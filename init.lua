-- Neovim’s Python provider, not for the lsp
local home = vim.fn.expand("~")
if home == "/Users/mrzi" then
    vim.g.python3_host_prog = "/Users/mrzi/.config/nvim/python_env/bin/python3"
elseif home == "/net/home/mrzi" then
    vim.g.python3_host_prog = "/cfs/earth/scratch/mrzi/software/conda/install_location/bin/python3"
else
    vim.g.python3_host_prog = vim.fn.exepath("python3")
end


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
vim.opt.splitright = true -- ctrl + v on selected item in telescope
vim.opt.splitbelow = true -- ctrl + x on selected item in telescope

-- flickering fixed, see https://github.com/neovim/neovim/issues/32660
--vim.g._ts_force_sync_parsing = true

-- disable lsp references on esc press
vim.api.nvim_create_autocmd("LspAttach", {
    once = true,
    callback = function()
        pcall(vim.keymap.del, "n", "<Esc>")
    end,
})
