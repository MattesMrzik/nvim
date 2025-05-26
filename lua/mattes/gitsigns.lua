require('gitsigns').setup{
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
        vim.cmd('normal! zz')
      end
    end)

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
        vim.cmd('normal! zz')
      end
    end)

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk)
    map('n', '<leader>hr', gitsigns.reset_hunk)

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('v', '<leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('n', '<leader>hS', gitsigns.stage_buffer)
    map('n', '<leader>hR', gitsigns.reset_buffer)
    map('n', '<leader>hp', gitsigns.preview_hunk)
    map('n', '<leader>hi', gitsigns.preview_hunk_inline)

    map('n', '<leader>hb', function()
      gitsigns.blame_line({ full = true })
    end)

    map('n', '<leader>hd', gitsigns.diffthis)

    map('n', '<leader>hD', function()
      gitsigns.diffthis('~')
    end)

    map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
    map('n', '<leader>hq', gitsigns.setqflist)

    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
    map('n', '<leader>tw', gitsigns.toggle_word_diff)

    -- Text object
    map({'o', 'x'}, 'ih', gitsigns.select_hunk)
  end
}



local function myf(file, line, debug)
  local abs = vim.fn.fnamemodify(file, ':p')
  local bufnr = vim.fn.bufnr(abs, true)

  -- Save original window
  local orig_win = vim.api.nvim_get_current_win()

  -- Open temp window (horizontal or vertical depending on debug)
  if debug then
    vim.cmd('silent! topleft new')  -- horizontal, full width
  else
    vim.cmd('silent! topleft vnew') -- vertical, narrow
  end

  local temp_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(temp_win, bufnr)
  vim.api.nvim_win_set_cursor(temp_win, { line, 0 })

  -- Call Gitsigns stage_hunk as if cursor is on the hunk
  vim.cmd('Gitsigns stage_hunk')

  -- Close window if not debugging
  if not debug then
    vim.api.nvim_win_close(temp_win, true)
    vim.api.nvim_set_current_win(orig_win)
  end

  return true
end


vim.keymap.set('n', '<leader>kk', function()
  myf("lua/mattes/gitsigns.lua", 70)
end, { desc = "Stage hunk at line 70 in gitsigns.lua" })

local function get_diffview_file_and_line()
  local bufname = vim.api.nvim_buf_get_name(0)
  -- Extract the relative file path after the last colon
  print("bufname = ", bufname)
  local rel_path = bufname:match("/:.*:(/.*)$")
  print("rel_path = ", rel_path)
  if not rel_path then
    vim.notify("Could not extract file path from buffer name: " .. bufname, vim.log.levels.ERROR)
    return nil
  end
  -- Get the current line number
  local line = vim.api.nvim_win_get_cursor(0)[1]
  print(rel_path, line)
  return rel_path, line
end

vim.keymap.set('n', '<leader>ll', function()

    local path, line = get_diffview_file_and_line()
    myf(path, line)
end, { desc = "Stage hunk at line 70 in gitsigns.lua" })

-- make leader hs check if i am in diff view or not, if yes then call my funtion, else use the default stage hunk
-- if in diff view but file panel getting the buffer name throughs an error. i can say: warn: you are in file view and not file, use leader k to switch to file
