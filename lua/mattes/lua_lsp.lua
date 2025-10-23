vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      diagnostics = {
        globals = { "vim" },  -- <- must be here
      },
    },
  },
})

-- Enable the server
vim.lsp.enable("lua_ls")

