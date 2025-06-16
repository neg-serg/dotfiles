-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ windwp/windline.nvim                                                         │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {{'windwp/windline.nvim', config = function()
      local wl = require'windline'
      local comp = require'windline.components.basic'
      local cache = require'windline.cache_utils'
      local lsp = require'windline.components.lsp'
      local git = require'windline.components.git'

      local colors = {
        black = 'NONE', white = '#54667a', red = '#970d4f', green = '#007a51',
        blue = '#005faf', yellow = '#c678dd', cyan = '#6587b3', base = '#234758',
        NormalBg = '#282828', InactiveFg = '#c6c6c6', InactiveBg = '#3c3836'
      }

      local hl = {
        Black = {'white', 'black'},
        White = {'black', 'white'},
        Inactive = {'InactiveFg', 'InactiveBg'}
      }

      local bp_width = 90
      local sep = require'windline.helpers'.separators.slant_right

      local function file_components(wide)
        return wide and {
          {cache.cache_on_buffer('BufEnter', 'dir_symbol', function()
            return vim.fn.empty(vim.fn.expand('%:t')) ~= 1 and '' or ''
          end), 'blue'},
          {' ', ''},
          {cache.cache_on_buffer({'BufEnter', 'DirChanged'}, 'WL_filename', function()
            return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
          end), 'default'},
          {cache.cache_on_buffer('BufEnter', 'delimiter', function()
            return vim.fn.empty(vim.fn.expand('%:t')) ~= 1 and ' ¦' or ''
          end), 'blue'},
          {' ', ''},
          {comp.file_name(''), 'cyan'},
          {comp.file_modified(' '), 'blue'}
        } or {
          {cache.cache_on_buffer({'BufEnter', 'DirChanged'}, 'WL_filename', function()
            return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
          end), 'cyan'},
          {comp.cache_file_size(), 'default'},
          {' ', ''},
          {comp.file_modified(' '), 'blue'}
        }
      end

      local components = {
        divider = {comp.divider, ''},
        file = {
          hl_colors = {default = hl.Black, white = {'white', 'black'}, cyan = {'cyan', 'black'}, blue = {'blue', 'black'}},
          text = function(_, _, w) return file_components(w > bp_width) end
        },
        lsp_diagnos = {
          hl_colors = {red = {'red', 'black'}, yellow = {'yellow', 'black'}, blue = {'blue', 'black'}},
          width = bp_width,
          text = function(b) return lsp.check_lsp(b) and {
            {lsp.lsp_error({format = '  %s', show_zero = false}), 'red'},
            {lsp.lsp_warning({format = '  %s', show_zero = false}), 'yellow'},
            {lsp.lsp_hint({format = '  %s', show_zero = false}), 'blue'}
          } or '' end
        },
        git = {
          hl_colors = {green = {'green', 'black'}, red = {'red', 'black'}, white = {'white', 'black'}},
          width = bp_width,
          text = function(b) return git.is_git(b) and {
            {git.diff_added({format = '  %s', show_zero = false}), 'green'},
            {git.diff_changed({format = '  %s', show_zero = false}), 'white'},
            {git.diff_removed({format = '  %s', show_zero = false}), 'red'}
          } or '' end
        }
      }

      wl.setup({
        colors_name = function() return colors end,
        statuslines = {
          {
            filetypes = {'default'},
            active = {
              components.file,
              components.lsp_diagnos,
              components.divider,
              {comp.cache_file_size(), {'white', 'black'}},
              {' ', hl.Black},
              {git.git_branch({icon = '  '}), {'blue', 'black'}, bp_width},
              {' ', hl.Black}
            },
            inactive = {
              {comp.full_file_name, hl.Inactive},
              components.divider,
              {comp.progress, hl.Inactive}
            }
          },
          {
            filetypes = {'qf', 'Trouble'},
            active = {
              {'Quickfix ', {'white', 'black'}},
              {function() return vim.fn.getqflist({title = 0}).title end, {'blue', 'base'}},
              {' Total:%L ', {'base', 'black'}}
            },
            always_active = true
          },
          {
            filetypes = {'fern', 'NvimTree', 'lir'},
            active = {
              {'  ', {'black', 'red'}},
              {sep, {'red', 'NormalBg'}},
              components.divider,
              {comp.file_name(''), {'white', 'NormalBg'}}
            },
            always_active = true
          },
          {
            filetypes = {'TelescopePrompt'},
            active = {{'  ', {'white', 'black'}}}
          }
        }
      })
    end
  }
}
