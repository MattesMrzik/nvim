local M = {}

function M.maybe_center(top, bottom, buf, win)
    local should_center = false
    if win and vim.api.nvim_win_is_valid(win) then
        -- landed in a different window (split/tab selection) -> center
        if vim.api.nvim_get_current_win() ~= win then
            should_center = true
            -- buffer in the window changed -> old viewport is meaningless -> center
        elseif buf and vim.api.nvim_win_get_buf(win) ~= buf then
            should_center = true
            -- same buffer: center only if the target was outside the old viewport
        elseif top and bottom and top < bottom then
            local line = vim.fn.line(".")
            should_center = line < top or line > bottom
        end
    elseif top and bottom and top < bottom then
        -- no window given: plain viewport check on the current window
        local line = vim.fn.line(".")
        should_center = line < top or line > bottom
    end

    if should_center then
        vim.cmd("normal! zz")
    end
end

return M

