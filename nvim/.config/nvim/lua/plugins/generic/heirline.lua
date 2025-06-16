-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ rebelot/heirline.nvim (Compact Windline)                                    │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
    'rebelot/heirline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local conditions = require('heirline.conditions')
      local utils = require('heirline.utils')

      -- Original Windline colors
      local colors = {
        black = 'NONE', white = '#54667a', red = '#970d4f', 
        green = '#007a51', blue = '#005faf', yellow = '#c678dd', 
        cyan = '#6587b3', base = '#234758', blue_light = '#517f8d'
      }

      -- Shared components
      local Align = { provider = '%=' }
      local Space = { provider = ' ' }
      local is_empty = function() return vim.fn.empty(vim.fn.expand('%:t')) == 1 end

      -- Left side components
      local LeftComponents = {
        -- File components or [N] for empty
        {
          condition = function() return not is_empty() end,
          {
            provider = ' ', hl = { fg = colors.blue, bg = colors.black }},
          {
            provider = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end,
            hl = { fg = colors.white, bg = colors.black }},
          {
            provider = ' ¦ ', hl = { fg = colors.blue, bg = colors.black }},
          {
            provider = function()
              local icon = require('nvim-web-devicons').get_icon(vim.fn.expand('%:t'))
              return (icon or '')..' '
            end,
            hl = { fg = colors.cyan, bg = colors.black }},
          {
            provider = function() return vim.fn.expand('%:t') end,
            hl = { fg = colors.white, bg = colors.black }},
          {
            condition = function() return vim.bo.modified end,
            provider = ' ', hl = { fg = colors.blue, bg = colors.black }}
        },
        -- Empty buffer indicator
        {
          condition = is_empty,
          provider = '[N]', hl = { fg = colors.white, bg = colors.black }
        }
      }

      -- Right side components
      local RightComponents = {
        Align,
        -- Diagnostics
        {
          condition = conditions.has_diagnostics,
          init = function(self)
            self.errors = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR})
            self.warnings = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.WARN})
          end,
          {
            provider = function(self) return self.errors > 0 and (' '..self.errors..' ') end,
            hl = { fg = colors.red, bg = colors.black }},
          {
            provider = function(self) return self.warnings > 0 and (' '..self.warnings..' ') end,
            hl = { fg = colors.yellow, bg = colors.black }}
        },
        -- LSP
        {
          condition = conditions.lsp_attached,
          provider = '  ', hl = { fg = colors.cyan, bg = colors.black }
        },
        -- Git
        {
          condition = conditions.is_git_repo,
          provider = function() return '  '..(vim.b.gitsigns_head or '')..' ' end,
          hl = { fg = colors.blue, bg = colors.black }
        }
      }

      -- Final statusline
      require('heirline').setup({
        statusline = {
          hl = { fg = colors.white, bg = colors.black },
          utils.surround({ '', '' }, colors.black, LeftComponents),
          RightComponents
        }
      })
    end
}
