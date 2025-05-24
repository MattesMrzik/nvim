local map = vim.keymap.set

map('n', '<leader>jo', ':DiffviewOpen<CR>', { desc = 'Diffview Open' })
map('n', '<leader>jc', ':DiffviewClose<CR>', { desc = 'Diffview Close' })

map('n', '<leader>jj', function()
  local view = require('diffview.lib').get_current_view()
  if view then
    vim.cmd('DiffviewClose')
  else
    vim.cmd('DiffviewOpen')
  end
end, { desc = 'Diffview Toggle' })
