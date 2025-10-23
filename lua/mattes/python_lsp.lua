vim.lsp.config("pyright", {
  on_attach = function(client, bufnr)
    -- Optional: keybindings, formatting settings, etc.
    local opts = { noremap = true, silent = true, buffer = bufnr }
    -- You can define buffer-local keymaps here if needed
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly", -- or "workspace"
        typeCheckingMode = "basic",       -- or "strict"
      },
    },
  },
})

-- Enable the server for its filetypes
vim.lsp.enable("pyright")

