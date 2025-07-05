-- useful hotkeys
-- K -> hover lsp info

-- basic
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
vim.keymap.set("v", "cc", '"+y')
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>th", require("mattes.color").my_toggle_theme, {desc = "Toggle theme"})

-- diagnostics
vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next({ float = false }) end)
vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev({ float = false }) end)

-- trouble
vim.keymap.set("n", "<leader>ww", require("mattes.trouble").toggle_diagnostics_and_focus_its_window, { desc = "Toggles and focuses trouble window"})

-- undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git);

-- lsp
vim.keymap.set("n", "<leader>gt", require("mattes.rust").jump_to_trait, { desc = "Go to trait definition from impl" })
vim.keymap.set('n', '<leader>im', require('telescope.builtin').lsp_implementations, { desc = 'LSP Implementations' })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
vim.keymap.set("n", "<leader>ih", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, {desc = "toggle inlay_hints"})
vim.api.nvim_set_keymap('n', '<leader>,', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })

-- cmp
-- see rust.lua

-- gitsigns
-- see gitsigns.lua

-- diagnostics
vim.keymap.set("n", "<leader>d", require("mattes.diagnostics").toggle_diagnostics, { desc = "Toggles diagnostics"} )
vim.keymap.set("n", "<leader>nd", require("mattes.diagnostics").disable_diagnostics, { desc = "Turns off diagnostics"})

-- telescope
local builtin = require('telescope.builtin')
local cs = require("mattes.custom_telescope_functions")
vim.keymap.set('n', '<leader>ff', function() cs.dynamic_picker(builtin.find_files)end, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Telescope find files' })
-- vim.keymap.set("n", "<leader>ws", require("telescope.builtin").lsp_workspace_symbols, { desc = "Workspace Symbols" })
vim.keymap.set('n', '<leader>fs', function() builtin.grep_string({ search = vim.fn.input("Grep > ") }); end)
vim.keymap.set("n", "<leader>ss", function()
  local fname = vim.api.nvim_buf_get_name(0)
  --vim.cmd("write")
  if fname:sub(-3) == ".rs" then
      cs.custom_lsp_document_symbols()
  else
    require("telescope.builtin").lsp_document_symbols()
  end
end, { desc = "Search symbols in current file" })
vim.keymap.set("n", "<leader>im", function()
    local fname = vim.api.nvim_buf_get_name(0)
    if fname:sub(-3) == ".rs" then
        cs.custom_lsp_implementations()
    else
        require("telescope.builtin").lsp_implementations()
    end
end, {desc = "Search implementations"})
--vim.keymap.set('n', '<C-[>', '<cmd>Telescope lsp_references<CR>', { desc = "Search symbols in current file" })
--vim.keymap.set("n", "<C-[>", function()
vim.keymap.set("n", "<leader>k", function()
    local fname = vim.api.nvim_buf_get_name(0)
    if fname:sub(-3) == ".rs" then
        cs.custom_lsp_references()
    else
        require("telescope.builtin").lsp_references()
    end
end, {desc = "Search references"})
vim.keymap.set("n", "<leader>ws", function() cs.custom_workspace_symbols() end, {desc =  "custom Workspace symbols"})

-- DiffView
vim.keymap.set("n", "<leader>jj", require("mattes.diffview").toggle_diff_view, { desc = "Toggles diffview"})
vim.keymap.set("n", "<leader>m", require("mattes.diffview").jump_between_right_file_and_file_over_view_pane, { desc = "Jump between overview and right pane"})
vim.keymap.set("n", "<leader>fh", function() vim.cmd("DiffviewFileHistory %")end, {desc = "Shows the git file history"})
