-- close on first esc not second
local actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
                ["<CR>"] = actions.select_default + actions.center,
                ["<C-x>"] = actions.select_horizontal + actions.center,
                ["<C-v>"] = actions.select_vertical + actions.center,
            },
            n = {
                ["<CR>"] = actions.select_default + actions.center,
                ["<C-x>"] = actions.select_horizontal + actions.center,
                ["<C-v>"] = actions.select_vertical + actions.center,
                -- ["<C-t>"] = actions.goto_file_selection_tab + actions.center,
            },
        },
        layout_config = {
            --horizontal = {width = {padding = 0}, height = {padding = 0}}
            horizontal = { width = 0.9, height = 0.9 },
        },
    },
})
-- show line numbers in previewer
vim.cmd([[autocmd User TelescopePreviewerLoaded setlocal number]])
