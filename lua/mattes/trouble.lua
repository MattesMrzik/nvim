--vim.keymap.set("n", "<leader>ww", "<cmd>Trouble diagnostics toggle<cr>")
vim.keymap.set("n", "<leader>ww", function()
  -- Call the command just like you had it
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
end, { desc = "Trouble diagnostics toggle + focus" })

