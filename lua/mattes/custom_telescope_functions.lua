--local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local builtin = require("telescope.builtin")
local fzy = require("telescope.algos.fzy")

local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values

local M = {}
local kind_icons = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "󱄑",
    Class = "",
    Struct = "",
    Interface = "",
    Module = "",
    Property = "ﰠ",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
    Trait = "",
}

local kind_highlights = {
    Text = "TelescopeSymbolText",
    Method = "TelescopeSymbolMethod",
    Function = "TelescopeSymbolFunction",
    Constructor = "TelescopeSymbolConstructor",
    Field = "TelescopeSymbolField",
    Variable = "TelescopeSymbolVariable",
    Class = "TelescopeSymbolClass",
    Interface = "TelescopeSymbolInterface",
    Module = "TelescopeSymbolModule",
    Property = "TelescopeSymbolProperty",
    Unit = "TelescopeSymbolUnit",
    Value = "TelescopeSymbolValue",
    Enum = "TelescopeSymbolEnum",
    Keyword = "TelescopeSymbolKeyword",
    Snippet = "TelescopeSymbolSnippet",
    Color = "TelescopeSymbolColor",
    File = "TelescopeSymbolFile",
    Reference = "TelescopeSymbolReference",
    Folder = "TelescopeSymbolFolder",
    EnumMember = "TelescopeSymbolEnumMember",
    Constant = "TelescopeSymbolConstant",
    Struct = "TelescopeSymbolStruct",
    Event = "TelescopeSymbolEvent",
    Operator = "TelescopeSymbolOperator",
    TypeParameter = "TelescopeSymbolTypeParameter",
    Trait = "TelescopeSymbolObject",
}

local function flatten(symbols, result)
    for _, symbol in ipairs(symbols) do
        table.insert(result, symbol)
        if symbol.children then
            flatten(symbol.children, result)
        end
    end
end

local function get_block_info(line, bufnr)
    local node = vim.treesitter.get_node({bufnr = bufnr, pos = {line,0} })
    local while_count = 0
    local patterns = {
        "^(impl.*)",
        "(trait .*)",   -- match e.g. "(trait MyTrait)"
        "(struct .*)",  -- match e.g. "(struct MyStruct)"
    }
    while node do
        while_count = while_count +1
        if while_count > 10 then
            break
        end
        local start_row, start_col, end_row, end_col = vim.treesitter.get_node_range(node)
        local lines = vim.api.nvim_buf_get_lines(bufnr, start_row-1, start_row + 10, false)
        for i, l in pairs(lines) do
            if i > 10 then
                break
            end
            for _, pat in pairs(patterns) do
                local m = l:match(pat)
                if m ~= nil then
                    return m
                end
            end
        end
        node = node:parent()
    end
end

M.dynamic_layout_config = function()
    local cursor_line = vim.fn.winline()
    local total_lines = vim.api.nvim_win_get_height(0)
    local is_bottom = cursor_line > total_lines / 2
    return {
        height = 0.47,
        width = 0.8,
        --prompt_position = "top",
        anchor = is_bottom and "N" or "S",
    }
end

M.custom_lsp_document_symbols = function()
    vim.lsp.buf_request(0, "textDocument/documentSymbol", { textDocument = vim.lsp.util.make_text_document_params() }, function(err, symbols, ctx, _)
        if err or not symbols then return end

        local flat_symbols = {}
        flatten(symbols, flat_symbols)

        local displayer = entry_display.create({
            separator = " ",
            items = {
                { width = 2 },
                { width = 30},
                { width = 40},
                { remaining = true },
            },
        })

        local function make_entry(symbol)
            local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or "Unknown"
            if kind == "Interface" or kind == "Object" then
                kind = "Trait"
            end
            local icon = kind_icons[kind] or ""
            local hl = kind_highlights[kind] or ""
            local detail = symbol.detail or ""
            local custom = get_block_info(symbol.range.start.line+1, 0) or ""
            return {
                value = symbol,
                ordinal = symbol.name .. " " .. kind, -- i can search "method" and it then only displays methods
                display = function()
                    return displayer({
                        { icon , hl },
                        symbol.name,
                        {custom, "TelescopeMyHint"},
                        {detail, "TelescopeMyHint"},
                    })
                end,
                lnum = symbol.selectionRange.start.line + 1,
                col = symbol.selectionRange.start.character + 1,
                filename = vim.api.nvim_buf_get_name(0),
            }
        end

        local sorter = conf.generic_sorter({})

        -- the highlighter should only highlight the (first and) second col, ie where the name is in 
        sorter.highlighter = function (a,b,c)
            return fzy.positions(b,c:sub(0,36))
        end
        local cursor_line = vim.fn.winline()
        local total_lines = vim.api.nvim_win_get_height(0)
        local is_bottom = cursor_line > total_lines / 2
        local style = M.dynamic_layout_config()

        pickers.new({}, {
            prompt_title = "My Document Symbols",
            preview_title = "",
            results_title = "",
            finder = finders.new_table({
                results = flat_symbols,
                entry_maker = make_entry,
            }),
            previewer = conf.qflist_previewer({}),
            sorter = sorter,
            layout_config = {
                horizontal = {
                    preview_width = 0.4, -- percent of total width; default is 0.5
                    height = style.height,
                    width = style.width,
                    anchor = style.anchor,
                },
            },
        }):find()
    end)
