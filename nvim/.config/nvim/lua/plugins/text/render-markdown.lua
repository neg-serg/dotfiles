-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ MeanderingProgrammer/render-markdown.nvim                                    │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
    enabled=false,
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies={'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim'}, -- if you use the mini.nvim suite
    opts = {},
    ft={'markdown', 'quarto'},
    setup = function()
      require'render-markdown'.setup({
        enabled=true,
        completions={blink={enabled=true}},
        render_modes=true,
        win_options = {
            conceallevel = { default = vim.o.conceallevel, rendered = 3 },
            concealcursor = { default = vim.o.concealcursor, rendered = '' },
        },
        anti_conceal={
            enabled=false,
            -- Which elements to always show, ignoring anti conceal behavior. Values can either be
            -- booleans to fix the behavior or string lists representing modes where anti conceal
            -- behavior will be ignored. Valid values are:
            --   head_icon, head_background, head_border, code_language, code_background, code_border,
            --   dash, bullet, check_icon, check_scope, quote, table_border, callout, link, sign
            ignore={code_background = true, sign = true,},
            above=0,
            below=0,
        },
      })
    end
}
