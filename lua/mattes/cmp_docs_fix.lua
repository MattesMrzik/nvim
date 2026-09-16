-- this is a fix for https://github.com/hrsh7th/nvim-cmp/issues/2232
local cev = require("cmp.view.custom_entries_view")
local orig_info = cev.info

cev.info = function(self)
    local info = orig_info(self)
    local w = self.entries_win.win
    if w and vim.api.nvim_win_is_valid(w) then
        local pos = vim.api.nvim_win_get_position(w)
        info.row, info.col = pos[1], pos[2]
    end
    return info
end

