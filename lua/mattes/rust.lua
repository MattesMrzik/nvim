local function stop_rust_analyzers()
    local clients = vim.lsp.get_clients({ name = "rust_analyzer" })
    if #clients == 0 then return end
    for _, client in ipairs(clients) do
        vim.lsp.stop_client(client.id, true)
    end
end


local function setup_rust_lsp(features)
    -- alternatively i could do similar to this: https://rutar.org/writing/rust-analyzer-dynamic-features/
    stop_rust_analyzers()
    vim.lsp.config("rust_analyzer", {
        cmd = { "/Users/mrzi/.cargo/bin/rust-analyzer" },
        settings = {
            ["rust-analyzer"] = {
                semanticHighlighting = false,
                check = { command = "clippy" },
                cargo = features,
                diagnostics = { enable = true },
                workspace = {
                    symbol = { search = { limit = 10000 } },
                },
            },
        },
        -- on_attach = function(_, bufnr) -- first param is the client, which we don't use
        --   -- Delay inlay hints to allow LSP to initialize
        --   vim.notify("Rust Analyzer attached", vim.log.levels.INFO)
        --   vim.defer_fn(function()
        --       vim.cmd("edit")
        --     local ft = vim.bo[bufnr].filetype
        --     if not ft:match("^Diffview") then
        --       vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        --     end
        --
        --     -- Optional hover customization (commented out)
        --     -- local hover = vim.lsp.buf.hover
        --     -- vim.lsp.buf.hover = function()
        --     --   return hover({ max_width = 100, max_height = 14, border = utils.border })
        --     -- end
        --   end, 4000)
        -- end,
    })

    -- Enable the server for its filetypes
    vim.lsp.enable("rust_analyzer")
end

setup_rust_lsp()

local function rust_get_cargo_toml()
    local ra = vim.lsp.get_clients({ name = "rust_analyzer" })[1]
    if not ra then return nil end

    local root
    if ra.workspace_folders then
        root = vim.uri_to_fname(ra.workspace_folders[1].uri)
    else
        root = ra.config.root_dir
    end

    return root .. "/Cargo.toml"
end

local function get_cargo_features(cargo_toml_path)
    local features = {}

    local in_features_block = false

    for line in io.lines(cargo_toml_path) do
        -- trim spaces
        line = line:match("^%s*(.-)%s*$")

        if line:match("^%[features%]") then
            in_features_block = true
        elseif in_features_block then
            if line == "" then
                break -- end of [features] block
            end

            -- match feature name before '='
            local name = line:match("^([%w%-%_]+)%s*=")
            if name then
                table.insert(features, name)
            end
        end
    end

    return features
end

local M = {
    features = {},       -- array of feature names
    feature_status = {}, -- dict: feature_name → boolean
}

-- Sync features with cargo_features from Cargo.toml
function M.sync_features(cargo_features)
    local present = {}

    -- mark all cargo features as present
    for _, f in ipairs(cargo_features) do
        present[f] = true
    end

    -- 1) remove features no longer present
    for i = #M.features, 1, -1 do
        local f = M.features[i]
        if not present[f] then
            table.remove(M.features, i)
            M.feature_status[f] = nil
        end
    end

    -- 2) add new features
    for _, f in ipairs(cargo_features) do
        if M.feature_status[f] == nil then
            table.insert(M.features, f)
            M.feature_status[f] = false -- default disabled
        end
    end
end

