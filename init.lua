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

-- maybe remove this line, i am not sure what it does
vim.lsp.inlay_hint.enable(true)


vim.cmd('hi Normal guibg=NONE ctermbg=NONE | hi NormalNC guibg=NONE ctermbg=NONE | hi EndOfBuffer guibg=NONE ctermbg=NONE | hi VertSplit guibg=NONE ctermbg=NONE')

--vim.cmd("syntax on")
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
vim.opt.spelloptions:append("camel")
vim.opt.spellcapcheck = ""
vim.opt.spelloptions = { "camel" }


vim.api.nvim_set_hl(0, "SpellBad", {
  underline = true,
  sp = "#b06320",  -- color of squiggly underline
})
vim.api.nvim_set_hl(0, "SpellLocal", {
  underline = true,
  sp = "#b06320",  -- color of squiggly underline
})
vim.api.nvim_set_hl(0, "SpellCap", {
  underline = true,
  sp = "#b06320",  -- color of squiggly underline
})
vim.api.nvim_set_hl(0, "SpellRare", {
  underline = true,
  sp = "#b06320",  -- color of squiggly underline
})
