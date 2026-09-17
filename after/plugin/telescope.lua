-- close on first esc not second
local actions = require("telescope.actions")
local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")

local function select_same_buffer(prompt_bufnr, picker, win)
    local entry = action_state.get_selected_entry()
    require("telescope.pickers").on_close_prompt(prompt_bufnr)
    if not vim.api.nvim_win_is_valid(win) then
        return
    end
    pcall(vim.api.nvim_set_current_win, win)

    if picker.push_cursor_on_edit then
        vim.cmd "normal! m'"
    end
    if picker.push_tagstack_on_edit then
        local from = { vim.fn.bufnr "%", vim.fn.line ".", vim.fn.col ".", 0 }
        local items = { { tagname = vim.fn.expand "<cword>", from = from } }
        vim.fn.settagstack(vim.fn.win_getid(), { items = items }, "t")
    end

    local row = entry.row or entry.lnum
    local col = entry.col
    local pos = vim.api.nvim_win_get_cursor(0)
    if col == nil then
        if row == pos[1] then
            col = pos[2] + 1
        elseif row == nil then
            row, col = pos[1], pos[2] + 1
        else
            col = 1
        end
    end
    if col and col > 0 then
        col = col - 1
    end
    if row and col then
        pcall(vim.cmd, "normal! " .. row .. "G")
        vim.api.nvim_win_set_cursor(0, { row, col })
        local line = vim.api.nvim_get_current_line()
        local c = col
        while c < #line do
            local ch = line:sub(c, c)
            if ch ~= "." and ch ~= ":" then break end
            c = c + 1
        end
        vim.api.nvim_win_set_cursor(0, { row, c })
    end
end

local function entry_in_window(entry, win)
    if not entry or not vim.api.nvim_win_is_valid(win) then
        return false
    end
    local wbuf = vim.api.nvim_win_get_buf(win)
    if entry.bufnr and entry.bufnr > 0 then
        return entry.bufnr == wbuf
    end
    local fname = entry.filename or entry.path
    if not fname or fname == "" then
        return false
    end
    local cur = vim.api.nvim_buf_get_name(wbuf)
    if cur == "" then return false end
    local resolve = function(p)
        return vim.uv.fs_realpath(p) or p
    end
    return resolve(fname) == resolve(cur)
end

local function select_and_center(prompt_bufnr, how)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local win = picker.original_win_id
    local entry = action_state.get_selected_entry()

    if how == "default" and entry_in_window(entry, win) then
        select_same_buffer(prompt_bufnr, picker, win)
    else
        action_set.select(prompt_bufnr, how)
    end

    vim.defer_fn(function()
        require("mattes.picker_vp").settle(win)
    end, 25)
end

require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
                ["<CR>"] = function(p) select_and_center(p, "default") end,
                ["<C-x>"] = function(p) select_and_center(p, "horizontal") end,
                ["<C-v>"] = function(p) select_and_center(p, "vertical") end,
            },
            n = {
                ["<CR>"] = function(p) select_and_center(p, "default") end,
                ["<C-x>"] = function(p) select_and_center(p, "horizontal") end,
                ["<C-v>"] = function(p) select_and_center(p, "vertical") end,
                -- ["<C-t>"] = actions.goto_file_selection_tab + actions.center,
            },
        },
        layout_config = {
            --horizontal = {width = {padding = 0}, height = {padding = 0}}
            horizontal = { width = 0.9, height = 0.9 },
        },
    },
})
-- show line numbers in previewer
vim.cmd([[autocmd User TelescopePreviewerLoaded setlocal number]])
