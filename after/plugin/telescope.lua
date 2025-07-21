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
            --horizontal = {width = {padding = 0}, height = {padding = 0}}
            horizontal = {width = 0.9, height = 0.9}
        },
    },
  })
