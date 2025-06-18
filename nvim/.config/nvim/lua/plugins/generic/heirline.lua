-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ rebelot/heirline.nvim                                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'rebelot/heirline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local c = require('heirline.conditions')
    local utils = require('heirline.utils')
    local colors = {
      black = 'NONE', white = '#54667a', red = '#970d4f',
      green = '#007a51', blue = '#005faf', yellow = '#c678dd',
      cyan = '#6587b3', base = '#234758', blue_light = '#517f8d'
    }

    local function hl(fg, bg) return { fg = fg, bg = bg } end
    local Align = { provider = '%=' }
    local Space = { provider = ' ' }
    local is_empty = function() return vim.fn.empty(vim.fn.expand('%:t')) == 1 end

    -- Common components
    local CurrentDir = {
      provider = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end,
      hl = hl(colors.white, colors.black),
      update = { 'DirChanged', 'BufEnter' }
    }

    local FileIcon = {
      provider = function()
        local icon = require('nvim-web-devicons').get_icon(vim.fn.expand('%:t'))
        return (icon or '')..' '
      end,
      hl = hl(colors.cyan, colors.black)
    }

    -- Left side components
    local LeftComponents = {
      condition = function() return not is_empty() end,
      { provider = ' ', hl = hl(colors.blue, colors.black) },
      CurrentDir,
      { provider = ' ¦ ', hl = hl(colors.blue, colors.black) },
      FileIcon,
      { provider = function() return vim.fn.expand('%:t') end, hl = hl(colors.white, colors.black) },
      {
        condition = function() return vim.bo.modified end,
        provider = ' ',
        hl = hl(colors.blue, colors.black)
      }
    }

    -- Right side components
    local MacroRec = {
      condition = function() return vim.fn.reg_recording() ~= '' end,
      provider = function() return '  REC @'..vim.fn.reg_recording()..' ' end,
      hl = hl(colors.red, colors.black)
    }

    local Diagnostics = {
      condition = c.has_diagnostics,
      init = function(self)
        self.errors = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR})
        self.warnings = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.WARN})
      end,
      {
        provider = function(self) return self.errors > 0 and (' '..self.errors..' ') end,
        hl = hl(colors.red, colors.black),
        on_click = { callback = function() vim.diagnostic.setqflist() end, name = 'heirline_diagnostics' }
      },
      {
        provider = function(self) return self.warnings > 0 and (' '..self.warnings..' ') end,
        hl = hl(colors.yellow, colors.black)
      }
    }

    local LSP = {
      condition = c.lsp_attached,
      provider = '  ',
      hl = hl(colors.cyan, colors.black),
      on_click = { callback = function() vim.cmd('LspInfo') end, name = 'heirline_lsp_info' }
    }

    local Git = {
      condition = c.is_git_repo,
      provider = function() return '  '..(vim.b.gitsigns_head or '')..' ' end,
      hl = hl(colors.blue, colors.black),
      on_click = { callback = function() vim.cmd('Lazygit') end, name = 'heirline_git' }
    }

    local FileSize = {
      provider = function()
        local file = vim.fn.expand('%:p')
        if #file == 0 or vim.fn.empty(file) == 1 then return '' end
        local size = vim.fn.getfsize(file)
        if size <= 0 then return '' end
        
        local suffixes = { 'B', 'K', 'M', 'G' }
        local i = 1
        while size > 1024 and i < #suffixes do
          size, i = size / 1024, i + 1
        end
        return string.format(' %.1f%s ', size, suffixes[i])
      end,
      hl = hl(colors.white, colors.black)
    }

    local FileEncoding = {
      provider = function()
        local icons = { unix = " ", dos = " ", mac = " " }
        return string.format(" %s%s ", icons[vim.bo.fileformat] or "", 
          vim.bo.fileencoding == "utf-8" and "" or "")
      end,
      hl = hl(colors.cyan, colors.black)
    }

    local SearchIndicator = {
      condition = function() return vim.v.hlsearch == 1 end,
      init = function(self)
        self.pattern = vim.fn.getreg('/')
        local search_info = vim.fn.searchcount({ recompute = 1, maxcount = 1000 })
        self.current, self.total = search_info.current, search_info.total
      end,
      {
        provider = function(self)
          local icons = {"", "", "", ""}
          return " "..icons[math.floor(vim.loop.now() / 300 % #icons + 1)].." "
        end,
        hl = hl(colors.yellow, colors.black)
      },
      {
        provider = function(self)
          return #self.pattern > 15 and self.pattern:sub(1, 12)..'...' or self.pattern
        end,
        hl = hl(colors.white, colors.black)
      },
      {
        provider = function(self)
          local flags = vim.fn.getregtype('/'):sub(2)
          return flags:find('[cw]') and " " or ""
        end,
        hl = hl(colors.cyan, colors.black)
      },
      {
        provider = function(self)
          return self.total > 0 and string.format(" %d/%d ", self.current, self.total) or " 0/0 "
        end,
        hl = hl(colors.green, colors.black)
      }
    }

    -- Final composition
    require('heirline').setup({
      statusline = {
        hl = hl(colors.white, colors.black),
        utils.surround({ '', '' }, colors.black, {
          { condition = is_empty, provider = '[N]', hl = hl(colors.white, colors.black) },
          LeftComponents,
          Git,
          SearchIndicator
        }),
        {
          MacroRec,
          Align,
          Diagnostics,
          LSP,
          FileEncoding,
          FileSize,
        }
      },
      opts = {
        flexible_components = true,
        disable_winbar_cb = function(args)
          return c.buffer_matches({
            buftype = { 'nofile', 'prompt', 'help', 'quickfix' },
            filetype = { '^git.*', 'fugitive' }
          }, args.buf)
        end
      }
    })

    vim.api.nvim_set_hl(0, 'StatusLine', hl(colors.white, colors.black))
    vim.api.nvim_set_hl(0, 'StatusLineNC', hl(colors.white, colors.black))
  end
}
