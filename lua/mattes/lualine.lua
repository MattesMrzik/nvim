local custom_powerline = require('lualine.themes.powerline')
--custom_powerline.normal.c.bg = "NONE
--normal
custom_powerline.normal.b.bg = "#384c00"
custom_powerline.normal.c.bg = "#0f1600"
custom_powerline.normal.x = custom_powerline.normal.x or {}
custom_powerline.normal.x.bg = "#384c00"

-- insert
custom_powerline.insert.a.bg = "#54c1dd"
custom_powerline.insert.b.bg = "#123456"

-- visual
custom_powerline.visual = custom_powerline.visual or {}
custom_powerline.visual.b = custom_powerline.visual.b or {}
custom_powerline.visual.c = custom_powerline.visual.c or {}
custom_powerline.visual.b.bg = "#673200"
custom_powerline.visual.c.bg = "#180c00"

-- command
custom_powerline.command = custom_powerline.command or {}
custom_powerline.command.a = custom_powerline.command.a or {}
custom_powerline.command.a.bg = "#d73200"
custom_powerline.command.a.fg = "#000000"
custom_powerline.command.b = custom_powerline.command.b or {}
custom_powerline.command.c = custom_powerline.command.c or {}
custom_powerline.command.b.bg = "#a73200"
custom_powerline.command.c.bg = "#a80c00"

local function set_fg(theme, sectionbcolor,sectionccolor)
    -- insert
    theme.insert.b.fg = sectionbcolor
    theme.insert.c.fg = sectionccolor
    --theme.insert.y = theme.insert.y or {}
    --theme.insert.y.fg = sectionbcolor
    --theme.insert.x = theme.insert.x or {}
    --theme.insert.x.fg = sectionccolor
    -- normal
    theme.normal.b.fg = sectionbcolor
    theme.normal.c.fg = sectionccolor
    --theme.normal.y = theme.normal.y or {}
    --theme.normal.y.fg = sectionbcolor
    --theme.normal.x = theme.normal.x or {}
    --theme.normal.x.fg = sectionccolor
    -- visual
    theme.visual.b = theme.visual.b or {}
    theme.visual.b.fg = sectionbcolor
    theme.visual.c = theme.visual.c or {}
    theme.visual.c.fg = sectionccolor
    --theme.visual.y = theme.visual.y or {}
    --theme.visual.y.fg = sectionbcolor
    --theme.visual.x = theme.visual.x or {}
    --theme.visual.x.fg = sectionccolor
end
set_fg(custom_powerline, "#c4c9c5", "#9e9e9e")

require('lualine').setup({
    options = {
        theme = custom_powerline,
        disabled_filetypes = {
            'nofile',
        }
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
    },
})
