local diagnostics_type = 0

vim.diagnostic.config({
    virtual_lines = false,
    virtual_text = false, -- optional: hide virtual_text when lines are on
})
local function wrap_diagnostic(msg, max_width)
    local lines = {}
    for s in msg:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end
    local out_lines = {}
    for _, line in ipairs(lines) do
        local i = 1
        while i <= #line do
            local chunk = line:sub(i, i + max_width - 1)
            table.insert(out_lines, chunk)
            i = i + max_width
        end
    end
    return table.concat(out_lines, "\n")
end
local function get_min_win_size(bufnr)
    local m = 9999 
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        print("w =", w)
        local buf_of_window = vim.api.nvim_win_get_buf(w)
        print("buf of window = ", buf_of_window)
        if buf_of_window == bufnr then
            local win_size = vim.api.nvim_win_get_width(w)
            if win_size < m then
                m = win_size
            end
        end
    end
    return m-12
end

vim.keymap.set("n", "<leader>dd", function()
    diagnostics_type = (diagnostics_type + 1) % 2
    local virtual_lines_enabled = false
    local virtual_text_enabled = false
    if diagnostics_type == 1 then
        vim.diagnostic.config({
            --virtual_text = virtual_text_enabled, -- optional: hide virtual_text when lines are on
            virtual_lines = {
                only_current_line = false,
                severity = nil,
                format = function(diagnostic)
                    local min_size = get_min_win_size(diagnostic.bufnr)
                    local remaining_width = min_size - diagnostic.col
                    return wrap_diagnostic(diagnostic.message, remaining_width)
                end,
            }
        })
    else 
        vim.diagnostic.config({virtual_lines = false})
    end

end, { desc = "Toggle virtual lines" })
