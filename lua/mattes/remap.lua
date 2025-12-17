-- basic
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", function() Snacks.explorer() end)
vim.keymap.set("v", "cc", '"+y')
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>th", require("mattes.color").my_toggle_theme, { desc = "Toggle theme" })
vim.keymap.set("n", "<C-j>", "<C-e>", { noremap = true, desc = "Scroll view down" })
vim.keymap.set("n", "<C-k>", "<C-y>", { noremap = true, desc = "Scroll view up" })
vim.keymap.set("n", "*", [[:let @/='\<<C-R><C-W>\>'<CR>:set hlsearch<CR>]], { noremap = true, silent = true }) -- highlight without jumping
vim.keymap.set("n", "#", [[:let @/='\<<C-R><C-W>\>'<CR>:set hlsearch<CR>]], { noremap = true, silent = true })
vim.keymap.set("n", "=", [[<cmd>vertical resize +5<cr>]])                                                      -- make the window biger vertically
vim.keymap.set("n", "+", [[<cmd>vertical resize -5<cr>]])                                                      -- make the window smaller vertically
vim.keymap.set("n", "-", [[<cmd>horizontal resize +2<cr>]])                                                    -- make the window bigger horizontally by pressing shift and =
vim.keymap.set("n", "_", [[<cmd>horizontal resize -2<cr>]])                                                    -- make the window smaller horizontally by pressing shift and -
vim.keymap.set("n", "<leader>gf", function()
    local text = vim.fn.expand("<cfile>")
    print(text)
    local file, line = text:match("([^:]+):(%d+)")
    print("File: " .. file .. ", Line: " .. line)
    if file and line then
        vim.cmd("edit " .. file)
        vim.cmd(line)
    else
        print("No valid file:line under cursor")
    end
end, { desc = "Go to file:line under cursor" })

-- snacks
vim.keymap.set("n", "<leader>ch",
    function() Snacks.picker.command_history({ layout = { preset = "dropdown", preview = false } }) end,
    { desc = "Snacks command history picker" })
vim.keymap.set("n", "<leader>sp",
    function() Snacks.picker.spelling({ layout = { preset = "select", preview = false } }) end)
vim.keymap.set("n", "<leader>/", function() Snacks.picker.lines() end)
vim.keymap.set("n", "<leader>fa", function()
    local cursor_line = vim.fn.winline()
    local total_lines = vim.api.nvim_win_get_height(0)
    local is_bottom = cursor_line > total_lines / 2

    local row = 0
    if not is_bottom then
        row = total_lines - math.floor(total_lines * 0.47)
    end
    Snacks.picker.grep({
        layout = {
            layout = {
                width = 0.99,
                height = 0.47,
                box = "horizontal",
                position = "float",
                col = vim.api.nvim_win_get_width(0) * (1 - 0.99) / 2,
                row = row,
            },
        }
    }
    )
end)
vim.keymap.set("n", "<leader>fb", function() Snacks.picker.buffers() end)
vim.keymap.set("n", "<leader>fn", function() Snacks.picker.notifications() end)
vim.keymap.set("n", "<leader>sn", function() Snacks.picker.snippets() end, { desc = "Snacks snippets picker" })
vim.keymap.set("n", "<leader>ww", function() Snacks.picker.diagnostics() end,
    { desc = "Toggles and focuses trouble window" })

-- copilot
vim.keymap.set("n", "<leader>cp", function() require("CopilotChat").toggle() end, { desc = "Toggle Copilot Chat" })
vim.keymap.set('i', '<C-L>', '<Plug>(copilot-accept-word)')
local copilot_enabled = true

vim.keymap.set("n", "<leader>ct", function()
    if copilot_enabled then
        vim.cmd("Copilot disable")
        vim.notify("Copilot disabled", vim.log.levels.INFO)
    else
        vim.cmd("Copilot enable")
        vim.notify("Copilot enabled", vim.log.levels.INFO)
    end
    copilot_enabled = not copilot_enabled
end, { desc = "Toggle Copilot", silent = true })

-- diagnostics
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = false }) end)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = false }) end)

-- trouble

-- undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git);

