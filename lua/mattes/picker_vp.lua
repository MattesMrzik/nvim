local M = {}

local session = nil

function M.before_picker()
    local win = vim.fn.win_getid()
    session = {
        win = win,
        top = vim.fn.line("w0", win),
        bottom = vim.fn.line("w$", win),
    }
end

function M.settle(win)
    if not session then
        return
    end
    local s = session
    session = nil

    local line = vim.fn.line(".")
    local col = vim.fn.col(".")

    if line >= s.top and line <= s.bottom then
        if vim.api.nvim_win_is_valid(s.win) then
            vim.api.nvim_win_call(s.win, function()
                vim.fn.cursor(s.top, 1)
                vim.cmd("normal! zt")
            end)
            vim.api.nvim_win_set_cursor(s.win, { line, col })
        end
    else
        vim.cmd("normal! zz")
    end
end

return M