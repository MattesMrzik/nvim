local del_qf_item = function()
    local items = vim.fn.getqflist()
    local line = vim.fn.line('.')
    table.remove(items, line)
    vim.fn.setqflist(items, "r")
    if #items == 0 then
        -- close quickfix window if empty
        vim.cmd.cclose()
    else
        -- clamp cursor to last line if needed
        local new_line = math.min(line, #items)
        vim.api.nvim_win_set_cursor(0, { new_line, 0 })
    end
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf", -- quickfix
    callback = function()
        vim.keymap.set("n", "dd", function()
            del_qf_item()
        end, { buffer = true, silent = true, desc = "Delete current QF entry" })
        vim.api.nvim_set_hl(0, "BqfPreviewCursorLine", { bg = "NONE" })
    end,
})
