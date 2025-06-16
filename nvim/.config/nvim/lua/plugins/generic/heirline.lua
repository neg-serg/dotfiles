return {
  -- ┌───────────────────────────────────────────────────────────────────────────────────┐
  -- │ █▓▒░ rebelot/heirline.nvim (Windline-style)                                      │
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
        InactiveBg  = '#3c3836',
        ActiveFg    = '#54667a',
        ActiveBg    = 'NONE'
      }

      -- Basic components
      local Align = { provider = '%=' }
      local Space = { provider = ' ' }

      -- File icon component
      local FileIcon = {
        provider = function()
          local icon = require('nvim-web-devicons').get_icon(vim.fn.expand('%:t'))
          return icon and ' '..icon..' ' or '  '
        end,
        hl = { fg = colors.cyan, bg = colors.black }
      }

      local CurrentDir = {
          provider = function()
              if vim.fn.empty(vim.fn.expand('%:t')) == 1 then
                  return ''
              end
              return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
          end,
          hl = { fg = colors.white, bg = colors.black },
          -- Опциональное кэширование (требует механизма обновления Heirline)
          update = {
              'DirChanged',
              callback = function() vim.cmd('redrawstatus') end
          }
      }

      -- Divider between path and filename (blue ¦)
      local PathDivider = {
        provider = ' ¦ ',
        hl = { fg = colors.blue, bg = colors.black }
      }

      -- Filename only (without path)
      local FileName = {
        provider = function()
          return vim.fn.expand('%:t')
        end,
        hl = { fg = colors.white, bg = colors.black }
      }

      -- File modification indicator
      local FileModified = {
        condition = function() return vim.bo.modified end,
        provider = ' ',
        hl = { fg = colors.blue, bg = colors.black }
      }

      -- LSP diagnostics
      local Diagnostics = {
        condition = conditions.has_diagnostics,
        static = {
          icons = {
            error = ' ',
            warn = ' ',
            hint = ' '
          }
        },
        init = function(self)
          self.errors = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR})
          self.warnings = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.WARN})
          self.hints = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.HINT})
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
        },
        {
          provider = function(self)
            return self.hints > 0 and (self.icons.hint..self.hints..' ')
          end,
          hl = { fg = colors.blue, bg = colors.black }
        }
      }

      -- Git branch (now moved to right side)
      local GitBranch = {
        condition = conditions.is_git_repo,
        init = function(self)
          self.branch = vim.b.gitsigns_head or ''
        end,
        provider = function(self)
          return '  '..self.branch..' '
        end,
        hl = { fg = colors.blue, bg = colors.black }
      }

      -- Git changes
      local GitChanges = {
        condition = conditions.is_git_repo,
        init = function(self)
          local status = vim.b.gitsigns_status_dict or {}
          self.added = status.added or 0
          self.changed = status.changed or 0
          self.removed = status.removed or 0
        end,
        {
          provider = function(self)
            return self.added > 0 and (' '..self.added..' ')
          end,
          hl = { fg = colors.green, bg = colors.black }
        },
        {
          provider = function(self)
            return self.changed > 0 and (' '..self.changed..' ')
          end,
          hl = { fg = colors.white, bg = colors.black }
        },
        {
          provider = function(self)
            return self.removed > 0 and (' '..self.removed..' ')
          end,
          hl = { fg = colors.red, bg = colors.black }
        }
      }

      -- LSP server indicator
      local LSPActive = {
        condition = conditions.lsp_attached,
        provider = '  ',
        hl = { fg = colors.cyan, bg = colors.black }
      }

      -- Main statusline
      local DefaultStatusline = {
        hl = { fg = colors.white, bg = colors.black },
        FileIcon,          -- File icon
        CurrentDir,        -- Directory path
        PathDivider,       -- Blue divider
        FileName,          -- Filename
        FileModified,      -- Modification indicator
        Space,
        Align,             -- Right-align from here
        Diagnostics,       -- LSP diagnostics
        LSPActive,         -- LSP server
        GitBranch          -- Git branch (now on right side)
      }

      -- Special buffers statusline
      local SpecialStatusline = {
        condition = function()
          return conditions.buffer_matches({
            buftype = { 'nofile', 'prompt', 'help', 'quickfix' },
            filetype = { '^git.*', 'fugitive', 'NvimTree', 'TelescopePrompt' }
          })
        end,
        hl = { fg = colors.InactiveFg, bg = colors.InactiveBg },
        {
          provider = function()
            if vim.bo.filetype == 'NvimTree' then return '  File Explorer '
            elseif vim.bo.filetype == 'TelescopePrompt' then return '  Telescope '
            else return ' '..vim.bo.filetype:upper()..' ' end
          end,
          hl = { fg = colors.black, bg = colors.blue }
        }
      }

      -- Setup Heirline
      require('heirline').setup({
        statusline = {
          fallthrough = false,
          SpecialStatusline,
          DefaultStatusline
        }
      })
    end
  }
}
