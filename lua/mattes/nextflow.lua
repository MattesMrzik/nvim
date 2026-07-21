vim.lsp.enable('nextflow')

vim.lsp.config['nextflow'] = {
    -- downloaded from https://github.com/nextflow-io/language-server/releases/tag/v26.04.0
    cmd = { 'java', '-jar', '/net/home/mrzi/bin/groovy_lspjar' },
    filetypes = { 'nextflow', 'nf', 'groovy', 'config' },
    root_markers = { 'nextflow.config', '.git' },
    settings = {
        nextflow = {
            files = {
                exclude = { '.git', '.nf-test', 'work' },
            }
        }
    }
}

-- to make syntax highlighting work in telescope previewer
vim.filetype.add({ extension = { nf = "nextflow" } })
