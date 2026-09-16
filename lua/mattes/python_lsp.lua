if vim.fn.expand("~") == "/Users/mrzi" then
    -- local: pyright available homebrew
else
    -- pyright is installed via pip in the conda base environment (HPC only)
    -- make sure to install: /cfs/earth/scratch/mrzi/software/conda/install_location/bin/pip install "pyright[nodejs]"
    vim.env.PATH = "/cfs/earth/scratch/mrzi/software/conda/install_location/bin:" .. vim.env.PATH
end

vim.lsp.config("pyright", {
    on_attach = function(client, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }
    end,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly", -- or "workspace"
                typeCheckingMode = "basic", -- or "strict"
            },
        },
    },
})

-- Enable the server for its filetypes
vim.lsp.enable("pyright")
