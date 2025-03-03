-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ tzachar/highlight-undo.nvim                                                  │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'tzachar/highlight-undo.nvim', -- highlight changed text after any action not in insert
  opts = {
    hlgroup = "HighlightUndo",
    duration = 300,
    pattern = {"*"},
    ignored_filetypes = {"neo-tree", "fugitive", "TelescopePrompt", "mason", "lazy"},
  },
}
