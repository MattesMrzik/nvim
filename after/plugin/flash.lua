require("flash").setup()

vim.keymap.set({ "n", "x", "o" }, "<C-v>", function()
  require("flash").treesitter({
    actions = {
      ["+"] = "next",
      ["-"] = "prev",
    },
  })
end, { desc = "Treesitter incremental selection" })
