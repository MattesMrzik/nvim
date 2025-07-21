--local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local builtin = require("telescope.builtin")
local fzy = require("telescope.algos.fzy")

local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values
local highlight = require("snacks.picker.util.highlight")
local M = {}
local kind_icons = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
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

local function get_highlights(text_and_hl)
    local highlights = {}
    local end_string = ""
    local sep = " "
    for i = 1, #text_and_hl do
        local text, hl_fn, col = text_and_hl[i][1], text_and_hl[i][2], text_and_hl[i][3]
        if text == nil then
            text = ""
        end
        if #text < col then
            text = text .. string.rep(" ", col - #text)
        end
        if #text > col then
            text = text:sub(1, col)
        end
        local highlights_for_col = hl_fn(text, #end_string)
        for hl_i = 1, #highlights_for_col do
            table.insert(highlights, highlights_for_col[hl_i])
        end
        end_string = end_string ..  text .. sep
    end
    return end_string, highlights
end

local function highlight_code(lang)
    return function(code, offset)
        local hls = {}
        highlight.format({}, code, hls, { lang = lang })
        -- print(vim.inspect(hls))
        local telescope_highlights = {}
        for _, extmark in ipairs(hls) do
            if extmark.col and extmark.end_col and extmark.hl_group then
                table.insert(telescope_highlights, { {extmark.col + offset, extmark.end_col + offset}, extmark.hl_group })
            end
        end
        return telescope_highlights
    end
end

local function return_hl_as_fn(hl)
    return function(text, offset)
        return {{{offset, #text + offset}, hl}}
    end
end

local function sub_fzy(start, end_col)
    return function(_, prompt, line)
        local positions = fzy.positions(prompt, line:sub(start, end_col))
        for i, pos in ipairs(positions) do
            positions[i] = pos + start - 1
        end
        return positions
    end
end

M.custom_lsp_document_symbols = function()
    vim.lsp.buf_request(0, "textDocument/documentSymbol", { textDocument = vim.lsp.util.make_text_document_params() }, function(err, symbols, ctx, _)
        if err or not symbols then return end

        local flat_symbols = {}
        flatten(symbols, flat_symbols)

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
                ordinal = symbol.name .. " " .. kind,
                display = function()
                    local highlighted_text, highlights = get_highlights(
                        {
                            {icon, return_hl_as_fn(hl), 3},
                            {symbol.name, return_hl_as_fn(hl), 30},
                            {custom, highlight_code("rust"), 30},
                        }
                    )
                    return highlighted_text, highlights
                end,
                lnum = symbol.selectionRange.start.line + 1,
                col = symbol.selectionRange.start.character + 1,
                filename = vim.api.nvim_buf_get_name(0),
            }
        end

        local sorter = conf.generic_sorter({})

        -- the highlighter should only highlight the (first and) second col, ie where the name is in 
        sorter.highlighter = sub_fzy(4, 34)
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
    local was_open = vim.api.nvim_buf_is_loaded(bufnr)
    if bufnr == -1 then
        -- assigns new buffer number
        bufnr = vim.fn.bufnr(filename, true)
    end
    if not vim.fn.bufloaded(bufnr) then
        vim.api.nvim_buf_set_var(bufnr, 'gitsigns_disable', true)
        vim.b[bufnr].gitsigns_disable = true
        vim.bo[bufnr].filetype = "nofile"
        print("Loading buffer: " .. filename)

        vim.fn.bufload(bufnr)

        require("gitsigns").detach(bufnr)
        vim.api.nvim_buf_set_option(0, 'statusline', '')
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
        --vim.fn.bufload(bufnr)
    end
    return bufnr, was_open
end

M._custom_lsp_implementations = function()
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
M.custom_lsp_implementations = function()
    local Snacks = require("snacks")
    vim.lsp.buf_request(0, "textDocument/implementation", vim.lsp.util.make_position_params(nil, "utf-16"), function(err, implementations, ctx, _)
        if err or not implementations then
            vim.notify("No implementations found", vim.log.levels.INFO)
            return
        end

        local current_file = vim.api.nvim_buf_get_name(0)
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        local filtered = vim.tbl_filter(function(impl)
            return not (
                vim.uri_to_fname(impl.targetUri) == current_file and
                impl.targetSelectionRange.start.line + 1 == cursor_pos[1]
            )
        end, implementations)

        if #filtered == 0 then
            vim.notify("No other implementations found", vim.log.levels.INFO)
            return
        end

        local items = {}
        for _, impl in ipairs(filtered) do
            local filename = vim.uri_to_fname(impl.targetUri)
            filename = vim.fn.fnamemodify(filename, ":.")
            local line = impl.targetSelectionRange.start.line
            local col = impl.targetSelectionRange.start.character
            local bufnr = load_buffer_and_treesitter_parse(filename)
            local custom = get_block_info(line, bufnr) or ""

            table.insert(items, {
                value = impl,
                file = filename,
                preview = {
                    file = filename,
                    line = line + 1,
                    col = col,
                },
                --line = custom,
                pos = {line + 1, col},
                text = custom,
            })
        end

        Snacks.picker {
            title = "LSP Implementations",
            items = items,
            matcher = {
                mods = {
                    field = "file",
                }
            }
        }
    end)
end
M.custom_workspace_symbols = function()
    vim.lsp.buf_request(0, "workspace/symbol", {query = "", searchKind = "allSymbols"}, function(err, symbols, ctx, _)
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

        M.get_cached_work_space_symbols_block_info(flat_symbols)
        --print(vim.inspect(M.cached_work_space_symbols_cleaned))
        local first_col_width = 40
        local second_col_width = 30

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

            local key = filename .. ":" .. lnum .. ":" .. col .. ":" .. name
            local custom = M.cached_work_space_symbols[key]

            return {
                value = symbol,
                ordinal = name .. " " .. kind,
                display = function ()
                    local t, h = get_highlights({
                        {filename, return_hl_as_fn("oldWhite"), first_col_width},
                        {name, return_hl_as_fn("oldWhite"), second_col_width},
                        {kind, return_hl_as_fn(hl), 10},
                        {custom, highlight_code("rust"), 30},
                    })
                    return t, h
                end,
                filename = filename,
                lnum = lnum + 1,
                col = col + 1,
            }
        end

        local sorter = conf.generic_sorter({})
        sorter.highlighter = sub_fzy(first_col_width, first_col_width + second_col_width)
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
        -- highlight the grep prompt in the string
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

M.cached_work_space_symbols = {}
M.cached_work_space_symbols_cleaned = {}

M.get_cached_work_space_symbols_block_info = function(flat_symbols)
    M.cached_work_space_symbols_cleaned = {}
    -- sort flat symbols by file name
    table.sort(flat_symbols, function(a, b)
        return a.location.uri < b.location.uri
    end)
    local last_file = nil
    local last_bufnr = nil
    local last_was_open = true 
    for i, symbol in ipairs(flat_symbols) do
        local file_name = vim.uri_to_fname(symbol.location.uri)
        file_name = vim.fn.fnamemodify(file_name, ":.")
        local lnum = symbol.location.range.start.line
        local col = symbol.location.range.start.character
        local name = symbol.name
        local key = file_name .. ":" .. lnum .. ":" .. col .. ":" .. name
        if M.cached_work_space_symbols[key] then
            M.cached_work_space_symbols_cleaned[key] = M.cached_work_space_symbols[key]
        else
            if last_file ~= file_name then
                -- close last buffer if it was open
                if last_bufnr ~= nil and vim.api.nvim_buf_is_loaded(last_bufnr) and not last_was_open then
                    vim.api.nvim_buf_delete(last_bufnr, {force = true})
                end
                -- load new buffer
                local bufnr = vim.fn.bufnr(file_name)
                if bufnr == -1 then
                    -- assigns new buffer number
                    bufnr = vim.fn.bufnr(file_name, true)
                end
                if vim.fn.bufloaded(bufnr) ~= 1 then
                    last_was_open = false
                    vim.bo[bufnr].filetype = "nofile"
                    vim.fn.bufload(bufnr)
                else
                    last_was_open = true
                end
                local parser = vim.treesitter.get_parser(bufnr, "rust")
                if not parser then
                    print("No parser available for language: rust")
                end
                local tree = parser:parse()[1]
                if not tree then
                    print("Failed to parse buffer")
                end
                last_file = file_name
                last_bufnr = bufnr
            end
            if last_bufnr then
                local custom = get_block_info(lnum, last_bufnr) or ""
                M.cached_work_space_symbols_cleaned[key] = custom
            end
        end
    end
    M.cached_work_space_symbols = M.cached_work_space_symbols_cleaned
end

M.workspace_dynamic = function()
    local first_col_width = 30
    local second_col_width = 30

    local sorter = conf.generic_sorter({})
    sorter.highlighter = sub_fzy(first_col_width, first_col_width + second_col_width)
    require('telescope.builtin').lsp_dynamic_workspace_symbols({
        entry_maker = function(symbol)
            -- print("inside entry_maker")
            -- print("symbol: ", vim.inspect(symbol))
            local filename = symbol.filename
            filename = vim.fn.fnamemodify(filename, ":.")
            local lnum = symbol.lnum
            local col = symbol.col
            local name = symbol.text
            -- the text is something like "[Struct] MyStruct" but also for other kinds, and i want to only have "MyStruct"
            if name:sub(1, 1) == "[" and name:find("]") then
                name = name:sub(name:find("]") + 2)
            end

            local kind =symbol.kind
            if kind == "Interface" or kind == "Object" then
                kind = "Trait"
            end

            -- print("kind: ", kind)
            local hl = kind_highlights[kind] or ""
            -- print("hl: ", hl)
            -- print("symbol: ", vim.inspect(symbol))
            return {
                value = symbol,
                ordinal = name .. " " .. kind,
                display = function ()
                    local t, h = get_highlights({
                        {filename, return_hl_as_fn("oldWhite"), first_col_width},
                        {name, return_hl_as_fn("oldWhite"), second_col_width},
                        {kind, return_hl_as_fn(hl), 10},
                    })
                    return t, h
                end,
                filename = filename,
                lnum = lnum ,
                col = col,
            }
        end,
        slow_entry_maker = function(symbol)
            print("inside slow entry_maker")
            -- print("symbol: ", vim.inspect(symbol))
            local filename = symbol.filename
            filename = vim.fn.fnamemodify(filename, ":.")
            local lnum = symbol.lnum
            local col = symbol.col
            local name = symbol.text
            -- the text is something like "[Struct] MyStruct" but also for other kinds, and i want to only have "MyStruct"
            if name:sub(1, 1) == "[" and name:find("]") then
                name = name:sub(name:find("]") + 2)
            end

            local kind =symbol.kind
            if kind == "Interface" or kind == "Object" then
                kind = "Trait"
            end

            -- print("kind: ", kind)
            local hl = kind_highlights[kind] or ""
            local custom = ""
            if kind == "Function" then
                local bufnr = load_buffer_and_treesitter_parse(filename)
                custom = get_block_info(lnum, bufnr) or ""
            end
            -- print("hl: ", hl)
            -- print("symbol: ", vim.inspect(symbol))
            return {
                value = symbol,
                ordinal = name .. " " .. kind,
                display = function ()
                    local t, h = get_highlights({
                        {filename, return_hl_as_fn("oldWhite"), first_col_width},
                        {name, return_hl_as_fn("oldWhite"), second_col_width},
                        {kind, return_hl_as_fn(hl), 10},
                        {custom, highlight_code("rust"), 30},
                    })
                    return t, h
                end,
                filename = filename,
                lnum = lnum ,
                col = col,
            }
        end,

        sorter = sorter,
    })
end
return M
