vim.g.python3_host_prog =  "/Users/mrzi/.config/nvim/python_env/bin/python3"
require("mattes")
--require("config.lazy")
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.cursorline = true

require'lspconfig'.lua_ls.setup{}
vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.expandtab = true
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }

-- https://github.com/neovim/neovim/issues/32660 because of flickering
vim.g._ts_force_sync_parsing = true


--vim.cmd('colorscheme rose-pine')
vim.o.signcolumn = "yes:2"

vim.lsp.inlay_hint.enable(true)

