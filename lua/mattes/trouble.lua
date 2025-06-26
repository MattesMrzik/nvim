local M = {}

function M.toggle_diagnostics_and_focus_its_window()
  vim.cmd("Trouble diagnostics toggle")

  -- Then focus the Trouble window after a short delay
  vim.defer_fn(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
      if ft == "trouble" then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
  end, 50)
end

return M
