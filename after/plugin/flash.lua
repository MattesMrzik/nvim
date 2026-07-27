require("flash").setup()

-- FlashLabel, FlashMatch, etc. colors are configured in lua/mattes/color.lua
vim.keymap.set({ "n", "x", "o" }, "<C-v>", function()
    require("flash").treesitter({
        actions = {
            ["+"] = "next",
            ["-"] = "prev",
        },
    })
end, { desc = "Treesitter incremental selection" })
