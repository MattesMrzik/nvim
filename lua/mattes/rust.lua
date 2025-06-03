--vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
--  vim.lsp.handlers.hover,
--  { border = "rounded" } -- You can also use "single", "double", etc.
--)
require'lspconfig'.rust_analyzer.setup {
    cmd = {"/Users/mrzi/.cargo/bin/rust-analyzer"},
    settings = {
        ['rust-analyzer'] = {
            check = {
                command = "clippy";
            },
            diagnostics = {
                enable = true;
            },
        }
    },
    on_attach = function(client, bufnr)
        vim.defer_fn(function()
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end, 4000)
    end,
}


local cmp = require("cmp")
local types = require('cmp.types')
local compare_kinds = function(kind, reverse)
    return function(entry1, entry2)
        local kind1 = entry1:get_kind()
        local kind2 = entry2:get_kind()
        if kind1 == kind and kind2 ~= kind then
            return not reverse
        elseif kind2 == kind and kind1 ~= kind then
            return reverse
        end
        return nil
    end
end
cmp.setup({
    preselect = cmp.PreselectMode.None,
    completion = {
        completeopt = 'menu,menuone,preview',
    },
    mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm(),
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
    },
    sources =  {
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'path' },
        { name = 'buffer' },
    },
    sorting = {
        comparators = {
            function (e1, e2)
                return compare_kinds(types.lsp.CompletionItemKind.Text, true)(e1, e2)
            end,
            cmp.config.compare.exact,
            cmp.config.compare.recently_used,
            cmp.config.compare.offset,
            function(e1, e2)
                return compare_kinds(types.lsp.CompletionItemKind.Field, false)(e1, e2)
            end,
            function(e1, e2)
                return compare_kinds(types.lsp.CompletionItemKind.Method, false)(e1, e2)
            end,
            function(e1, e2)
                return compare_kinds(types.lsp.CompletionItemKind.Variable, false)(e1, e2)
            end,
            cmp.config.compare.score,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
})


vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		vim.schedule(function()
			pcall(vim.keymap.del, "n", "<Esc>")
		end)
	end
})

vim.keymap.set('n', '<leader>im', require('telescope.builtin').lsp_implementations, { desc = 'LSP Implementations' })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
vim.keymap.set("n", "<leader>ih", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, {desc = "toggle inlay_hints"})
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.rs",
  callback = function()
    vim.cmd("silent !cargo fmt")
  end,
})


