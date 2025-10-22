require('lspconfig').lua_ls.setup {
  on_init = function(client)
    -- Ensure settings table exists
    client.config.settings = client.config.settings or {}
    client.config.settings.Lua = vim.tbl_deep_extend('force',
      client.config.settings.Lua or {},
      {
        runtime = { version = 'LuaJIT' },
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME },
        },
      }
    )

    print("Lua Language Server initialized with custom settings.")
    -- Notify the server that settings changed
    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  end,
}

