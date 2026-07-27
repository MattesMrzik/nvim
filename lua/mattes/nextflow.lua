local nf_ls_path
if vim.fn.expand("~") == "/Users/mrzi" then
    nf_ls_path = "/Users/mrzi/Seafile/Meine_Bibliothek/Bashrc/nextflow/language-server-all.jar"
else
    nf_ls_path = "/net/home/mrzi/bin/groovy_lsp.jar"
end

vim.lsp.enable('nextflow')

vim.lsp.config['nextflow'] = {
    -- downloaded from https://github.com/nextflow-io/language-server/releases/tag/v26.04.0
    cmd = { 'java', '-jar', nf_ls_path },
    filetypes = { 'nextflow', 'nf', 'groovy', 'config' },
    root_markers = { 'nextflow.config', '.git' },
    -- Perhaps sometime the lsp broke, this might be a fix
    -- on_attach = function(client, bufnr)
    --     local uri = vim.uri_from_bufnr(bufnr)
    --     if uri:match("^diffview://") then
    --         vim.lsp.stop_client(client.id)
    --     end
    -- end,
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
