return {
  'rebelot/heirline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('plugins.generic.heirline.config')()
  end,
}
