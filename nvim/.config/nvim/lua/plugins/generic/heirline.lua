-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ rebelot/heirline.nvim                                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'rebelot/heirline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local c     = require('heirline.conditions')
    local utils = require('heirline.utils')

    -- Color palette
    local colors = {
      black = 'NONE', white = '#54667a', red = '#970d4f',
      green = '#007a51', blue = '#005faf', yellow = '#c678dd',
      cyan = '#6587b3', blue_light = '#517f8d',
    }

    local function hl(fg, bg) return { fg = fg, bg = bg } end
    local align = { provider = '%=' }

    -- Helper: unnamed/empty buffer guard
    local function is_empty() return vim.fn.empty(vim.fn.expand('%:t')) == 1 end

    -- Current working directory
    local CurrentDir = {
      provider = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end,
      hl = hl(colors.white, colors.black),
      update = { 'DirChanged', 'BufEnter' },
    }

    -- File icon (guard against unnamed buffers)
    local FileIcon = {
      condition = function() return not is_empty() end,
      provider = function()
        local name = vim.fn.expand('%:t')
        local icon = require('nvim-web-devicons').get_icon(name)
        return icon or ''
      end,
      hl = hl(colors.cyan, colors.black),
      update = { 'BufEnter', 'BufFilePost' },
    }

    -- Left side: only when a file/buffer is present
    local LeftComponents = {
      condition = function() return not is_empty() end,
      { provider = ' ', hl = hl(colors.blue, colors.black) },
      CurrentDir,
      { provider = ' ¦ ', hl = hl(colors.blue, colors.black) },
      FileIcon,
      {
        provider = function() return ' ' .. vim.fn.expand('%:t') end,
        hl = hl(colors.white, colors.black),
        update = { 'BufEnter', 'BufFilePost' },
      },
      {
        condition = function() return vim.bo.modified end,
        provider = ' ',
        hl = hl(colors.blue, colors.black),
        update = { 'BufWritePost', 'TextChanged', 'TextChangedI', 'BufModifiedSet' },
      },
    }

    -- Diagnostics atom (errors/warnings)
    local function get_diag(severity_key)
      local color = (severity_key == 'errors') and colors.red or colors.yellow
      local sev   = (severity_key == 'errors') and vim.diagnostic.severity.ERROR
                                         or        vim.diagnostic.severity.WARN
      return {
        provider = function(self)
          local n = self[severity_key] or 0
          return (n > 0) and (' ' .. n .. ' ') or ''
        end,
        hl = hl(color, colors.black),
      }
    end

    -- Human-readable file size
    local function get_size()
      local size = vim.fn.getfsize(vim.fn.expand('%:p'))
      if size <= 0 then return '' end
      local i = 1
      local suffix = { '', 'K', 'M', 'G' }
      while size >= 1024 and i < #suffix do
        size = size / 1024
        i = i + 1
      end
      if i == 1 then
        return string.format('%d%s ', size, suffix[i])
      else
        return string.format('%.1f%s ', size, suffix[i])
      end
    end

    -- Right/aux components
    local components = {
      -- Macro recorder
      macro = {
        condition = function() return vim.fn.reg_recording() ~= '' end,
        provider = function() return '  REC @' .. vim.fn.reg_recording() .. ' ' end,
        hl = hl(colors.red, colors.black),
        update = { 'RecordingEnter', 'RecordingLeave' },
      },

      -- Diagnostics
      diag = {
        condition = c.has_diagnostics,
        init = function(self)
          self.errors   = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
          self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        end,
        update = { 'DiagnosticChanged', 'BufEnter' },
        get_diag('errors'),
        get_diag('warnings'),
        on_click = {
          callback = function() pcall(vim.diagnostic.setqflist) end,
          name = 'heirline_diagnostics',
        },
      },

      -- LSP attached
      lsp = {
        condition = c.lsp_attached,
        provider = '  ',
        hl = hl(colors.cyan, colors.black),
        on_click = { callback = function() vim.cmd('LspInfo') end, name = 'heirline_lsp_info' },
        update = { 'LspAttach', 'LspDetach' },
      },

      -- Git (branch from gitsigns)
      git = {
        condition = c.is_git_repo,
        provider = function()
          local head = vim.b.gitsigns_head or ''
          if head == '' then return '' end
          return '  ' .. head .. ' '
        end,
        hl = hl(colors.blue, colors.black),
        -- Keep it simple & robust
        update = { 'BufEnter', 'BufWritePost' },
      },

      -- Encoding + EOL flavor
      encoding = {
        provider = function()
          -- Normalize encoding (bo.fileencoding may be empty → fallback to o.encoding)
          local enc = (vim.bo.fileencoding ~= '' and vim.bo.fileencoding) or vim.o.encoding or 'utf-8'
          enc = enc:lower()
          local enc_icon = (enc == 'utf-8') and '' or ''
          local fmt = vim.bo.fileformat
          local os_icon = ({ unix = '', dos = '', mac = '' })[fmt] or ''
          return string.format(' %s %s ', os_icon, enc_icon)
        end,
        hl = hl(colors.cyan, colors.black),
        update = { 'OptionSet', 'BufEnter' },
      },

      -- File size (only when a file exists)
      size = {
        condition = function() return not is_empty() end,
        provider = function() return get_size() end,
        hl = hl(colors.white, colors.black),
        update = { 'BufEnter', 'BufWritePost' },
      },

      -- Search status: hides when 0/0 or empty pattern
      search = {
        condition = function() return vim.v.hlsearch == 1 end,
        provider = function()
          local pattern = vim.fn.getreg('/')
          if not pattern or pattern == '' then return '' end
          if #pattern > 15 then pattern = pattern:sub(1, 12) .. '...' end
          local s = vim.fn.searchcount({ recompute = 1, maxcount = 1000 })
          local cur = s.current or 0
          local tot = s.total   or 0
          if tot == 0 then return '' end -- hide when 0/0
          return string.format('  %s %d/%d ', pattern, cur, tot)
        end,
        hl = hl(colors.yellow, colors.black),
        update = { 'CmdlineLeave', 'CursorMoved', 'CursorMovedI' },
      },

      -- Cursor position + percent through file (Lua formatting)
      position = {
        provider = function()
          local lnum = vim.fn.line('.')
          local col  = vim.fn.col('.')
          local last = math.max(1, vim.fn.line('$'))
          local pct  = math.floor(lnum * 100 / last)
          return string.format(' %3d:%-2d %3d%% ', lnum, col, pct)
        end,
        hl = hl(colors.white, colors.black),
        update = { 'CursorMoved', 'CursorMovedI' },
      },
    } -- <— this closes `components`

    -- Final composition
    require('heirline').setup({
      statusline = {
        hl = hl(colors.white, colors.black),
        utils.surround({ '', '' }, colors.black, {
          { condition = is_empty, provider = '[N]', hl = hl(colors.white, colors.black) },
          LeftComponents,
          components.search,
        }),
        {
          components.macro,
          align,
          components.diag,
          components.lsp,
          components.git,
          components.encoding,
          components.size,
          components.position,
        },
      },
      opts = {
        disable_winbar_cb = function(args)
          return c.buffer_matches({
            buftype = { 'nofile', 'prompt', 'help', 'quickfix' },
            filetype = { '^git.*', 'fugitive' },
          }, args.buf)
        end,
      },
    })

    -- Ensure StatusLine groups are set
    vim.api.nvim_set_hl(0, 'StatusLine',   hl(colors.white, colors.black))
    vim.api.nvim_set_hl(0, 'StatusLineNC', hl(colors.white, colors.black))
  end,
}
