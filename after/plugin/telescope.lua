-- close on first esc not second
local actions = require("telescope.actions")
local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")

-- Jump to an entry that lives in the current buffer. Skips telescope's
-- same-buffer `:edit` re-read (avoids the file flicker / viewport re-anchor),
-- moves the cursor directly, and restores the jumplist so `<C-o>` returns
-- to the call site.
local function select_same_buffer(prompt_bufnr, picker, win)
    -- close the picker ourselves, without telescope's :edit
    local entry = action_state.get_selected_entry()
    require("telescope.pickers").on_close_prompt(prompt_bufnr)
    if not vim.api.nvim_win_is_valid(win) then
        return
    end
    -- focus the window we jumped from
    pcall(vim.api.nvim_set_current_win, win)

    -- emulate the jumplist/tagstack push that :edit would have done
    if picker.push_cursor_on_edit then
        vim.cmd "normal! m'"
    end
    if picker.push_tagstack_on_edit then
        local from = { vim.fn.bufnr "%", vim.fn.line ".", vim.fn.col ".", 0 }
        local items = { { tagname = vim.fn.expand "<cword>", from = from } }
        vim.fn.settagstack(vim.fn.win_getid(), { items = items }, "t")
    end

    -- jump to the target line (G pushes the call site onto the jumplist)
    local row = (entry.row or entry.lnum) or vim.fn.line(".")
    local col = entry.col or vim.fn.col(".")
    pcall(function() vim.cmd("normal! " .. row .. "G") end)

    -- telescope's col is 1-based and points at the start of the token;
    -- land on the identifier, skipping a leading `.` / `::`
    local line = vim.api.nvim_get_current_line()
    while col < #line do
        local ch = line:sub(col, col)
        if ch ~= "." and ch ~= ":" then break end
        col = col + 1
    end
    vim.api.nvim_win_set_cursor(0, { row, col })
end

-- True if the selected entry refers to a file already open in `win`.
-- Uses bufnr when available, falls back to resolved path (e.g. rust-analyzer
-- references which have no bufnr).
local function entry_in_same_window(entry, win)
    if not entry or not vim.api.nvim_win_is_valid(win) then
        return false
    end
    local wbuf = vim.api.nvim_win_get_buf(win)
    -- fast path: compare buffer ids
    if entry.bufnr and entry.bufnr > 0 then
        return entry.bufnr == wbuf
    end
    -- fallback: some pickers (rust-analyzer refs) give a path, not a bufnr
    local fname = entry.filename or entry.path
    if not fname or fname == "" then
        return false
    end
    local cur = vim.api.nvim_buf_get_name(wbuf)
    if cur == "" then return false end
    -- compare resolved real paths so symlinks don't fool us
    local resolve = function(p)
        return vim.uv.fs_realpath(p) or p
    end
    return resolve(fname) == resolve(cur)
end

-- Selection handler for telescope entries. Same-buffer entries jump via
-- select_same_buffer; everything else uses telescope's normal select.
-- Afterwards, center the window if the target landed outside the viewport
-- that was visible before the picker opened.
local function select_and_center(prompt_bufnr, how)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local win = picker.original_win_id
    local entry = action_state.get_selected_entry()
    -- snapshot the viewport before the jump so we can tell off-screen targets
    local top = vim.fn.line("w0", win)
    local bot = vim.fn.line("w$", win)

    -- same-buffer: jump without re-reading the file; otherwise let telescope do it
    if how == "default" and entry_in_same_window(entry, win) then
        select_same_buffer(prompt_bufnr, picker, win)
    else
        -- this would center the window after the jump, but we want to center only if the target was off-screen
        action_set.select(prompt_bufnr, how)
    end

    -- center only if the target was outside the pre-picker viewport
    require("mattes.center").maybe_center(top, bot)
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
