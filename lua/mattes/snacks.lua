local snacks = require("snacks")
snacks.setup {
    animate = { enabled = false },
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    indent = {
        enabled = true,
        animate = {
            enabled = false,
        }
    },
    input = { enabled = true },
    picker = {
        enabled = true,
        ui_select = true,
        layouts = {
            vertical = {
                layout = {
                    width = 0.9,
                }
            },
            horizontal = {
                layout = {
                    width = 0.9,
                }
            },
            dropdown = {
                layout = {
                    width = 0.9,
                }
            },
            vscode = {
                layout = {
                    width = 0.9,
                }
            },
            select = {
                layout = {
                    width = 0.9,
                }
            },
        },
    },
    explorer = { enabled = true, },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
}