end

local function filter_function_defs_from_references(references)
    local filtered_references = vim.tbl_filter(function(reference)
        local filename = vim.uri_to_fname(reference.uri)
        local lnum = reference.range.start.line
        local col = reference.range.start.character
        local bufnr = vim.fn.bufnr(filename)
        if bufnr == -1 then
            -- buffer is not open -> get bufnr
            bufnr = vim.fn.bufnr(filename, true)
        end

        if vim.fn.bufloaded(bufnr) ~= 1 then
            -- buffer with bufnr is not loaded -> load
            vim.fn.bufload(bufnr)
            local parser = vim.treesitter.get_parser(bufnr, "rust")
            local tree = parser:parse()[1]
            if not tree then
                return nil
            end
        end
        local node = vim.treesitter.get_node({bufnr = bufnr, pos = {lnum,col} })
        if node:parent():type() =="function_item" then
            return false
        else
            return true
        end
    end, references)
    return filtered_references
end

M.custom_lsp_references = function()
    local params = vim.lsp.util.make_position_params(nil, "utf-16")
    params.context = { includeDeclaration = false}
    vim.lsp.buf_request(0, "textDocument/references", params, function(err, references, ctx, _)
        if err or not references or vim.tbl_isempty(references) then
            print(err)
            vim.notify("No references found", vim.log.levels.INFO)
            return
        end

        local flat_references = {}
        flatten(references, flat_references)
        local filtered_references = filter_function_defs_from_references(flat_references)

        if #filtered_references == 0 then
            print("No references found")
            return
        end

        -- this are the columns, here only one
        local displayer = entry_display.create({
            separator = " ",
            items = {
                { remaining = true },
            },
        })

        local function make_entry(loc)
            local filename = vim.uri_to_fname(loc.uri)
            filename = vim.fn.fnamemodify(filename, ":.")
            local lnum = loc.range.start.line
            local col = loc.range.start.character

            return {
                value = loc,
                ordinal = filename,
                display = function()
                    return displayer({
                        filename,
                    })
                end,
                filename = filename,
                lnum = lnum + 1,
                col = col + 1,
            }
        end

        local sorter = conf.generic_sorter({})
        sorter.highlighter = function(_, line, prompt)
            return fzy.positions(line, prompt)
        end
        local style = M.dynamic_layout_config()
        pickers.new({}, {
            prompt_title = "My LSP References",
            preview_title = "",
            results_title = "",

            finder = finders.new_table({
                results = filtered_references,
                entry_maker = make_entry,
            }),
            previewer = conf.qflist_previewer({}),
            sorter = sorter,
            layout_config = {
                horizontal = { preview_width = 0.4},
                height = style.height,
                width = style.width,
                anchor = style.anchor,
            },
        }):find()
    end)
end

local function load_buffer_and_treesitter_parse(filename)
    local bufnr = vim.fn.bufnr(filename)
    if bufnr == -1 then
        bufnr = vim.fn.bufnr(filename, true)
    end

    if vim.fn.bufloaded(bufnr) ~= 1 then
        vim.fn.bufload(bufnr)
        local parser = vim.treesitter.get_parser(bufnr, "rust")
        if not parser then
            print("No parser available for language: " .. lang)
            return nil
        end

        local tree = parser:parse()[1]
        if not tree then
            print("Failed to parse buffer")
            return nil
        end
        vim.fn.bufload(bufnr)
    end
    return bufnr
end

M.custom_lsp_implementations = function()
    vim.lsp.buf_request(0, "textDocument/implementation", vim.lsp.util.make_position_params(nil, "utf-16"), function(err, implementations, ctx, _)
        if err or not implementations then
            vim.notify("No implementations found", vim.log.levels.INFO)
            return
        end

        local current_file = vim.api.nvim_buf_get_name(0)
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        local filtered_implementations = vim.tbl_filter(function(implementation)
            return not (
                vim.uri_to_fname(implementation.targetUri) == current_file and
                implementation.targetSelectionRange.start.line + 1 == cursor_pos[1]
            )
        end, implementations)

        if #filtered_implementations == 0 then
            print("No other implementations found")
            return
        end

        local displayer = entry_display.create({
            separator = " ",
            items = {
                { width = 30 },
                { remaining = true },
            },
        })

        local function make_entry(implementation)
            local filename = vim.uri_to_fname(implementation.targetUri)
            filename = vim.fn.fnamemodify(filename, ":.")

            local bufnr = load_buffer_and_treesitter_parse(filename)
            local line_number = implementation.targetSelectionRange.start.line
            local column = implementation.targetSelectionRange.start.character
            local custom = get_block_info(line_number, bufnr) or ""
            return {
                value = implementation,
                ordinal = filename,
                display = function()
                    return displayer({
                        filename,
                        {custom, "TelescopeMyHint"},
                    })
                end,
                filename = filename,
                lnum = line_number + 1,
                col = column + 1,
            }
        end

        local sorter = conf.generic_sorter({})
        sorter.highlighter = function(_, line, prompt)
            -- TODO: is this the correct order? is the line and the prompt in the line above really in this order?
            return fzy.positions(line, prompt)
        end

        local style = M.dynamic_layout_config()

        pickers.new({}, {
            prompt_title = "My LSP Implementations",
            preview_title = "",
            results_title = "",

            finder = finders.new_table({
                results = filtered_implementations,
                entry_maker = make_entry,
            }),
            previewer = conf.qflist_previewer({}),
            sorter = sorter,
            layout_config = {
                horizontal = { preview_width = 0.4 },
                height = style.height,
                width = style.width,
                anchor = style.anchor,
            },
        }):find()
    end)
