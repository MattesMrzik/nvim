local custom_powerline = require('lualine.themes.powerline')
--custom_powerline.normal.c.bg = "NONE"
custom_powerline.normal.b.bg = "#384c00"
custom_powerline.normal.c.bg = "#0f1600"

-- Insert mode
custom_powerline.insert.a.bg = "#54c1dd"
custom_powerline.insert.b.bg = "#123456"  -- change to your desired color

custom_powerline.insert.c.bg = "#234567"  -- change to your desired color

-- Visual mode
custom_powerline.visual = custom_powerline.visual or {}  -- create if missing
custom_powerline.visual.b = custom_powerline.visual.b or {}  -- create if missing
custom_powerline.visual.b.bg = "#673200"
custom_powerline.visual.c = custom_powerline.visual.c or {}  -- create if missing
custom_powerline.visual.c.bg = "#180c00"

-- maybe i want the c to be dark for one mode and bright for another

require('lualine').setup({
    options = {
        theme = custom_powerline,
    },
    sections = {
        lualine_c = {
            --{ 'filename', path = 1, color = {bg = "#303030", fg = '#9e9e9e'}}
            { 'filename', path = 1,}
        },
        lualine_x = {},
    },
    inactive_sections = {
        lualine_c = {
            { 'filename', path = 1},
    },
}
})
