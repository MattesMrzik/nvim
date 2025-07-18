-- close on first esc not second
local actions = require("telescope.actions")
local function custom_ui_select_theme()
  local width = 0.4
  local height = 0.4 
  --local height = math.floor(vim.o.lines * 0.3)
  --local height = math.floor(vim.o.lines * 0.3)
  return {
    width = width,
    height = height,
    previewer = false,
    prompt_title = false,
  }
end
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
        layout_config = {
            horizontal = {width = {padding = 0}, height = {padding = 0}}
            --horizontal = {width = 0.9, height = 0.9}
        },
    },
    extensions = {
        ["ui-select"] = {
            custom_ui_select_theme()
        }
    }
})
require("telescope").load_extension("ui-select")
