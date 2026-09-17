local M = {}

function M.maybe_center(top, bottom)
    if not top or not bottom or top >= bottom then
        return
    end
    local line = vim.fn.line(".")
    if line < top or line > bottom then
        vim.cmd("normal! zz")
    end
end

return M