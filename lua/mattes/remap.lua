vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
vim.keymap.set("v", "cc", '"+y')
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next({ float = false }) end)
vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev({ float = false }) end)
