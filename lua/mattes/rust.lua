require'lspconfig'.rust_analyzer.setup {
    cmd = {"/Users/mrzi/.cargo/bin/rust-analyzer"},
    settings = {
        ['rust-analyzer'] = {
            semanticHighlighting = false,
            check = {
                command = "clippy";
            },
            diagnostics = {
                enable = true;
            },
            workspace = {
                symbol = {
                    search = {
                        limit = 10000,
                    },
                },
            },
        }
    },
    -- since the lsp takes some time to startup, calling the inlay_hint immediately has no effect
    -- so the call is delayed
    on_attach = function(client, bufnr)
        vim.defer_fn(function()
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end, 4000)
    end,
}


-- enables cargo fmt on save, i think this might be less efficient than rust fmt since 
-- cargo does every file (i think) and not only the changed ones, but (i think) cargo fmt produces better formats
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.rs",
  callback = function()
    vim.cmd("silent !cargo fmt")
  end,
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
cmp.setup({
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
        ["<CR>"] = cmp.mapping.confirm({behaviour = cmp.ConfirmBehavior.Insert}),
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
    },
    sources =  {
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'path' },
        { name = 'buffer' },
    },
    sorting = {
        comparators = {
            function (e1, e2)
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

-- utility method used in remap.lua
local ts_utils = require("nvim-treesitter.ts_utils")
local M = {}

function M.jump_to_trait()
    local node = ts_utils.get_node_at_cursor()
    local fn_name = nil

    -- Step 1: Find function_item and extract function name
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
                    vim.api.nvim_win_set_cursor(0, { row + 1, col + 1 })

                    local params = vim.lsp.util.make_position_params(nil, "utf-16")
                    vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
                        if not result or vim.tbl_isempty(result) then
                            print("No trait found.")
                            return
                        end

                        result = result[1]
                        local filename = vim.uri_to_fname(result.targetUri)
                        local lnum = result.targetSelectionRange.start.line
                        local col = result.targetSelectionRange.start.character
                        local bufnr = vim.fn.bufnr(filename)
                        if bufnr == -1 then bufnr = vim.fn.bufnr(filename, true) end
                        if vim.fn.bufloaded(bufnr) ~= 1 then vim.fn.bufload(bufnr) end

                        local parser = vim.treesitter.get_parser(bufnr, "rust")
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
                            vim.api.nvim_win_set_cursor(0, { lnum + 1, col})
                            return
                        end

                        -- Step 3: search for function with matching name
                        for sig in body:iter_children() do
                            if sig:type() == "function_signature_item" then
                                for subnode in sig:iter_children() do
                                    if subnode:type() == "identifier" then
                                        local text = vim.treesitter.get_node_text(subnode, bufnr)
                                        if text == fn_name then
                                            local srow, scol = subnode:range()
                                            vim.api.nvim_set_current_buf(bufnr)
                                            vim.api.nvim_win_set_cursor(0, { srow+1, scol})
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

