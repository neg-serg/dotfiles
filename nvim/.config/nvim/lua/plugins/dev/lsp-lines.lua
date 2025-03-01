-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ https://git.sr.ht/~whynothugo/lsp_lines.nvim                                 │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    config = function()
        -- vim.diagnostic.config({ virtual_lines = { only_current_line = true } })
        vim.diagnostic.config({ virtual_lines = false })
        vim.keymap.set('', '<leader>w', require'lsp_lines'.toggle, {desc='Toggle lsp_lines'})
        require'lsp_lines'.setup()
    end,
}
