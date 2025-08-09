return function()
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      vim.schedule(function()
        local api, fn = vim.api, vim.fn

        -- Augroup for hygiene, and double-setup guard
        local AUG = api.nvim_create_augroup('HeirlineConfig', { clear = true })
        if vim.g._heirline_config_loaded then return end
        vim.g._heirline_config_loaded = true

        -- Load deps (defensive)
        local ok_heir, heir = pcall(require, 'heirline'); if not ok_heir then return end
        local ok_cond, c     = pcall(require, 'heirline.conditions')
        local ok_utils, utils= pcall(require, 'heirline.utils')
        if not ok_cond or not ok_utils then return end
        local ok_devicons, devicons = pcall(require, 'nvim-web-devicons')

        -- ── Hidden debug ──────────────────────────────────────────────────────────
        local uv = vim.uv or vim.loop
        local DEBUG = (vim.env.HEIRLINE_DEBUG == '1') or (vim.g.heirline_debug == true)
        local DBG_TITLE, DBG_MAX = 'HeirlineDBG', 600
        local dbg_log = {}
        local function dbg_push(line)
          if not DEBUG then return end
          local msg = string.format('[%s] %s', os.date('%H:%M:%S'), line)
          if #dbg_log >= DBG_MAX then table.remove(dbg_log, 1) end
          table.insert(dbg_log, msg)
        end
        local function dbg_notify(line, lvl)
          if not DEBUG then return end
          dbg_push(line)
          if vim.notify then vim.notify(line, lvl or vim.log.levels.DEBUG, { title = DBG_TITLE }) end
        end
        local function prof(name, f, thr)
          if not DEBUG or type(f) ~= 'function' then return f end
          local T = thr or 5.0
          return function(...)
            local t0 = uv.hrtime()
            local ok, res = xpcall(f, debug.traceback, ...)
            local dt = (uv.hrtime() - t0) / 1e6
            if dt > T then dbg_push(string.format('slow %-18s %.2f ms', name, dt)) end
            if not ok then dbg_push(string.format('err  %-18s %s', name, tostring(res))); return '' end
            return res
          end
        end

        -- User commands (redef-safe)
        pcall(api.nvim_del_user_command, 'HeirlineDebugToggle')
        pcall(api.nvim_del_user_command, 'HeirlineDebugDump')
        pcall(api.nvim_del_user_command, 'HeirlineDebugClear')
        api.nvim_create_user_command('HeirlineDebugToggle', function()
          DEBUG = not DEBUG; vim.g.heirline_debug = DEBUG
          dbg_notify('debug mode: ' .. (DEBUG and 'ON' or 'OFF'))
        end, {})
        api.nvim_create_user_command('HeirlineDebugDump', function()
          local b = api.nvim_create_buf(false, true)
          api.nvim_buf_set_lines(b, 0, -1, false, dbg_log)
          api.nvim_buf_set_option(b, 'bufhidden', 'wipe')
          api.nvim_buf_set_option(b, 'filetype', 'log')
          api.nvim_set_current_buf(b)
        end, {})
        api.nvim_create_user_command('HeirlineDebugClear', function()
          dbg_log = {}; dbg_notify('log cleared')
        end, {})

        if DEBUG then
          api.nvim_create_autocmd({ 'LspAttach','LspDetach','DiagnosticChanged','WinResized' }, {
            group = AUG,
            callback = function(ev) dbg_push('event: ' .. ev.event) end,
          })
        end

        -- ── Flags & symbols ───────────────────────────────────────────────────────
        -- Persisted flags (allow runtime toggles)
        vim.g.heirline_use_icons = vim.g.heirline_use_icons
        vim.g.heirline_use_theme_colors = vim.g.heirline_use_theme_colors

        local USE_ICONS = vim.g.heirline_use_icons
        if USE_ICONS == nil then
          USE_ICONS = not (vim.env.NERD_FONT == '0') and (vim.g.have_nerd_font == true or true)
        end
        local SHOW_ENV = vim.g.heirline_env_indicator == true
        local USE_THEME = vim.g.heirline_use_theme_colors
        if USE_THEME == nil then USE_THEME = true end

        local function I(icons, ascii) return USE_ICONS and icons or ascii end
        local S = setmetatable({
          folder='', sep=' ¦ ', modified=I(' ',' *'), lock=I(' 🔒',' RO'),
          search=I('  ',' / '), rec=I(' ','REC'), gear=I('  ',' [LSP] '),
          branch=I('  ',' [git] '), close=I('  ',' [x] '),
          err=I(' ','E:'), warn=I(' ','W:'), utf8=I('','utf8'),
          latin=I('','enc'), linux=I('','unix'), mac=I('','mac'), win=I('','dos'),
          pilcrow=I(' ¶',' ¶'), wrap=I(' ⤶',' ↩'), doc=I('','[buf]'),
          plus=I('','+'), tilde=I('󰜥','~'), minus=I('','-'),
        }, {
          __index = function(_, k) return '[' .. tostring(k) .. ']' end,
        })

        -- ── Theme colors (0.9/0.8 compat) ─────────────────────────────────────────
        local _hl_cache = {}
        local function hl_get(name)
          if _hl_cache[name] then return _hl_cache[name] end
          local ok, h
          if vim.api.nvim_get_hl then
            ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and h then _hl_cache[name] = h; return h end
          end
          ok, h = pcall(vim.api.nvim_get_hl_by_name, name, true)
          if ok and h then
            local r = { fg = h.foreground, bg = h.background }
            _hl_cache[name] = r; return r
          end
          return {}
        end
        local function tohex(n) if not n then return nil end; return string.format('#%06x', n) end
        local function themed_colors(fallback)
          if not USE_THEME then return vim.deepcopy(fallback) end
          local sl   = hl_get('StatusLine')
          local slnc = hl_get('StatusLineNC')
          local dfe  = hl_get('DiagnosticError')
          local dfw  = hl_get('DiagnosticWarn')
          local dir  = hl_get('Directory')
          local id   = hl_get('Identifier')
          local str  = hl_get('String')
          local dadd = hl_get('DiffAdd')
          local dchg = hl_get('DiffChange')
          local ddel = hl_get('DiffDelete')
          return {
            black       = fallback.black,
            white       = tohex(sl.fg)    or fallback.white,
            white_dim   = tohex(slnc.fg)  or fallback.white_dim,
            red         = tohex(dfe.fg)   or fallback.red,
            yellow      = tohex(dfw.fg)   or fallback.yellow,
            blue        = tohex(dir.fg)   or fallback.blue,
            cyan        = tohex(id.fg)    or fallback.cyan,
            green       = tohex(str.fg)   or fallback.green,
            diff_add    = tohex(dadd.fg)  or fallback.green,
            diff_change = tohex(dchg.fg)  or fallback.yellow,
            diff_del    = tohex(ddel.fg)  or fallback.red,
            blue_light  = fallback.blue_light,
            mode_ins_bg = tohex(hl_get('DiffAdd').bg)    or 'NONE',
            mode_vis_bg = tohex(hl_get('Visual').bg)     or 'NONE',
            mode_rep_bg = tohex(hl_get('DiffDelete').bg) or 'NONE',
            base_bg     = tohex(sl.bg)   or fallback.black,
            nc_bg       = tohex(slnc.bg) or fallback.black,
          }
        end
        local function colors_assign(dst, src)
          for k, v in pairs(src) do dst[k] = v end
        end

        local colors_fallback = {
          black = 'NONE', white = '#54667a', red = '#970d4f',
          green = '#007a51', blue = '#005faf', yellow = '#c678dd',
          cyan = '#6587b3', blue_light = '#517f8d', white_dim = '#3f5063',
        }
        local colors = themed_colors(colors_fallback)
        local function hl(fg, bg) return { fg = fg, bg = bg } end
        local align = { provider = '%=' }

        -- ── Helpers ────────────────────────────────────────────────────────────────
        local function buf_valid(b) return type(b)=='number' and b>0 and api.nvim_buf_is_valid(b) end
        local function safe_buffer_matches(spec, bufnr)
          if bufnr ~= nil and not buf_valid(bufnr) then return false end
          return c.buffer_matches(spec, bufnr)
        end
        -- Fast width: prefer option when not in evaluation
        local function win_w()
          return (vim.v.evaluating == 1) and api.nvim_win_get_width(0) or vim.o.columns
        end
        local function is_narrow() return win_w() < 80 end
        local function is_tiny() return win_w() < 60 end
        local function is_empty()  return fn.empty(fn.expand('%:t')) == 1 end

        -- Memoized require check
        local _has = {}
        local function has_mod(name)
          local v = _has[name]
          if v ~= nil then return v end
          local ok = pcall(require, name)
          _has[name] = ok
          return ok
        end
        local function notify(msg, lvl)
          if vim.notify then vim.notify(msg, lvl or vim.log.levels.INFO, { title = 'Heirline' }) end
        end

        -- Lazy environment label (can be extended to invalidate on events)
        local _env_cache
        local function env_label()
          if _env_cache then return _env_cache end
          local parts = {}
          if vim.env.SSH_CONNECTION or vim.env.SSH_CLIENT then table.insert(parts, 'SSH') end
          if (fn.has('wsl') == 1) or vim.env.WSLENV then table.insert(parts, 'WSL') end
          if fn.has('gui_running') == 1 then table.insert(parts, 'GUI') end
          local term = vim.env.TERM_PROGRAM or vim.env.TERM or ''
          if term ~= '' then table.insert(parts, term) end
          _env_cache = table.concat(parts, '|')
          return _env_cache
        end

        -- Openers (defensive)
        local function open_file_browser_cwd()
          local cwd = fn.getcwd()
          if has_mod('oil') then
            vim.cmd('Oil ' .. fn.fnameescape(cwd))
            return
          end
          if has_mod('telescope') then
            local ok_ext = pcall(function()
              require('telescope').extensions.file_browser.file_browser({ cwd = cwd, respect_gitignore = true })
            end)
            if ok_ext then return end
            local ok_builtin = pcall(function()
              require('telescope.builtin').find_files({ cwd = cwd, hidden = true })
            end)
            if ok_builtin then return end
          end
          vim.cmd('Ex ' .. fn.fnameescape(cwd))
        end
        local function open_git_ui()
          if has_mod('telescope') then
            local ok = pcall(function() require('telescope.builtin').git_branches() end)
            if ok then return end
          end
          if has_mod('neogit') then return require('neogit').open() end
          if fn.exists(':Git') == 2 then return vim.cmd('Git') end
          notify('No git UI found (telescope/neogit/fugitive not available)', vim.log.levels.WARN)
          dbg_push('git click: no UI')
        end
        local function open_diagnostics_list()
          if has_mod('trouble') then
            local ok = pcall(require('trouble').toggle, { mode = 'document_diagnostics' })
            if not ok then pcall(require('trouble').toggle, { mode = 'workspace_diagnostics' }) end
          else
            pcall(vim.diagnostic.setqflist); vim.cmd('copen')
          end
        end

        -- Runtime toggles
        pcall(api.nvim_del_user_command, 'HeirlineIconsToggle')
        api.nvim_create_user_command('HeirlineIconsToggle', function()
          USE_ICONS = not USE_ICONS
          vim.g.heirline_use_icons = USE_ICONS
          notify('Heirline: icons ' .. (USE_ICONS and 'ON' or 'OFF'))
          vim.cmd('redrawstatus')
        end, {})

        pcall(api.nvim_del_user_command, 'HeirlineThemeToggle')
        api.nvim_create_user_command('HeirlineThemeToggle', function()
          USE_THEME = not USE_THEME
          vim.g.heirline_use_theme_colors = USE_THEME
          local fresh = themed_colors(colors_fallback)
          colors_assign(colors, fresh)
          api.nvim_set_hl(0, 'StatusLine',   { fg = colors.white,     bg = colors.base_bg })
          api.nvim_set_hl(0, 'StatusLineNC', { fg = colors.white_dim, bg = colors.nc_bg })
          notify('Heirline: theme-colors ' .. (USE_THEME and 'ON' or 'OFF'))
          vim.cmd('redrawstatus')
        end, {})

        -- Parts import (defensive)
        local ok_parts, parts_ctor = pcall(require, 'plugins.generic.heirline.components')
        if not ok_parts or type(parts_ctor) ~= 'function' then
          dbg_notify('components module missing or invalid', vim.log.levels.ERROR)
          return
        end
        local parts = parts_ctor({
          api = api,
          fn = fn,
          c = c,
          utils = utils,
          colors = colors,
          S = S,
          prof = prof,
          dbg_push = dbg_push,
          ok_devicons = ok_devicons,
          devicons = devicons,
          USE_ICONS = USE_ICONS,
          SHOW_ENV = SHOW_ENV,
          is_empty = is_empty,
          is_narrow = is_narrow,
          is_tiny = is_tiny,
          open_file_browser_cwd = open_file_browser_cwd,
          open_git_ui = open_git_ui,
          open_diagnostics_list = open_diagnostics_list,
          safe_buffer_matches = safe_buffer_matches,
          notify = notify,
          env_label = env_label,
          hl = hl,
          align = align,
        })
        if type(parts) ~= 'table' or not parts.statusline then
          dbg_notify('components did not return a proper parts table', vim.log.levels.ERROR)
          return
        end
        local statusline = parts.statusline
        local winbar = parts.winbar
        local SPECIAL_FT = parts.SPECIAL_FT

        -- ── Setup ─────────────────────────────────────────────────────────────────
        heir.setup({
          statusline = statusline,
          winbar = winbar,
          opts = {
            disable_winbar_cb = function(args)
              if not (args and buf_valid(args.buf)) then return false end
              local disable = safe_buffer_matches({
                buftype = { 'nofile','prompt','help','quickfix','terminal' },
                filetype = SPECIAL_FT,
              }, args.buf)
              return disable == true
            end,
          },
        })

        -- Sync with theme + autos (use in-place color refresh)
        api.nvim_set_hl(0, 'StatusLine',   { fg = colors.white,     bg = colors.base_bg })
        api.nvim_set_hl(0, 'StatusLineNC', { fg = colors.white_dim, bg = colors.nc_bg })

        api.nvim_create_autocmd('ColorScheme', {
          group = AUG,
          callback = function()
            _hl_cache = {}
            local fresh = themed_colors(colors_fallback)
            colors_assign(colors, fresh)
            api.nvim_set_hl(0, 'StatusLine',   { fg = colors.white,     bg = colors.base_bg })
            api.nvim_set_hl(0, 'StatusLineNC', { fg = colors.white_dim, bg = colors.nc_bg })
            if DEBUG then dbg_notify('colors refreshed from theme') end
          end,
        })

        -- Optional: simple health report (best-effort across nvim versions)
        do
          local health = rawget(vim, 'health') or rawget(vim, 'health')
          local report_ok = health and health.report_ok
          local report_info = health and health.report_info
          if report_ok or report_info then
            pcall(function()
              if report_ok then report_ok('Heirline loaded') end
              if report_info then
                report_info('Icons: ' .. (USE_ICONS and 'enabled' or 'disabled'))
                report_info('Devicons: ' .. (ok_devicons and 'present' or 'missing'))
                report_info('Theme-colors: ' .. tostring(USE_THEME))
              end
            end)
          end
        end

        if DEBUG then dbg_notify('initialized (debug ON)') end
      end)
    end,
  })
end
