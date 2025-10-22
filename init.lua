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
--vim.g._ts_force_sync_parsing = true

-- lsp
-- rust lsp in separate rust.lua file
-- lua lsp in lua_lsp.lua file
-- python lsp
require"lspconfig".pyright.setup({
    on_attach = function(client, bufnr)
        -- Optional: keybindings, formatting settings etc.
        local opts = { noremap=true, silent=true, buffer=bufnr }
    end,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly", -- or "workspace"
                typeCheckingMode = "basic", -- or "strict"
            }
        }
    }
})
-- disable lsp references on esc press
vim.api.nvim_create_autocmd("LspAttach", {
  once = true,
  callback = function()
    pcall(vim.keymap.del, "n", "<Esc>")
  end,
})
