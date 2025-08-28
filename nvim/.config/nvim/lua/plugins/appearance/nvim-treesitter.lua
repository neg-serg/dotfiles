-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ nvim-treesitter/nvim-treesitter                                              │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate', -- чтобы автоматически обновлялись парсеры
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = { "lua", "python", "bash" }, -- языки, которые подтянутся сами
      highlight = { enable = true }, -- включить подсветку
      indent = { enable = true }, -- умные отступы
    })
  end
}
