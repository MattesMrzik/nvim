local wrap_or_not = 1

local M = {}
function M.toggle_line_wrap()
    wrap_or_not = (wrap_or_not + 1) % 2
    if wrap_or_not == 1 then
        vim.notify("Line Wrap Enabled")
        vim.cmd("set wrap")
    else
        vim.notify("Line Wrap Disabled")
        vim.cmd("set wrap!")
    end
end

return M
