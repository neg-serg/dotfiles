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
      cyan = '#6587b3', blue_light = '#517f8d'
    }

    local function hl(fg, bg) return { fg = fg, bg = bg } end
    local align = { provider = '%=' }
    local is_empty = function() return vim.fn.empty(vim.fn.expand('%:t')) == 1 end

    -- Common components
    local CurrentDir = {
      provider = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end,
      hl = hl(colors.white, colors.black),
      update = { 'DirChanged', 'BufEnter' }
    }

    local FileIcon = {
      provider = function()
        return (require('nvim-web-devicons').get_icon(vim.fn.expand('%:t'))) or ''
      end,
      hl = hl(colors.cyan, colors.black)
    }

    -- Left side components
    local LeftComponents = {
      condition = function() return not is_empty() end,
      { provider = ' ', hl = hl(colors.blue, colors.black) }, CurrentDir,
      { provider = ' ¦ ', hl = hl(colors.blue, colors.black) }, FileIcon,
      { provider = function() return ' '..vim.fn.expand('%:t') end, hl = hl(colors.white, colors.black) },
      { condition = function() return vim.bo.modified end, provider = ' ', hl = hl(colors.blue, colors.black) }
    }

    -- Diagnostic helper
    local get_diag = function(severity)
      return {
        provider = function(self)
          return self[severity] > 0 and (' '..self[severity]..' ')
        end,
        hl = hl(colors[severity == 'errors' and 'red' or 'yellow'], colors.black)
      }
    end

    -- File size helper
    local get_size = function()
        local size = vim.fn.getfsize(vim.fn.expand('%:p'))
        if size <= 0 then return '' end

        local i = 1
        local suffixes = { '', 'K', 'M', 'G' }
        while size >= 1024 and i < #suffixes do
            size = size / 1024
            i = i + 1
        end
        return string.format(i == 1 and '%d%s ' or '%.1f%s ', size, suffixes[i])
    end

    -- Component definitions
    local components = {
      macro = {
        condition = function() return vim.fn.reg_recording() ~= '' end,
        provider = function() return '  REC @'..vim.fn.reg_recording()..' ' end,
        hl = hl(colors.red, colors.black)
      },
      diag = {
        condition = c.has_diagnostics,
        init = function(self)
          self.errors = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR})
          self.warnings = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.WARN})
        end,
        get_diag('errors'), get_diag('warnings'),
        on_click = { callback = function() vim.diagnostic.setqflist() end, name = 'heirline_diagnostics' }
      },
      lsp = {
        condition = c.lsp_attached,
        provider = '  ',
        hl = hl(colors.cyan, colors.black),
        on_click = { callback = function() vim.cmd('LspInfo') end, name = 'heirline_lsp_info' }
      },
      git = {
        condition = c.is_git_repo,
        provider = function() return '  '..(vim.b.gitsigns_head or '')..' ' end,
        hl = hl(colors.blue, colors.black),
      },
      encoding = {
        provider = function()
          local fmt = vim.bo.fileformat
          local enc = vim.bo.fileencoding == "utf-8" and "" or ""
          return ({ unix = "", dos = "", mac = "" })[fmt]..' '..enc..' '
        end,
        hl = hl(colors.cyan, colors.black)
      },
      size = {
        provider = function() return get_size() end,
        hl = hl(colors.white, colors.black)
      },
      search = {
        condition = function() return vim.v.hlsearch == 1 end,
        provider = function()
          local pattern = vim.fn.getreg('/')
          if #pattern > 15 then pattern = pattern:sub(1,12)..'...' end
          local s = vim.fn.searchcount({ recompute = 1, maxcount = 1000 })
          return string.format('  %s %d/%d ', pattern, s.current, s.total)
        end,
        hl = hl(colors.yellow, colors.black)
      },
    }

    -- Final composition
    require('heirline').setup({
      statusline = {
        hl = hl(colors.white, colors.black),
        utils.surround({ '', '' }, colors.black, {
          { condition = is_empty, provider = '[N]', hl = hl(colors.white, colors.black) },
          LeftComponents,
          components.search
        }),
        {
          components.macro,
          align,
          components.diag,
          components.lsp,
          components.git,
          components.encoding,
          components.size,
          components.position
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