function M.toggle_features()
    local cargo_toml = rust_get_cargo_toml()
    if not cargo_toml then
        vim.notify("Could not find Cargo.toml for Rust Analyzer", vim.log.levels.ERROR)
        return
    end
    local features = get_cargo_features(cargo_toml)
    M.sync_features(features)

    local function build_display_list()
        local t = {}
        table.insert(t, "Done")

        for _, f in ipairs(M.features) do
            local mark = M.feature_status[f] and "x" or " "
            table.insert(t, mark .. " " .. f)
        end

        return t
    end
    local changed = false

    local function reopen_menu()
        vim.ui.select(build_display_list(), {
            prompt = "Toggle Rust features:",
        }, function(choice)
            if not choice or choice == "Done" then
                if changed then
                    vim.notify("Restarting Rust Analyzer with new features", vim.log.levels.INFO)
                    setup_rust_lsp(M.get_cargo_feature_table())

                    -- vim.defer_fn(function()
                    --     local view = vim.fn.winsaveview()
                    --     vim.cmd("edit")
                    --     vim.fn.winrestview(view)
                    -- end, 4000)
                else
                    vim.notify("No changes to features", vim.log.levels.INFO)
                end
                return
            end

            -- strip "✓ " or "  "
            local feature = choice:sub(3)

            -- toggle
            M.feature_status[feature] = not M.feature_status[feature]
            changed = true

            reopen_menu()
        end)
    end

    reopen_menu()
end

function M.get_cargo_feature_table()
    local enabled = {}

    for _, f in ipairs(M.features) do
        if M.feature_status[f] then
            table.insert(enabled, f)
        end
    end

    return { features = enabled }
end

-- enables cargo fmt on save, i think this might be less efficient than rust fmt since
-- cargo does every file (i think) and not only the changed ones, but (i think) cargo fmt produces better formats
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.rs",
    callback = function()
        vim.lsp.buf.format()
    end
})
-- shows deduced variable types as hint
vim.lsp.inlay_hint.enable(true)

-- code completion
local cmp = require("cmp")
local types = require('cmp.types')
local compare_kinds = function(kind, reverse)
    return function(entry1, entry2)
        local kind1 = entry1:get_kind()
        local kind2 = entry2:get_kind()
        if kind1 == kind and kind2 ~= kind then
            return not reverse
        elseif kind2 == kind and kind1 ~= kind then
            return reverse
        end
        return nil
    end
end

local modify_text_edit = function(entry, _) -- second param was called ctx
    local item = entry:get_completion_item()
    if item.textEdit and item.textEdit.range then
        local range = item.textEdit.range
        local on_same_line = range.start.line == range["end"].line
        if on_same_line then
            item.textEdit.range["end"].character = item.textEdit.range.start.character
            entry.completion_item = item
        end
    end
    return true
end

