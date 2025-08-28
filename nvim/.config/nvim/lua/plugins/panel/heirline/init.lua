return {
  'rebelot/heirline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('plugins.panel.heirline.config')()
  end,
}
