-- pyright sends AnnotatedTextEdit with annotationId but either omits the
-- changeAnnotations map or references IDs that don't exist in it, causing
-- assert(change_annotations ~= nil) in apply_text_edits (the Neovim side
-- fix in PR#34508 is already in 0.12.4).
-- Strip annotationId here: it's purely UI metadata (labels and confirmation
-- prompts). Without it, the edit still applies correctly.
-- Remove once pyright properly populates changeAnnotations (fixed upstream
-- in DetachHead/basedpyright#1352, likely in pyright >= 1.1.401).
local rename_handler = vim.lsp.handlers['textDocument/rename']
vim.lsp.handlers['textDocument/rename'] = function(err, result, ctx)
    if result then
        if result.documentChanges then
            for _, dc in ipairs(result.documentChanges) do
                if dc.edits then
                    for _, edit in ipairs(dc.edits) do
                        edit.annotationId = nil
                    end
                end
            end
        end
        if result.changes then
            for _, edits in pairs(result.changes) do
                for _, edit in ipairs(edits) do
                    edit.annotationId = nil
                end
            end
        end
    end
    rename_handler(err, result, ctx)
end
