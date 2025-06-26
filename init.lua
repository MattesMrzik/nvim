vim.g.python3_host_prog =  "/Users/mrzi/.config/nvim/python_env/bin/python3"
require("mattes")

-- basic settings
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.cursorline = true
vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.expandtab = true
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
vim.o.signcolumn = "yes:2"

-- advanced settings

-- flickering fixed, see https://github.com/neovim/neovim/issues/32660
vim.g._ts_force_sync_parsing = true

-- lsp
-- rust lsp in in separate rust.lua file
require'lspconfig'.lua_ls.setup{}
-- disable lsp references on esc press
vim.api.nvim_create_autocmd("LspAttach", {
  once = true,
  callback = function()
    pcall(vim.keymap.del, "n", "<Esc>")
  end,
})