-- lsp
local lspM = require("mattes.rust")
vim.keymap.set("n", "<leader>gt", lspM.jump_to_trait, { desc = "Go to trait definition from impl" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
vim.keymap.set("n", "<leader>ih", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
    { desc = "toggle inlay_hints" })
vim.api.nvim_set_keymap('n', '<leader>,', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, { desc = "LSP Hover" })
-- this might cause to give a different namespace to the diagnostics, so that snacks does not see the diagnostics
vim.keymap.set("n", "<leader>cf", function() lspM:toggle_features() end)

local function test()
    vim.notify("test funtion")
end

vim.keymap.set("n", "<leader>test", function()
    test()
end, { desc = "Run cargo test for current project" })

-- cmp
-- see rust.lua

-- gitsigns
-- see gitsigns.lua

-- diagnostics
vim.keymap.set("n", "<leader>d", require("mattes.diagnostics").toggle_diagnostics, { desc = "Toggles diagnostics" })
vim.keymap.set("n", "<leader>nd", require("mattes.diagnostics").disable_diagnostics, { desc = "Turns off diagnostics" })

-- telescope
local builtin = require('telescope.builtin')
local cs = require("mattes.custom_telescope_functions")
vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>ff', function() cs.dynamic_picker(builtin.find_files) end, { desc = 'Telescope find files' })
-- vim.keymap.set("n", "<leader>ws", require("telescope.builtin").lsp_workspace_symbols, { desc = "Workspace Symbols" })
--vim.keymap.set('n', '<leader>fs', function()
--    local search = vim.fn.input("Grep > ")
--    builtin.grep_string({ search = search , layout_config = cs.dynamic_layout_config(), results_title = "", preview_title = ""})
--end, {desc = "Search with grep"})
vim.keymap.set("n", "<leader>fs", function()
    vim.ui.input({ prompt = "Enter your input: " }, function(input)
        if input ~= nil then
            cs.two_column_grep_string({ search = input })
        end
    end)
end, { desc = "Search with grep" })

vim.keymap.set("n", "<leader>ss", function()
    local fname = vim.api.nvim_buf_get_name(0)
    --vim.cmd("write")
    if fname:sub(-3) == ".rs" then
        cs.custom_lsp_document_symbols()
    else
        require("telescope.builtin").lsp_document_symbols()
    end
end, { desc = "Search symbols in current file" })
-- this is just the same as >im, because i sometime mistype it
vim.keymap.set("n", "<leader>in", function()
    local fname = vim.api.nvim_buf_get_name(0)
    if fname:sub(-3) == ".rs" then
        cs.custom_lsp_implementations()
    else
        require("telescope.builtin").lsp_implementations()
    end
end)
vim.keymap.set("n", "<leader>im", function()
    local fname = vim.api.nvim_buf_get_name(0)
    if fname:sub(-3) == ".rs" then
        cs.custom_lsp_implementations()
    else
        require("telescope.builtin").lsp_implementations()
    end
end)
--vim.keymap.set('n', '<C-[>', '<cmd>Telescope lsp_references<CR>', { desc = "Search symbols in current file" })
--vim.keymap.set("n", "<C-[>", function()
vim.keymap.set("n", "<leader>k", function()
    local fname = vim.api.nvim_buf_get_name(0)
    if fname:sub(-3) == ".rs" then
        cs.custom_lsp_references()
    else
        require("telescope.builtin").lsp_references()
    end
end, { desc = "Search references" })
-- // make this call the normal snacks picker if not in rust project (rust lsp)
vim.keymap.set("n", "<leader>ws", function() cs.custom_workspace_symbols() end, { desc = "custom Workspace symbols" })
vim.keymap.set("n", "<leader>pp", function() cs.workspace_2() end, { desc = "Telescope dynamic workspace symbols" })

-- DiffView
vim.keymap.set("n", "<leader>jj", require("mattes.diffview").toggle_diff_view, { desc = "Toggles diffview" })
vim.keymap.set("n", "<leader>m", require("mattes.diffview").jump_between_right_file_and_file_over_view_pane,
    { desc = "Jump between overview and right pane" })
vim.keymap.set("n", "<leader>fh", function() vim.cmd("DiffviewFileHistory %") end,
    { desc = "Shows the git file history" })
