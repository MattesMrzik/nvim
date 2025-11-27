vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
                checkThirdParty = false,
                library = { vim.env.VIMRUNTIME },
            },
            diagnostics = {
                globals = { "vim", "Snacks" },
            },
        },
    },
})

-- Enable the server
vim.lsp.enable("lua_ls")

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.lua",
    callback = function()
        vim.lsp.buf.format({
            async = false,
            filter = function(client) return client.name == "lua_ls" end,
        })
    end,
})
