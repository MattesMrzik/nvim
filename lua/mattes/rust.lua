require'lspconfig'.rust_analyzer.setup {
    cmd = {"/Users/mrzi/.cargo/bin/rust-analyzer"},
    settings = {
        ['rust-analyzer'] = {
            semanticHighlighting = false,
            check = {
                command = "clippy";
            },
            diagnostics = {
                enable = true;
            },
        }
    },
    -- since the lsp takes some time to startup, calling the inlay_hint immediately has no effect
    -- so the call is delayed
    on_attach = function(client, bufnr)
        vim.defer_fn(function()
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end, 4000)
    end,
}


-- enables cargo fmt on save, i think this might be less efficient than rust fmt since 
-- cargo does every file (i think) and not only the changed ones, but (i think) cargo fmt produces better formats
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.rs",
  callback = function()
    vim.cmd("silent !cargo fmt")
  end,
})

-- shows deduced variable types as hint
vim.lsp.inlay_hint.enable(true)

-- code completion
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
            cmp.config.compare.offset,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            function(e1, e2)
                return compare_kinds(types.lsp.CompletionItemKind.Field, false)(e1, e2)
            end,
            function(e1, e2)
                return compare_kinds(types.lsp.CompletionItemKind.Method, false)(e1, e2)
            end,
            function(e1, e2)
                return compare_kinds(types.lsp.CompletionItemKind.Variable, false)(e1, e2)
            end,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
})

-- utility method used in remap.lua
local ts_utils = require("nvim-treesitter.ts_utils")
local M = {}
function M.jump_to_trait()
    local node = ts_utils.get_node_at_cursor()
    while node do
        if node:type() == "impl_item" then
            for child in node:iter_children() do
                if child:type() == "type_identifier" or child:type() == "generic_type" then
                    local row, col = child:range()
                    vim.api.nvim_win_set_cursor(0, { row + 1, col + 1 })
                    vim.lsp.buf.definition()
                    return
                end
            end
        end
        node = node:parent()
    end
    print("No trait found in current impl block.")
end
return M


