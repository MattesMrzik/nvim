if vim.fn.expand("~") == "/Users/mrzi" then
    -- local: lua-language-server available via homebrew
else
    -- lua-language-server is installed manually in the software dir (HPC only)
    vim.env.PATH = "/cfs/earth/scratch/mrzi/software/lua-language-server/bin:" .. vim.env.PATH
end

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