cmp.setup({
    window = {
        completion = cmp.config.window.bordered {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
        },
        documentation = cmp.config.window.bordered {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        },
    },
    preselect = cmp.PreselectMode.None,
    completion = {
        completeopt = 'menu,menuone,preview',
    },
    mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({ behaviour = cmp.ConfirmBehavior.Insert }),
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
    },
    sources = {
        { name = 'nvim_lsp', entry_filter = modify_text_edit },
        { name = 'vsnip' },
        { name = 'path' },
        { name = 'buffer' },
    },
    sorting = {
        comparators = {
            function(e1, e2)
                return compare_kinds(types.lsp.CompletionItemKind.Text, true)(e1, e2)
            end,
            cmp.config.compare.exact,
            cmp.config.compare.offset,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            function(e1, e2)
                return compare_kinds(types.lsp.CompletionItemKind.Field, false)(e1, e2)
            end,
            function(e1, e2)
                return compare_kinds(types.lsp.CompletionItemKind.Method, false)(e1, e2)
            end,
            function(e1, e2)
                return compare_kinds(types.lsp.CompletionItemKind.Variable, false)(e1, e2)
            end,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
})

--cmp.event:on('confirm_done', function(event)
--print("Confirm done event triggered")
--local entry = event.entry
--local item = entry:get_completion_item()
--if item.textEdit and item.textEdit.range then
--print("TextEdit range found, processing...")
--print(vim.inspect(item.textEdit))
--local range = item.textEdit.range
---- Only patch if the range is on a single line and removes at most one word
--if range.start.line == range["end"].line then
--local bufnr = vim.api.nvim_get_current_buf()
--local line_text = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range.start.line + 1, false)[1] or ""
--local removed_text = line_text:sub(range.start.character + 1 - #item.textEdit.newText, range["end"].character - #item.textEdit.newText + 1)
--print("Removed text: " .. removed_text)
---- Check if the removed text is a single word (no whitespace)
----if removed_text:match("^%w+$") then
--print("Single word removed, patching textEdit range...")
---- Patch the end column to match the start column (insert only, don't replace)
--item.textEdit.range["end"].character = item.textEdit.range.start.character
--entry.completion_item = item
----end
--end
--end
--end)


-- utility method used in remap.lua
local ts_utils = require("nvim-treesitter.ts_utils")

function M.setup_rust_lsp(feature)
    setup_rust_lsp(feature)
end

function M.jump_to_trait()
    -- Step 1: Find function_item and extract function name
    local node = ts_utils.get_node_at_cursor()
    local fn_name = nil
    local search_node = node
    while search_node do
        if search_node:type() == "function_item" then
            for child in search_node:iter_children() do
                if child:type() == "identifier" then
                    fn_name = vim.treesitter.get_node_text(child, 0)
                    break
                end
            end
            break
        end
        search_node = search_node:parent()
    end

    -- Step 2: Find the impl_item
    while node do
        if node:type() == "impl_item" then
            for child in node:iter_children() do
                if child:type() == "type_identifier" or child:type() == "generic_type" then
                    local row, col = child:range()
                    --vim.api.nvim_win_set_cursor(0, { row + 1, col + 1 })

                    local params = vim.lsp.util.make_position_params(nil, "utf-16")
                    params.position = {
                        line = row,
                        character = col,
                    }

                    vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
                        if not result or vim.tbl_isempty(result) then
                            print("No trait found.")
                            return
                        end

                        result = result[1]
                        local filename = vim.uri_to_fname(result.targetUri)
                        local lnum = result.targetSelectionRange.start.line
                        -- local col = result.targetSelectionRange.start.character
                        local bufnr = vim.fn.bufnr(filename)
                        if bufnr == -1 then bufnr = vim.fn.bufnr(filename, true) end
                        if vim.fn.bufloaded(bufnr) ~= 1 then vim.fn.bufload(bufnr) end

                        local parser = vim.treesitter.get_parser(bufnr, "rust")
                        if parser == nil then
                            print("No parser found for buffer:", bufnr)
                            return
                        end
                        local tree = parser:parse()[1]
                        if not tree then return end

                        local trait_node = vim.treesitter.get_node({ bufnr = bufnr, pos = { lnum, col } })
                        while trait_node and trait_node:type() ~= "trait_item" do
                            trait_node = trait_node:parent()
                        end
                        if not trait_node then
                            print("Not in a trait_item.")
                            return
                        end

                        -- Find declaration_list body
                        local body
                        for cc in trait_node:iter_children() do
                            if cc:type() == "declaration_list" then
                                body = cc
                                break
                            end
                        end

                        if not body then
                            print("No declaration_list found.")
                            return
                        end

                        if not fn_name then
                            -- no specific function, jump to start of trait
                            vim.api.nvim_set_current_buf(bufnr)
                            vim.api.nvim_win_set_cursor(0, { lnum + 1, col })
                            return
                        end

                        -- Step 3: search for function with matching name
                        for sig in body:iter_children() do
                            if sig:type() == "function_signature_item" or sig:type() == "function_item" then
                                for subnode in sig:iter_children() do
                                    if subnode:type() == "identifier" then
                                        local text = vim.treesitter.get_node_text(subnode, bufnr)
                                        print("text = ", text)
                                        if text == fn_name then
                                            local srow, scol = subnode:range()
                                            vim.api.nvim_set_current_buf(bufnr)
                                            vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
                                            return
                                        end
                                    end
                                end
                            end
                        end

                        print("Function not found in trait.")
                    end)
                    return
                end
            end
        end
        node = node:parent()
    end

    print("No impl block found.")
end

return M
