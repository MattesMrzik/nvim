require'lspconfig'.rust_analyzer.setup {
    settings = {
        ['rust-analyzer'] = {
            check = {
                command = "clippy";
            },
            diagnostics = {
                enable = true;
            }
        }
    }
}

local cmp = require("cmp")
local types = require('cmp.types')
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
        --["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
        --["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] =cmp.mapping.select_next_item(),
    },
    sources =  {
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'path' },
        { name = 'buffer' },
    },
    sorting = {
        comparators = {
            cmp.config.compare.recently_used,
            function(entry1, entry2)
                local kind1 = entry1:get_kind()
                local kind2 = entry2:get_kind()
                if kind1 == types.lsp.CompletionItemKind.Field and kind2 ~= types.lsp.CompletionItemKind.Field then
                    return true
                elseif kind2 == types.lsp.CompletionItemKind.Field and kind1 ~= types.lsp.CompletionItemKind.Field then
                    return false
                end
                return nil
            end,
            function(entry1, entry2)
                local kind1 = entry1:get_kind()
                local kind2 = entry2:get_kind()
                if kind1 == types.lsp.CompletionItemKind.Method and kind2 ~= types.lsp.CompletionItemKind.Method then
                    return true
                elseif kind2 == types.lsp.CompletionItemKind.Method and kind1 ~= types.lsp.CompletionItemKind.Method then
                    return false
                end
                return nil
            end,
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
})
