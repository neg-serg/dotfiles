return {
  -- ┌───────────────────────────────────────────────────────────────────────────────────┐
  -- │ █▓▒░ rebelot/heirline.nvim (Windline exact replica)                              │
  -- └───────────────────────────────────────────────────────────────────────────────────┘
  {
    'rebelot/heirline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local conditions = require('heirline.conditions')
      local utils = require('heirline.utils')

      -- Original Windline color scheme
      local colors = {
        black       = 'NONE',
        white       = '#54667a',
        red         = '#970d4f',
        green       = '#007a51',
        blue        = '#005faf',
        yellow      = '#c678dd',
        cyan        = '#6587b3',
        base        = '#234758',
        blue_light  = '#517f8d',
        NormalFg    = '#ff0000',
        NormalBg    = '#282828',
        InactiveFg  = '#c6c6c6',
        InactiveBg  = '#3c3836'
      }

      -- Helper components
      local Align = { provider = '%=' }
      local Space = { provider = ' ' }

      -- Check for empty buffer
      local function is_empty()
        return vim.fn.empty(vim.fn.expand('%:t')) == 1
      end

      -- Windline-style empty buffer indicator
      local EmptyBufferIndicator = {
        condition = is_empty,
        hl = { fg = colors.white, bg = colors.black },
        provider = function()
          -- Show current directory path (relative) even in empty buffers
          local dir = vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
          return '  '..dir..' ¦  New Buffer '
        end
      }

      -- Main components for non-empty buffers
      local NonEmptyComponents = {
        condition = function() return not is_empty() end,
        
        -- Folder icon
        {
          provider = ' ',
          hl = { fg = colors.blue, bg = colors.black }
        },
        
        -- Current directory (relative path)
        {
          provider = function()
            return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
          end,
          hl = { fg = colors.white, bg = colors.black }
        },
        
        -- Divider (matches Windline exactly)
        {
          provider = ' ¦ ',
          hl = { fg = colors.blue, bg = colors.black }
        },
        
        -- File icon
        {
          provider = function()
            local icon = require('nvim-web-devicons').get_icon(vim.fn.expand('%:t'))
            return icon and icon..' ' or ' '
          end,
          hl = { fg = colors.cyan, bg = colors.black }
        },
        
        -- Filename only
        {
          provider = function()
            return vim.fn.expand('%:t')
          end,
          hl = { fg = colors.white, bg = colors.black }
        },
        
        -- Modification indicator
        {
          condition = function() return vim.bo.modified end,
          provider = ' ',
          hl = { fg = colors.blue, bg = colors.black }
        },
        
        Space,
        Align,
        
        -- LSP diagnostics
        {
          condition = conditions.has_diagnostics,
          static = {
            icons = {
              error = ' ',
              warn = ' '
            }
          },
          init = function(self)
            self.errors = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR})
            self.warnings = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.WARN})
          end,
          {
            provider = function(self)
              return self.errors > 0 and (self.icons.error..self.errors..' ')
            end,
            hl = { fg = colors.red, bg = colors.black }
          },
          {
            provider = function(self)
              return self.warnings > 0 and (self.icons.warn..self.warnings..' ')
            end,
            hl = { fg = colors.yellow, bg = colors.black }
          }
        },
        
        -- LSP indicator
        {
          condition = conditions.lsp_attached,
          provider = '  ',
          hl = { fg = colors.cyan, bg = colors.black }
        },
        
        -- Git branch
        {
          condition = conditions.is_git_repo,
          init = function(self)
            self.branch = vim.b.gitsigns_head or ''
          end,
          provider = function(self)
            return '  '..self.branch..' '
          end,
          hl = { fg = colors.blue, bg = colors.black }
        }
      }

      -- Main statusline
      local DefaultStatusline = {
        hl = { fg = colors.white, bg = colors.black },
        EmptyBufferIndicator,
        NonEmptyComponents
      }

      require('heirline').setup({
        statusline = {
          fallthrough = false,
          DefaultStatusline
        }
      })
    end
  }
}
