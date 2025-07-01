-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ MeanderingProgrammer/render-markdown.nvim                                    │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
    enabled=true,
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    setup = function()
      require('render-markdown').setup({
        completions = { blink = { enabled = true } },
      })
    end
}
