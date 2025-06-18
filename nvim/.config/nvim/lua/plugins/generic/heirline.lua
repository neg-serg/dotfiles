-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ rebelot/heirline.nvim                                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
    'rebelot/heirline.nvim',
    dependencies={ 'nvim-tree/nvim-web-devicons' },
    config=function()
      local conditions=require('heirline.conditions')
      local utils=require('heirline.utils')
      local colors={
        black='NONE', white='#54667a', red='#970d4f',
        green='#007a51', blue='#005faf', yellow='#c678dd',
        cyan='#6587b3', base='#234758', blue_light='#517f8d'
      }
      -- Shared components
      local Align={provider='%='}
      local Space={provider=' '}
      local is_empty=function() return vim.fn.empty(vim.fn.expand('%:t')) == 1 end
      -- Current directory component
      local CurrentDir={
        provider=function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end,
        hl={ fg=colors.white, bg=colors.black },
        update={'DirChanged', 'BufEnter'} -- Autoupdate on change
      }

      -- Left side components
      local LeftComponents={
        {
          condition=function() return not is_empty() end,
          {provider=' ', hl={ fg=colors.blue, bg=colors.black },},
          CurrentDir, {provider=' ¦ ', hl={ fg=colors.blue, bg=colors.black}},
          {
            provider=function()
              local icon=require('nvim-web-devicons').get_icon(vim.fn.expand('%:t'))
              return (icon or '')..' '
            end,
            hl={fg=colors.cyan, bg=colors.black}
          },
          {provider=function() return vim.fn.expand('%:t') end, hl={ fg=colors.white, bg=colors.black}},
          {condition=function() return vim.bo.modified end, provider=' ', hl={fg=colors.blue, bg=colors.black}
          }
        },
        {condition=is_empty, provider='[N]', hl={fg=colors.white, bg=colors.black}}
      }

      -- Right side components
      local RightComponents={
        -- Macro recording indicator
        {
          condition=function() return vim.fn.reg_recording() ~= '' end,
          provider=function() return '  REC @'..vim.fn.reg_recording()..' ' end,
          hl={fg=colors.red, bg=colors.black}
        },
        Align, -- Diagnostics
        {
          condition=conditions.has_diagnostics,
          init=function(self)
            self.errors=#vim.diagnostic.get(0, {severity=vim.diagnostic.severity.ERROR})
            self.warnings=#vim.diagnostic.get(0, {severity=vim.diagnostic.severity.WARN})
          end,
          {
            provider=function(self) return self.errors > 0 and (' '..self.errors..' ') end,
            hl={fg=colors.red, bg=colors.black},
            on_click={callback=function() vim.diagnostic.setqflist() end, name='heirline_diagnostics'}
          },
          {
            provider=function(self) return self.warnings > 0 and (' '..self.warnings..' ') end,
            hl={fg=colors.yellow, bg=colors.black}
          }
        },
        -- LSP
        {
          condition=conditions.lsp_attached,
          provider='  ',
          hl={fg=colors.cyan, bg=colors.black},
          on_click={callback=function() vim.cmd('LspInfo') end, name='heirline_lsp_info'}
        },
        -- Git branch
        {
          condition=conditions.is_git_repo,
          provider=function() return '  '..(vim.b.gitsigns_head or '')..' ' end,
          hl={ fg=colors.blue, bg=colors.black },
          on_click={callback=function() vim.cmd('Lazygit') end, name='heirline_git'}
        }
      }

      local FilePosition = {
          provider = function()
              local line = vim.fn.line('.')
              local col = vim.fn.virtcol('.')
              local lines = vim.fn.line('$')
              local percent = math.floor((line / lines) * 100)
              return string.format(' %d:%d  %d%% ', line, col, percent)
          end,
          hl = { fg = colors.white, bg = colors.black }
      }

      local FileSize = {
          provider = function()
              local file = vim.fn.expand('%:p')
              if file == '' or vim.fn.empty(file) == 1 then return '' end
              local size = vim.fn.getfsize(file)
              if size <= 0 then return '' end

              local suffixes = { 'B', 'K', 'M', 'G' }
              local i = 1
              while size > 1024 and i < #suffixes do
                  size = size / 1024
                  i = i + 1
              end
              return string.format(' %.1f%s ', size, suffixes[i])
          end,
          hl = { fg = colors.white, bg = colors.black }
      }

      local FileFormat = {
          provider = function()
              local ff = vim.bo.fileformat
              local fe = vim.bo.fileencoding ~= '' and vim.bo.fileencoding or vim.o.encoding
              return string.format(' %s | %s ', ff:upper(), fe:upper())
          end,
          hl = { fg = colors.cyan, bg = colors.black }
      }

      local SearchIndicator = {
          condition = function()
              return vim.v.hlsearch == 1
          end,
          provider = function()
              local search = vim.fn.getreg('/')
              if #search > 15 then
                  search = search:sub(1, 12) .. '...'
              end
              return string.format('  %s ', search)
          end,
          hl = { fg = colors.yellow, bg = colors.black },
          on_click = {
              callback = function() vim.cmd('nohlsearch') end,
              name = 'heirline_search_clear'
          }
      }

      table.insert(RightComponents, FilePosition)
      table.insert(RightComponents, FileSize)
      table.insert(RightComponents, FileFormat)
      table.insert(LeftComponents, 3, SearchIndicator)

      -- Final statusline
      require('heirline').setup({
        statusline={
          hl={ fg=colors.white, bg=colors.black },
          utils.surround({ '', '' }, colors.black, LeftComponents),
          RightComponents
        },
        opts={
          flexible_components=true,
          disable_winbar_cb=function(args)
            return conditions.buffer_matches({buftype={'nofile', 'prompt', 'help', 'quickfix'}, filetype={ '^git.*', 'fugitive' },}, args.buf)
          end
        }
      })

      -- Initial highlight setup
      vim.api.nvim_set_hl(0, 'StatusLine', { fg=colors.white, bg=colors.black })
      vim.api.nvim_set_hl(0, 'StatusLineNC', { fg=colors.white, bg=colors.black })
    end
  }
