vim.lsp.enable('nextflow')

vim.lsp.config['nextflow'] = {
    -- downloaded from https://github.com/nextflow-io/language-server/releases/tag/v26.04.0
    cmd = { 'java', '-jar', '/Users/mrzi/Seafile/Meine_Bibliothek/Bashrc/nextflow/language-server-all.jar' },
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
