local diagnostics_type = 0

vim.diagnostic.config({
    virtual_lines = false,
    virtual_text = true,
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
        local buf_of_window = vim.api.nvim_win_get_buf(w)
        if buf_of_window == bufnr then
            local win_size = vim.api.nvim_win_get_width(w)
            if win_size < m then
                m = win_size
            end
        end
    end
    return m-12
end

local function get_inlay_width(bufnr, line)
    local inlay_ns = vim.api.nvim_get_namespaces()["nvim.lsp.inlayhint"]
    if not inlay_ns then return 0 end

    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, inlay_ns, {line, 0}, {line, -1}, {details = true})
    local total_width = 0

    for _, mark in ipairs(extmarks) do
        local virt_text = mark[4] and mark[4].virt_text
        if virt_text then
            for _, chunk in ipairs(virt_text) do
                local text = chunk[1]
                total_width = total_width + vim.fn.strdisplaywidth(text)
            end
        end
    end

    return total_width +2
end

vim.keymap.set("n", "<leader>zz", function()
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
                    return wrap_diagnostic("vir col = " .. get_inlay_width(diagnostic.bufnr, diagnostic.lnum) .. ", min win size = " .. min_size .. ", col of warn = " .. diagnostic.col .. ", msg:\n" .. diagnostic.message, remaining_width)
                end,
            }
        })
    else 
        vim.diagnostic.config({virtual_lines = false})
    end
end, {desc = "Toggle virtual_lines debug"})

vim.keymap.set("n", "<leader>d", function()
    diagnostics_type = (diagnostics_type + 1) %2
    local virtual_lines_enabled = false
    local virtual_text_enabled = false
    if diagnostics_type == 1 then
        vim.diagnostic.config({
            virtual_text = false,
            virtual_lines = {
                only_current_line = false,
                severity = nil,
                format = function(diagnostic)
                    local min_size = get_min_win_size(diagnostic.bufnr)
                    local inlayhint = get_inlay_width(diagnostic.bufnr, diagnostic.lnum)
                    local remaining_width = min_size - diagnostic.col - inlayhint
                    return wrap_diagnostic(diagnostic.message, remaining_width)
                end,
            }
        })
    else
        vim.diagnostic.config({
            virtual_text = true,
            virtual_lines= false,
        })
    --else
     --vim.diagnostic.config({virtual_lines = false})
    end

end, { desc = "Toggle virtual lines" })
