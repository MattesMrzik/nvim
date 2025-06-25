local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local fzy = require("telescope.algos.fzy")

local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values
local lsp_util = vim.lsp.util

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

vim.api.nvim_set_hl(0, "TelescopeSymbolText",         { fg = "#f8f8f2" }) -- white
vim.api.nvim_set_hl(0, "TelescopeSymbolMethod",       { fg = "#50fa7b" }) -- green
vim.api.nvim_set_hl(0, "TelescopeSymbolFunction",     { fg = "#ffb86c" }) -- orange
vim.api.nvim_set_hl(0, "TelescopeSymbolConstructor",  { fg = "#ff79c6" }) -- pink
vim.api.nvim_set_hl(0, "TelescopeSymbolField",        { fg = "#8be9fd" }) -- cyan
vim.api.nvim_set_hl(0, "TelescopeSymbolVariable",     { fg = "#403e0b" }) -- yellow
vim.api.nvim_set_hl(0, "TelescopeSymbolClass",        { fg = "#8be9fd" }) -- cyan
vim.api.nvim_set_hl(0, "TelescopeSymbolInterface",    { fg = "#bd93f9" }) -- purple
vim.api.nvim_set_hl(0, "TelescopeSymbolModule",       { fg = "#ff79c6" }) -- pink
vim.api.nvim_set_hl(0, "TelescopeSymbolProperty",     { fg = "#66d9ef" }) -- light blue
vim.api.nvim_set_hl(0, "TelescopeSymbolUnit",         { fg = "#bd93f9" }) -- purple
vim.api.nvim_set_hl(0, "TelescopeSymbolValue",        { fg = "#f1fa8c" }) -- yellow
vim.api.nvim_set_hl(0, "TelescopeSymbolEnum",         { fg = "#ffb86c" }) -- orange
vim.api.nvim_set_hl(0, "TelescopeSymbolKeyword",      { fg = "#ff5555" }) -- red
vim.api.nvim_set_hl(0, "TelescopeSymbolSnippet",      { fg = "#f8f8f2" }) -- white
vim.api.nvim_set_hl(0, "TelescopeSymbolColor",        { fg = "#fab387" }) -- peach
vim.api.nvim_set_hl(0, "TelescopeSymbolFile",         { fg = "#f8f8f2" }) -- white
vim.api.nvim_set_hl(0, "TelescopeSymbolReference",    { fg = "#ffb86c" }) -- orange
vim.api.nvim_set_hl(0, "TelescopeSymbolFolder",       { fg = "#94e2d5" }) -- teal
vim.api.nvim_set_hl(0, "TelescopeSymbolEnumMember",   { fg = "#bd93f9" }) -- purple
vim.api.nvim_set_hl(0, "TelescopeSymbolConstant",     { fg = "#f38ba8" }) -- light red
vim.api.nvim_set_hl(0, "TelescopeSymbolStruct",       { fg = "#fab387" }) -- peach
vim.api.nvim_set_hl(0, "TelescopeSymbolEvent",        { fg = "#f38ba8" }) -- light red
vim.api.nvim_set_hl(0, "TelescopeSymbolOperator",     { fg = "#ff5555" }) -- red
vim.api.nvim_set_hl(0, "TelescopeSymbolTypeParameter",{ fg = "#b4befe" }) -- lavender
vim.api.nvim_set_hl(0, "TelescopeSymbolObject",       { fg = "#b4bffe" }) -- lavender


vim.api.nvim_set_hl(0, "TelescopeMyHint", {fg = "#434544"})
vim.api.nvim_set_hl(0, "TelescopeAutoSearch", {fg = "#DBB0AF"})


local ts_utils = require('nvim-treesitter.ts_utils')
local function get_block_info(line, bufnr)
    -- local node = ts_utils.get_node_at_cursor()
    if vim.fn.bufloaded(bufnr) ~= 1 then
        print("not loaded")
    else
        print("loaded in get block info")
    end
    local node = vim.treesitter.get_node({bufnr = bufnr, pos = {line-1,0} })
    local while_count = 0
    local patterns = {
        "^(impl.*)",
        "(trait .*)",   -- match e.g. "(trait MyTrait)"
        "(struct .*)",  -- match e.g. "(struct MyStruct)"
    }
    while node do
        print("processing node")
        while_count = while_count +1
        if while_count > 10 then
            break
        end
        --print("node range = ", vim.treesitter.get_node_range(node))
        local start_row, start_col, end_row, end_col = vim.treesitter.get_node_range(node)
        --print("start_row = ", start_row)   
        local lines = vim.api.nvim_buf_get_lines(bufnr, start_row-1, start_row + 10, false)
        for i, line in pairs(lines) do
            if i > 10 then
                break
            end
            for _, pat in pairs(patterns) do
                local m = line:match(pat)
                if m ~= nil then
                    return m
                end
            end
        end
        node = node:parent()
    end
end


