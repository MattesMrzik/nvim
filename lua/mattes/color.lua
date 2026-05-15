local telescope_border = "#525252"
require('kanagawa').setup({
    compile = false,  -- enable compiling the colorscheme
    undercurl = true, -- enable undercurls
    commentStyle = { italic = true },
    functionStyle = {},
    keywordStyle = { italic = true },
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = false,              -- do not set background color
    dimInactive = false,              -- dim inactive window `:h hl-NormalNC`
    terminalColors = true,            -- define vim.g.terminal_color_{0,17}
    -- https://github.com/rebelot/kanagawa.nvim/blob/debe91547d7fb1eef34ce26a5106f277fbfdd109/lua/kanagawa/themes.lua#L198
    colors = {                        -- add/modify theme and palette colors
        palette = {
            dragonBlack0 = "#0d0c0c", --#0d0c0c,
            dragonBlack1 = "#12120f", --#12120f
            dragonBlack2 = "#000000", --#1D1C19
            dragonBlack3 = "#000000", -- this is background
            dragonBlack4 = "#282727",
            dragonBlack5 = "#1f1e1c", --#393836 this is the current line highlight and maybe something else
            dragonBlack6 = "#625e5a",
            oldWhite = "#c4c9c5",
        },
        theme = {
            wave = {},
            lotus = {},
            dragon = {},
            all = {
                ui = {
                    bg_gutter = "none"
                }
            }
        },
    },
    overrides = function(colors)
        local theme = colors.theme
        return {
            TelescopeTitle = { fg = theme.ui.special, bold = true },
            TelescopePromptNormal = { bg = nil },
            TelescopePromptBorder = { fg = telescope_border, bg = nil },
            TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = nil },
            TelescopeResultsBorder = { fg = telescope_border, bg = nil },
            TelescopePreviewNormal = { bg = nil },
            TelescopePreviewBorder = { bg = nil, fg = telescope_border },
            Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
            PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },
        }
    end,
    theme = "dragon",
    background = {
        dark = "dragon",
        light = "lotus"
    },
})
vim.cmd("colorscheme kanagawa")

local function transparent_background()
    vim.cmd(
        'hi Normal guibg=NONE ctermbg=NONE | hi NormalNC guibg=NONE ctermbg=NONE | hi EndOfBuffer guibg=NONE ctermbg=NONE | hi VertSplit guibg=NONE ctermbg=NONE')
    vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "Grey" })
    vim.api.nvim_set_hl(0, "TreesitterContext", { bg = nil })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", fg = telescope_border })
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "BqfPreviewCursorLine", { bg = "NONE" }) -- see also quickfix_my.lua
end


local function spelling_underline()
    vim.api.nvim_set_hl(0, "SpellBad", {
        underline = true,
        sp = "#b06320",
    })
    vim.api.nvim_set_hl(0, "SpellLocal", {
        underline = true,
        sp = "#b06320",
    })
    vim.api.nvim_set_hl(0, "SpellCap", {
        underline = true,
        sp = "#b06320",
    })
    vim.api.nvim_set_hl(0, "SpellRare", {
        underline = true,
        sp = "#b06320",
    })
end

local function telescope_colors()
    vim.api.nvim_set_hl(0, "TelescopeSymbolText", { fg = "#f8f8f2" })          -- white
    vim.api.nvim_set_hl(0, "TelescopeSymbolMethod", { fg = "#50fa7b" })        -- green
    vim.api.nvim_set_hl(0, "TelescopeSymbolFunction", { fg = "#ffb86c" })      -- orange
    vim.api.nvim_set_hl(0, "TelescopeSymbolConstructor", { fg = "#ff79c6" })   -- pink
    vim.api.nvim_set_hl(0, "TelescopeSymbolField", { fg = "#8be9fd" })         -- cyan
    vim.api.nvim_set_hl(0, "TelescopeSymbolVariable", { fg = "#403e0b" })      -- yellow
    vim.api.nvim_set_hl(0, "TelescopeSymbolClass", { fg = "#8be9fd" })         -- cyan
    vim.api.nvim_set_hl(0, "TelescopeSymbolInterface", { fg = "#bd93f9" })     -- purple
    vim.api.nvim_set_hl(0, "TelescopeSymbolModule", { fg = "#ff79c6" })        -- pink
    vim.api.nvim_set_hl(0, "TelescopeSymbolProperty", { fg = "#66d9ef" })      -- light blue
    vim.api.nvim_set_hl(0, "TelescopeSymbolUnit", { fg = "#bd93f9" })          -- purple
    vim.api.nvim_set_hl(0, "TelescopeSymbolValue", { fg = "#f1fa8c" })         -- yellow
    vim.api.nvim_set_hl(0, "TelescopeSymbolEnum", { fg = "#ffb86c" })          -- orange
    vim.api.nvim_set_hl(0, "TelescopeSymbolKeyword", { fg = "#ff5555" })       -- red
    vim.api.nvim_set_hl(0, "TelescopeSymbolSnippet", { fg = "#f8f8f2" })       -- white
    vim.api.nvim_set_hl(0, "TelescopeSymbolColor", { fg = "#fab387" })         -- peach
    vim.api.nvim_set_hl(0, "TelescopeSymbolFile", { fg = "#f8f8f2" })          -- white
    vim.api.nvim_set_hl(0, "TelescopeSymbolReference", { fg = "#ffb86c" })     -- orange
    vim.api.nvim_set_hl(0, "TelescopeSymbolFolder", { fg = "#94e2d5" })        -- teal
    vim.api.nvim_set_hl(0, "TelescopeSymbolEnumMember", { fg = "#bd93f9" })    -- purple
    vim.api.nvim_set_hl(0, "TelescopeSymbolConstant", { fg = "#f38ba8" })      -- light red
    vim.api.nvim_set_hl(0, "TelescopeSymbolStruct", { fg = "#fab387" })        -- peach
    vim.api.nvim_set_hl(0, "TelescopeSymbolEvent", { fg = "#f38ba8" })         -- light red
    vim.api.nvim_set_hl(0, "TelescopeSymbolOperator", { fg = "#ff5555" })      -- red
    vim.api.nvim_set_hl(0, "TelescopeSymbolTypeParameter", { fg = "#b4befe" }) -- lavender
    vim.api.nvim_set_hl(0, "TelescopeSymbolObject", { fg = "#b4bffe" })        -- lavender

    vim.api.nvim_set_hl(0, "TelescopeMyHint", { fg = "#434544" })
    vim.api.nvim_set_hl(0, "TelescopeAutoSearch", { fg = "#DBB0AF" })
end

local function set_copilot_suggestion_color()
    vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#82390d", italic = true })
end

transparent_background()
spelling_underline()
telescope_colors()
set_copilot_suggestion_color()

-- utility function
local M = {}
local current = 0

function M.my_toggle_theme()
    if current == 0 then
        vim.notify("Switching to theme kanagawa-lotus")
        vim.cmd("colorscheme kanagawa-lotus")
        telescope_colors()
        spelling_underline()
        set_copilot_suggestion_color()
        current = 1
    else
        vim.notify("Switching to theme kanagawa-dragon")
        require("kanagawa").setup({ theme = "dragon" })
        vim.cmd("colorscheme kanagawa")
        telescope_colors()
        spelling_underline()
        transparent_background()
        set_copilot_suggestion_color()
        current = 0
    end
end

return M