end

M.custom_workspace_symbols = function()
    vim.lsp.buf_request(0, "workspace/symbol", {query = ""}, function(err, symbols, ctx, _)
        if err then
            print("LSP error:", vim.inspect(err))
            return
        end
        if not symbols or vim.tbl_isempty(symbols) then
            print("No symbols found")
            return
        end
        local flat_symbols= {}
        flatten(symbols, flat_symbols)
        local first_col_width = 40
        local second_col_width = 30

        -- this are the columns, here only one
        local displayer = entry_display.create({
            separator = " ",
            items = {
                {width = first_col_width},
                {width = second_col_width},
                { remaining = true },
            },
        })

        local function make_entry(symbol)
            local filename = vim.uri_to_fname(symbol.location.uri)
            filename = vim.fn.fnamemodify(filename, ":.")
            local lnum = symbol.location.range.start.line
            local col = symbol.location.range.start.character
            local name = symbol.name
            local kind = vim.lsp.protocol.SymbolKind[symbol.kind]
            if kind == "Interface" or kind == "Object" then
                kind = "Trait"
            end

            local hl = kind_highlights[kind] or ""

            return {
                value = symbol,
                ordinal = name .. " " .. kind,
                display = function()
                    return displayer({
                        filename,
                        name,
                        {kind, hl},
                    })
                end,
                filename = filename,
                lnum = lnum + 1,
                col = col + 1,
            }
        end

        local sorter = conf.generic_sorter({})
        sorter.highlighter = function (a,b,c)
            -- TODO: why do i make this ?
            -- perhaps bc i dont want to highlicth the first col?
            local positions = fzy.positions(b, c:sub(first_col_width, first_col_width + second_col_width))
            for i, pos in ipairs(positions) do
                positions[i] = pos + first_col_width - 1
            end
            return positions
        end
        local style = M.dynamic_layout_config()
        pickers.new({}, {
            prompt_title = "My LSP Workspace symbols",
            preview_title = "",
            results_title = "",

            finder = finders.new_table({
                results = flat_symbols,
                entry_maker = make_entry,
            }),
            previewer = conf.qflist_previewer({}),
            sorter = sorter,
            layout_config = {
                horizontal = { preview_width = 0.4},
                height = style.height,
                width = style.width,
                anchor = style.anchor,
            },
        }):find()

    end)
end

M.dynamic_picker = function(picker_fn, opts)
  opts = opts or {}
  opts.layout_config = M.dynamic_layout_config()
  opts.results_title = ""
  opts.preview_title = ""
  picker_fn(opts)
end

M.two_column_grep_string = function(opts)
    opts = opts or {}

    local displayer = entry_display.create({
        separator = " ",
        items = {
            { width = 40 },
            { remaining = true },
        },
    })


    local function make_entry(entry)
        local filename, lnum, col, text = entry:match("([^:]+):(%d+):(%d+):(.*)")
        filename = vim.fn.fnamemodify(filename or "", ":.")
        lnum = tonumber(lnum) or 0
        col = tonumber(col) or 0
        text = text or ""
        return {
            value = entry,
            ordinal = filename,
            display = function()
                return displayer({
                    filename,
                    {text, "TelescopeMyHint"},
                })
            end,
            filename = filename,
            lnum = lnum,
            col = col,
        }
    end
    local sorter = conf.generic_sorter({})
        sorter.highlighter = function (a,b,c)
            local positions = fzy.positions(b, c:sub(0, 40))
            if opts.search and #opts.search > 0 then
                local second_col = c:sub(41)
                local search_positions = fzy.positions(opts.search, second_col)
                for _, pos in ipairs(search_positions) do
                    table.insert(positions, 40 + pos)
                end
            end
            return positions
        end

    local style = M.dynamic_layout_config()
    builtin.grep_string(vim.tbl_extend("force", opts, {
        attach_mappings = function(_,_)
            return true
        end,
        entry_maker = make_entry,
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = { preview_width = 0.4},
            height = style.height,
            width = style.width,
            anchor = style.anchor,
        },
        results_title = "",
        preview_title = "",
        sorter = sorter,


    }))
end
return M