-- Create the custom picker
M.custom_lsp_document_symbols = function()
    vim.lsp.buf_request(0, "textDocument/documentSymbol", { textDocument = vim.lsp.util.make_text_document_params() }, function(err, result, ctx, _)
        if err or not result then return end

        local function flatten_symbols(symbols, result)
            for _, symbol in ipairs(symbols) do
                table.insert(result, symbol)
                if symbol.children then
                    flatten_symbols(symbol.children, result)
                end
            end
        end

        local flat_symbols = {}
        flatten_symbols(result, flat_symbols)

        -- Telescope entry display
        local displayer = entry_display.create({
            separator = " ",
            items = {
                { width = 2 },
                { width = 30},
                { width = 40},
                { remaining = true }, -- preview or extra info
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
                lnum = symbol.range.start.line + 1,
                col = symbol.range.start.character + 1,
                filename = vim.api.nvim_buf_get_name(0),
            }
        end

        local sorter = conf.generic_sorter({})

        sorter.highlighter = function (a,b,c)
            return fzy.positions(b,c:sub(0,36))
        end
        pickers.new({}, {
            prompt_title = "My Document Symbols",
            finder = finders.new_table({
                results = flat_symbols,
                entry_maker = make_entry,
            }),
            previewer = conf.qflist_previewer({}),
            sorter = sorter,
            layout_config = {
                horizontal = {
                    preview_width = 0.4, -- percent of total width; default is 0.5
                },
            },
        }):find()
    end)
end


M.custom_lsp_references = function()
    local params = vim.lsp.util.make_position_params(nil, "utf-16")
    params.context = { includeDeclaration = false}
    vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, ctx, _)
        if err or not result or vim.tbl_isempty(result) then
            print(err)
            vim.notify("No references found", vim.log.levels.INFO)
            return
        end
        local function flatten_symbols(symbols, result)
            for _, symbol in ipairs(symbols) do
                table.insert(result, symbol)
                if symbol.children then
                    flatten_symbols(symbol.children, result)
                end
            end
        end

        local flat_symbols = {}
        flatten_symbols(result, flat_symbols)

        flat_symbols = vim.tbl_filter(function(loc)
            local filename = vim.uri_to_fname(loc.uri)
            local lnum = loc.range.start.line 
            local col = loc.range.start.character
            local bufnr = vim.fn.bufnr(filename)
            if bufnr == -1 then
                bufnr = vim.fn.bufnr(filename, true)
            end

            if vim.fn.bufloaded(bufnr) ~= 1 then
                vim.fn.bufload(bufnr)
                local parser = vim.treesitter.get_parser(bufnr, "rust")

                local tree = parser:parse()[1]
                if not tree then
                    return nil
                end
                vim.fn.bufload(bufnr)
            end
            local node = vim.treesitter.get_node({bufnr = bufnr, pos = {lnum,col} })
            if node:parent():type() =="function_item" then
                return false
            else
                return true
            end
        end, flat_symbols)

        if #flat_symbols == 0 then
            return
        end
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

            --local node = vim.treesitter.get_node({bufnr = bufnr, pos = {lnum,col} })
            --local text = vim.treesitter.get_node_text(node, bufnr)

            return {
                value = loc,
                ordinal = filename,
                display = function()
                    return displayer({
                        filename,
                    })
                end,
                filename = filename,
                lnum = lnum+1,
                col = col+1,
            }
        end

        local sorter = conf.generic_sorter({})
        sorter.highlighter = function(_, line, prompt)
            return fzy.positions(line, prompt)
        end

        pickers.new({}, {
            prompt_title = "My LSP Implementations",
            finder = finders.new_table({
                results = flat_symbols,
                entry_maker = make_entry,
            }),
            previewer = conf.qflist_previewer({}),
            sorter = sorter,
            layout_config = {
                horizontal = { preview_width = 0.8},
            },
        }):find()
    end)
end


M.custom_lsp_implementations = function()
    vim.lsp.buf_request(0, "textDocument/implementation", vim.lsp.util.make_position_params(nil, "utf-16"), function(err, result, ctx, _)
        if err or not result then
            vim.notify("No implementations found", vim.log.levels.INFO)
            return
        end

        local cursor_pos = vim.api.nvim_win_get_cursor(0) -- {line, col}
        local bufnr = vim.api.nvim_get_current_buf()
        local locations = vim.lsp.util.locations_to_items(result, bufnr)
        --print(vim.inspect(locations))
        local current_file = vim.api.nvim_buf_get_name(0)
        locations = vim.tbl_filter(function(loc)
            return not (
                loc.filename == current_file and
                loc.lnum == cursor_pos[1]
            )
        end, locations)
        if #locations == 0 then
            return
        end
        local displayer = entry_display.create({
            separator = " ",
            items = {
                { width = 30 },
                { remaining = true },
            },
        })

        local function make_entry(loc)
            local filename = vim.fn.fnamemodify(loc.filename, ":.")
            local text = loc.text or ""

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
            if vim.fn.bufloaded(bufnr) ~= 1 then
                print("still not loaded")
            else
                print("now loaded")
            end
            local custom = get_block_info(loc.lnum, bufnr) or ""

            return {
                value = loc,
                ordinal = filename .. " " .. text,
                display = function()
                    return displayer({
                        filename,
                        {custom, "TelescopeMyHint"},
                    })
                end,
                filename = loc.filename,
                lnum = loc.lnum,
                col = loc.col,
            }
        end

        local sorter = conf.generic_sorter({})
        sorter.highlighter = function(_, line, prompt)
            return fzy.positions(line, prompt)
        end

        pickers.new({}, {
            prompt_title = "My LSP Implementations",
            finder = finders.new_table({
                results = locations,
                entry_maker = make_entry,
            }),
            previewer = conf.qflist_previewer({}),
            sorter = sorter,
            layout_config = {
                horizontal = { preview_width = 0.6 },
            },
        }):find()
    end)
end



return M

