vim.g.python3_host_prog =  "/Users/mrzi/.config/nvim/python_env/bin/python3"
require("mattes")
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',  -- could also use '■', '▶', '>>'
    spacing = 2,
    severity = { min = vim.diagnostic.severity.WARN },
  }
})
vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.expandtab = true

