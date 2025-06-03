local builtin = require('telescope.builtin')
-- close on first esc not second
local actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
        layout_config = {
            horizontal = {width = {padding = 0}, height = {padding = 0}}
        },
    },
})

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fs', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
vim.keymap.set('n', '<C-[>', '<cmd>Telescope lsp_references<CR>', { desc = "Search symbols in current file" })
local cs = require("mattes.symbols_with_custom")
vim.keymap.set("n", "<leader>ss", function()
  local fname = vim.api.nvim_buf_get_name(0)
  --vim.cmd("write")
  if fname:sub(-3) == ".rs" then
      cs.custom_lsp_document_symbols()
  else
    require("telescope.builtin").lsp_document_symbols()
  end
end, { desc = "Search symbols in current file" })






