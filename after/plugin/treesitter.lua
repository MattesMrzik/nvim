-- tree-sitter CLI installed via conda:
--   /cfs/earth/scratch/mrzi/software/conda/install_location/bin/conda install -c conda-forge tree-sitter-cli
-- Symlinked to ~/.local/bin/tree-sitter
require('nvim-treesitter.install').install({
    "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "rust", "groovy", "java"
})

require("treesitter-context").setup({
    multiline_threshold = 1,
    trim_scope = 'inner',
    multiwindow = true,
})
