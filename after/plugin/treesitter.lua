require('nvim-treesitter.install').install({
    "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "rust", "groovy", "java"
})

require("treesitter-context").setup({
    multiline_threshold = 1,
    trim_scope = 'inner',
    multiwindow = true,
})
