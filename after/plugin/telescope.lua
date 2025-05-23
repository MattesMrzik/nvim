local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fs', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
vim.keymap.set('n', '<leader>ss', '<cmd>Telescope lsp_document_symbols<CR>', { desc = "Search symbols in current file" })
vim.keymap.set('n', '<C-[>', '<cmd>Telescope lsp_references<CR>', { desc = "Search symbols in current file" })


local actions = require("telescope.actions")

-- close on first esc not second
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
    },
})

