local snacks = require("snacks")
snacks.setup {
    animate = { enabled = false },
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    indent = {
        enabled = false,
        animate = {
            enabled = false,
        }
    },
    input = { enabled = true },
    picker = {
        enabled = true,
        ui_select = true,
        sources = {      -- Add this
            explorer = { -- Move explorer here
                layout = {
                    hidden = { "input" }
                }
            }
        },
        layouts = {
            vertical = {
                layout = {
                    width = 1,
                    height = 0.47,
                }
            },
            horizontal = {
                layout = {
                    width = 1,
                    height = 0.47,
                }
            },
            dropdown = {
                layout = {
                    width = 0.99,
                    height = 0.47,
                }
            },
            vscode = {
                layout = {
                    width = 0.99,
                    height = 0.47,
                }
            },
            select = {
                layout = {
                    width = 0.99,
                    height = 0.47,
                }
            },
        },
    },
    explorer = { enabled = true },
    notifier = { enabled = false },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
}
-- the notifier above might not be need
-- with this call below we can now use Telescope notify to see the history of notifications
vim.notify = require("notify")
