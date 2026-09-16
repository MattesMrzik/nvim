vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python", "lua", "rust", "cpp", "groovy", "java" },
    callback = function()
        pcall(vim.treesitter.start, 0)
    end,
})
