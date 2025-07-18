require("noice").setup({
    lsp = {
        hover = {
            enabled = true,
        },
    },
    presets = {
        lsp_doc_border = true, -- add a border to hover docs and signature help
    },
})
