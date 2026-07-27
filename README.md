# nvim config

## Hotfix

### Comment.nvim `gcc` fails with `[Comment.nvim] nil`

**Root cause:** `vim.treesitter.get_parser()` returns `nil` without throwing an error when a treesitter parser is not installed. The `ft.calculate` function in `Comment.nvim` only checked `if not ok` from `pcall`, but `pcall` returns `ok = true` even when the parser is `nil`. This caused a crash when calling `parser:children()` on nil.

**Fix:** Added `or not parser` to the condition in `Comment.nvim/lua/Comment/ft.lua:296` so it falls back to the hardcoded commentstring table when no parser is available.

```lua
-- before:
if not ok then
-- after:
if not ok or not parser then
```

**Root cause:** No treesitter parsers were installed in this environment (the `tree-sitter` CLI is not available to compile them). The `ensure_installed` list in `after/plugin/treesitter.lua` also didn't include `python`.
