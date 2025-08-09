-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ rebelot/heirline.nvim                                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'rebelot/heirline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Defer EVERYTHING to VimEnter + schedule to avoid init races with lazy plugins/UI
    vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = function()
        vim.schedule(function()
          local ok_heir, heir = pcall(require, 'heirline')
          if not ok_heir then return end

          local ok_cond, c = pcall(require, 'heirline.conditions')
          local ok_utils, utils = pcall(require, 'heirline.utils')
          if not ok_cond or not ok_utils then return end

          local api, fn = vim.api, vim.fn
          local devicons = require('nvim-web-devicons')

          -- ── Hidden debug mode ──────────────────────────────────────────────────────
          local DEBUG = (vim.env.HEIRLINE_DEBUG == '1') or (vim.g.heirline_debug == true)
          local DBG_TITLE = 'HeirlineDBG'
          local DBG_MAX = 600
          local dbg_log = {}

          local function dbg_enabled() return DEBUG end

          local function dbg_push(line)
            if not DEBUG then return end
            local msg = string.format('[%s] %s', os.date('%H:%M:%S'), line)
            if #dbg_log >= DBG_MAX then table.remove(dbg_log, 1) end
            table.insert(dbg_log, msg)
          end

          local function dbg_notify(line, lvl)
            if not DEBUG then return end
            dbg_push(line)
            if vim.notify then
              vim.notify(line, lvl or vim.log.levels.DEBUG, { title = DBG_TITLE })
            end
          end

          local function prof(name, fn, threshold_ms)
            if not DEBUG or type(fn) ~= 'function' then return fn end
            local thr = threshold_ms or 5.0
            return function(...)
              local t0 = vim.loop.hrtime()
              local ok, res = pcall(fn, ...)
              local dt = (vim.loop.hrtime() - t0) / 1e6
              if dt > thr then
                dbg_push(string.format('slow provider %-18s  %.2f ms', name, dt))
              end
              if not ok then
                dbg_push(string.format('provider error %-18s  %s', name, tostring(res)))
                return ''
              end
              return res
            end
          end

          -- Commands to control/debug
          api.nvim_create_user_command('HeirlineDebugToggle', function()
            DEBUG = not DEBUG
            vim.g.heirline_debug = DEBUG
            dbg_notify('debug mode: ' .. (DEBUG and 'ON' or 'OFF'))
          end, {})

          api.nvim_create_user_command('HeirlineDebugDump', function()
            local buf = api.nvim_create_buf(false, true)
            api.nvim_buf_set_lines(buf, 0, -1, false, dbg_log)
            api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
            api.nvim_buf_set_option(buf, 'filetype', 'log')
            api.nvim_set_current_buf(buf)
          end, {})

          api.nvim_create_user_command('HeirlineDebugClear', function()
            dbg_log = {}
            dbg_notify('log cleared')
          end, {})

          -- Hook a few autocmds to log state (only in debug)
          if DEBUG then
            api.nvim_create_autocmd({ 'LspAttach', 'LspDetach', 'DiagnosticChanged', 'WinResized' }, {
              callback = function(ev)
                dbg_push('event: ' .. ev.event)
              end,
            })
          end
          -- ───────────────────────────────────────────────────────────────────────────

          -- Palette
          local colors = {
            black = 'NONE', white = '#54667a', red = '#970d4f',
            green = '#007a51', blue = '#005faf', yellow = '#c678dd',
            cyan = '#6587b3', blue_light = '#517f8d', white_dim = '#3f5063',
          }

          local function hl(fg, bg) return { fg = fg, bg = bg } end
          local align = { provider = '%=' }

          -- Helpers (race-safe)
          local function buf_valid(b) return type(b) == "number" and b > 0 and api.nvim_buf_is_valid(b) end
          local function safe_buffer_matches(spec, bufnr)
            if bufnr ~= nil and not buf_valid(bufnr) then return false end
            return c.buffer_matches(spec, bufnr)
          end
          local function is_narrow() return api.nvim_win_get_width(0) < 80 end
          local function is_empty()  return fn.empty(fn.expand('%:t')) == 1 end
          local function has_mod(name) local ok = pcall(require, name); return ok end
          local function notify(msg, lvl)
            if vim.notify then vim.notify(msg, lvl or vim.log.levels.INFO, { title = 'Heirline' }) end
          end

          -- Openers (scheduled)
          local open_file_browser_cwd = function()
            local cwd = fn.getcwd()
            if has_mod('oil') then
              vim.cmd('Oil ' .. fn.fnameescape(cwd))
            elseif has_mod('telescope') and has_mod('telescope._extensions.file_browser') then
              require('telescope').extensions.file_browser.file_browser({ cwd = cwd, respect_gitignore = true })
            elseif has_mod('telescope') then
              require('telescope.builtin').find_files({ cwd = cwd, hidden = true })
            else
              vim.cmd('Ex ' .. fn.fnameescape(cwd))
            end
          end

          local open_git_ui = function()
            if has_mod('telescope') and require('telescope.builtin').git_branches then
              return require('telescope.builtin').git_branches()
            end
            if has_mod('neogit') then return require('neogit').open() end
            if fn.exists(':Git') == 2 then return vim.cmd('Git') end
            notify('No git UI found (telescope/neogit/fugitive not available)', vim.log.levels.WARN)
            if DEBUG then dbg_push('git click: no UI available') end
          end

          local open_diagnostics_list = function()
            if has_mod('trouble') then
              local ok = pcall(require('trouble').toggle, { mode = 'document_diagnostics' })
              if not ok then pcall(require('trouble').toggle, { mode = 'workspace_diagnostics' }) end
            else
              pcall(vim.diagnostic.setqflist)
              vim.cmd('copen')
            end
          end

          -- Special types (expanded)
          local FT_ICON = {
            -- Core buftypes
            help = { '', 'Help' }, quickfix = { '', 'Quickfix' }, terminal = { '', 'Terminal' },
            prompt = { '', 'Prompt' }, nofile = { '', 'Scratch' },

            -- Telescope/fzf
            TelescopePrompt = { '', 'Telescope' }, TelescopeResults = { '', 'Telescope' },
            fzf = { '', 'FZF' }, ['fzf-lua'] = { '', 'FZF' },

            -- File explorers/navigators
            NvimTree = { '', 'Explorer' }, ['neo-tree'] = { '', 'Neo-tree' }, Neotree = { '', 'Neo-tree' },
            oil = { '', 'Oil' }, dirbuf = { '', 'Dirbuf' }, lir = { '', 'Lir' },

            -- Git/diff/rebase
            fugitive = { '', 'Fugitive' }, fugitiveblame = { '', 'Git Blame' },
            DiffviewFiles = { '', 'Diffview' }, DiffviewFileHistory = { '', 'Diffview' },
            gitcommit = { '', 'Commit' }, gitrebase = { '', 'Rebase' }, gitconfig = { '', 'Git Config' },

            -- UI/meta
            lazy = { '󰒲', 'Lazy' }, mason = { '󰏖', 'Mason' }, notify = { '', 'Notify' }, noice = { '', 'Noice' },
            toggleterm = { '', 'Terminal' }, Outline = { '', 'Outline' }, aerial = { '', 'Aerial' },
            ['symbols-outline'] = { '', 'Symbols' }, lspinfo = { '', 'LSP Info' }, checkhealth = { '', 'Health' },
            spectre_panel = { '', 'Spectre' }, OverseerList = { '', 'Overseer' }, Trouble = { '', 'Trouble' },
            qf = { '', 'Quickfix' }, man = { '', 'Man' }, alpha = { '', 'Alpha' }, dashboard = { '', 'Dashboard' },
            Floaterm = { '', 'Terminal' }, startify = { '', 'Startify' }, helpview = { '', 'Help' },
            markdown_preview = { '', 'Preview' }, httpResult = { '', 'HTTP' }, OutlinePanel = { '', 'Outline' },
            neoformat = { '', 'Neoformat' }, undotree = { '', 'Undotree' }, tagbar = { '', 'Tagbar' }, vista = { '', 'Vista' },
            octo = { '', 'Octo' }, harpoon = { '󰛢', 'Harpoon' }, which_key = { '', 'WhichKey' },

            -- DAP
            dapui_scopes = { '', 'DAP Scopes' }, dapui_breakpoints = { '', 'DAP Breakpoints' },
            dapui_stacks = { '', 'DAP Stacks' }, dapui_watches = { '', 'DAP Watches' },
            ['dap-repl'] = { '', 'DAP REPL' }, dapui_console = { '', 'DAP Console' },

            -- Tests/tasks
            ['neotest-summary'] = { '', 'Neotest' }, ['neotest-output'] = { '', 'Neotest' },
            ['neotest-output-panel'] = { '', 'Neotest' }, Overseer = { '', 'Overseer' },

            -- Term wrappers
            FTerm = { '', 'FTerm' }, termwrapper = { '', 'TermWrap' },
          }

          local function ft_label_and_icon()
            local bt, ft = vim.bo.buftype, vim.bo.filetype
            if bt and bt ~= '' then
              local m = FT_ICON[bt]; if m then return m[2], m[1] end; return bt, ''
            end
            if ft and ft ~= '' then
              if ft == 'Neotree' then ft = 'neo-tree' end
              local m = FT_ICON[ft]; if m then return m[2], m[1] end; return ft, ''
            end
            return 'Special', ''
          end

          -- Left (file info)
          local CurrentDir = {
            provider = prof('CurrentDir', function() return fn.fnamemodify(fn.getcwd(), ':~') end),
            hl = hl(colors.white, colors.black),
            update = { 'DirChanged', 'BufEnter' },
            on_click = {
              callback = vim.schedule_wrap(function()
                if DEBUG then dbg_push('click: cwd') end
                open_file_browser_cwd()
              end),
              name = 'heirline_cwd_open',
            },
          }

          local FileIcon = {
            condition = function() return not is_empty() end,
            provider = prof('FileIcon', function()
              local name = fn.expand('%:t')
              local icon = devicons.get_icon(name)
              return icon or ''
            end),
            hl = function()
              local name = fn.expand('%:t')
              local icon, color = devicons.get_icon_color(name, nil, { default = false })
              if icon and color then return { fg = color, bg = colors.black } end
              return hl(colors.cyan, colors.black)
            end,
            update = { 'BufEnter', 'BufFilePost' },
          }

          local Readonly = {
            condition = function() return vim.bo.readonly or not vim.bo.modifiable end,
            provider = ' 🔒',
            hl = hl(colors.blue, colors.black),
            update = { 'OptionSet', 'BufEnter' },
          }

          local FileNameClickable = {
            provider = prof('FileName', function() return ' ' .. fn.expand('%:t') end),
            hl = hl(colors.white, colors.black),
            update = { 'BufEnter', 'BufFilePost' },
            on_click = {
              callback = vim.schedule_wrap(function()
                local path = fn.expand('%:p'); if path == '' then return end
                pcall(fn.setreg, '+', path); notify('Copied path: ' .. path)
                if DEBUG then dbg_push('click: filename -> copied path') end
              end),
              name = 'heirline_copy_abs_path',
            },
          }

          local LeftComponents = {
            condition = function() return not is_empty() end,
            { provider = ' ', hl = hl(colors.blue, colors.black) },
            CurrentDir,
            { provider = ' ¦ ', hl = hl(colors.blue, colors.black) },
            FileIcon,
            FileNameClickable,
            Readonly,
            {
              condition = function() return vim.bo.modified end,
              provider = ' ',
              hl = hl(colors.blue, colors.black),
              update = { 'BufWritePost', 'TextChanged', 'TextChangedI', 'BufModifiedSet' },
            },
          }

          -- Small toggles
          local ListToggle = {
            provider = function() return ' ¶' end,
            hl = function() return hl(vim.wo.list and colors.yellow or colors.white, colors.black) end,
            update = { 'OptionSet', 'BufWinEnter' },
            on_click = {
              callback = vim.schedule_wrap(function()
                vim.o.list = not vim.o.list
                if DEBUG then dbg_push('toggle: list -> ' .. tostring(vim.o.list)) end
              end),
              name = 'heirline_toggle_list',
            },
          }

          local WrapToggle = {
            provider = function() return ' ⤶' end,
            hl = function() return hl(vim.wo.wrap and colors.yellow or colors.white, colors.black) end,
            update = { 'OptionSet', 'BufWinEnter' },
            on_click = {
              callback = vim.schedule_wrap(function()
                vim.wo.wrap = not vim.wo.wrap
                if DEBUG then dbg_push('toggle: wrap -> ' .. tostring(vim.wo.wrap)) end
              end),
              name = 'heirline_toggle_wrap',
            },
          }

          -- Right-side components
          local function human_size()
            local size = fn.getfsize(fn.expand('%:p'))
            if size <= 0 then return '' end
            local i, suffix = 1, { 'B', 'K', 'M', 'G', 'T', 'P' }
            while size >= 1024 and i < #suffix do size = size / 1024; i = i + 1 end
            if i == 1 then return string.format('%d%s ', size, suffix[i]) end
            local fmt = (i <= 3) and '%.1f%s ' or '%.2f%s '
            return string.format(fmt, size, suffix[i])
          end

          local components = {
            macro = {
              condition = function() return fn.reg_recording() ~= '' end,
              provider = prof('macro', function() return '  REC @' .. fn.reg_recording() .. ' ' end),
              hl = hl(colors.red, colors.black),
              update = { 'RecordingEnter', 'RecordingLeave' },
            },

            diag = {
              condition = function() return c.has_diagnostics() and not is_narrow() end,
              init = function(self)
                self.errors   = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
              end,
              update = { 'DiagnosticChanged', 'BufEnter', 'BufNew', 'WinResized' },
              {
                provider = prof('diag.errors', function(self) return (self.errors or 0) > 0 and (' ' .. self.errors .. ' ') or '' end),
                hl = hl(colors.red, colors.black),
              },
              {
                provider = prof('diag.warns', function(self) return (self.warnings or 0) > 0 and (' ' .. self.warnings .. ' ') or '' end),
                hl = hl(colors.yellow, colors.black),
              },
              on_click = {
                callback = vim.schedule_wrap(function(_, _, _, button)
                  if DEBUG then dbg_push('click: diagnostics (' .. tostring(button) .. ')') end
                  if button == 'l' then open_diagnostics_list()
                  elseif button == 'm' then pcall(vim.diagnostic.goto_next)
                  elseif button == 'r' then pcall(vim.diagnostic.goto_prev)
                  end
                end),
                name = 'heirline_diagnostics_click',
              },
            },

            lsp = {
              condition = c.lsp_attached,
              provider = '  ',
              hl = hl(colors.cyan, colors.black),
              on_click = { callback = vim.schedule_wrap(function()
                if DEBUG then dbg_push('click: lsp') end
                vim.cmd('LspInfo')
              end), name = 'heirline_lsp_info' },
              update = { 'LspAttach', 'LspDetach' },
            },

            git = {
              condition = function() return c.is_git_repo() and not is_narrow() end,
              provider = prof('git', function()
                if vim.b.gitsigns_head == nil then return '' end
                local head = vim.b.gitsigns_head or ''
                if head == '' then return '' end
                return '  ' .. head .. ' '
              end),
              hl = hl(colors.blue, colors.black),
              update = { 'BufEnter', 'BufWritePost', 'WinResized' },
              on_click = { callback = vim.schedule_wrap(function() if DEBUG then dbg_push('click: git') end; open_git_ui() end), name = 'heirline_git_ui' },
            },

            encoding = {
              provider = prof('encoding', function()
                local enc = (vim.bo.fileencoding ~= '' and vim.bo.fileencoding) or vim.o.encoding or 'utf-8'
                enc = enc:lower()
                local enc_icon = (enc == 'utf-8') and '' or ''
                local fmt = vim.bo.fileformat
                local os_icon = ({ unix = '', dos = '', mac = '' })[fmt] or ''
                return string.format(' %s %s ', os_icon, enc_icon)
              end),
              hl = hl(colors.cyan, colors.black),
              update = { 'OptionSet', 'BufEnter' },
            },

            size = {
              condition = function() return not is_empty() and not is_narrow() end,
              provider = prof('size', function() return human_size() end),
              hl = hl(colors.white, colors.black),
              update = { 'BufEnter', 'BufWritePost', 'WinResized' },
              on_click = {
                callback = vim.schedule_wrap(function()
                  if DEBUG then dbg_push('click: size -> buffer fuzzy find') end
                  if has_mod('telescope.builtin') then
                    require('telescope.builtin').current_buffer_fuzzy_find()
                  end
                end),
                name = 'heirline_size_click',
              },
            },

            search = {
              condition = function() return vim.v.hlsearch == 1 end,
              provider = prof('search', function()
                local ok_sc, s = pcall(fn.searchcount, { recompute = 1, maxcount = 1000 })
                local pattern = fn.getreg('/')
                if not pattern or pattern == '' or not ok_sc then return '' end
                if #pattern > 15 then pattern = pattern:sub(1, 12) .. '...' end
                local cur = (s and s.current) or 0
                local tot = (s and s.total)   or 0
                if tot == 0 then return '' end
                return string.format('  %s %d/%d ', pattern, cur, tot)
              end),
              hl = hl(colors.yellow, colors.black),
              update = { 'CmdlineLeave', 'CursorMoved', 'CursorMovedI' },
              on_click = { callback = vim.schedule_wrap(function()
                if DEBUG then dbg_push('click: search -> nohlsearch') end
                pcall(vim.cmd, 'nohlsearch')
              end), name = 'heirline_search_clear' },
            },

            position = {
              provider = prof('position', function()
                local lnum = fn.line('.'); local col = fn.virtcol('.')
                local last = math.max(1, fn.line('$'))
                local pct  = math.floor(lnum * 100 / last)
                return string.format(' %3d:%-2d %3d%% ', lnum, col, pct)
              end),
              hl = hl(colors.white, colors.black),
              update = { 'CursorMoved', 'CursorMovedI' },
            },

            toggles = { ListToggle, WrapToggle },
          }

          -- Special buffer statusline (massive list, race-safe)
          local SpecialBuffer = {
            condition = function()
              return safe_buffer_matches({
                buftype = { 'help','quickfix','terminal','prompt','nofile' },
                filetype = {
                  -- Core/meta
                  'qf','help','man','lspinfo','checkhealth','undotree','tagbar','vista','which_key',
                  -- Telescope/fzf
                  'TelescopePrompt','TelescopeResults','fzf','fzf%-lua',
                  -- Explorers
                  'NvimTree','neo%-tree','Neotree','oil','dirbuf','lir',
                  -- Git/diff
                  '^git.*','fugitive','fugitiveblame','DiffviewFiles','DiffviewFileHistory','gitcommit','gitrebase','gitconfig',
                  -- UI/meta
                  'lazy','mason','notify','noice','toggleterm','Outline','aerial','symbols%-outline',
                  'spectre_panel','OverseerList','Trouble','alpha','dashboard','startify','helpview',
                  'markdown_preview','httpResult','OutlinePanel','octo','harpoon','neoformat',
                  -- DAP
                  'dapui_scopes','dapui_breakpoints','dapui_stacks','dapui_watches','dap%-repl','dapui_console',
                  -- Tests/tasks
                  'neotest%-summary','neotest%-output','neotest%-output%-panel','Overseer',
                  -- Term wrappers
                  'Floaterm','FTerm','termwrapper','terminal',
                },
              })
            end,

            hl = hl(colors.white, colors.black),

            {
              provider = prof('special.label', function()
                local label, icon = ft_label_and_icon()
                return string.format(' %s %s', icon or '', label or 'Special')
              end),
              hl = hl(colors.cyan, colors.black),
            },

            { provider = '%=' },

            {
              condition = function() return not is_empty() end,
              provider = prof('special.filename', function() return ' ' .. fn.fnamemodify(fn.expand('%:t'), ':t') .. ' ' end),
              hl = hl(colors.white, colors.black),
              on_click = {
                callback = vim.schedule_wrap(function()
                  local path = fn.expand('%:p'); if path == '' then return end
                  pcall(fn.setreg, '+', path); notify('Copied path: ' .. path)
                  if DEBUG then dbg_push('click: special filename -> copied path') end
                end),
                name = 'heirline_special_copy_path',
              },
            },

            {
              provider = '  ',
              hl = hl(colors.red, colors.black),
              on_click = { callback = vim.schedule_wrap(function()
                if DEBUG then dbg_push('click: close buffer') end
                vim.cmd('bd!') end),
                name = 'heirline_close_buf' },
            },
          }

          -- Default (full) statusline
          local DefaultStatusline = {
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
              components.toggles,
            },
          }

          -- Winbar
          local Winbar = {
            fallthrough = false,
            {
              condition = function() return vim.bo.buftype == '' end,
              utils.surround({ ' ', ' ' }, colors.black, {
                provider = prof('winbar.path', function()
                  local p = fn.expand('%:~:.')
                  local parts = vim.split(p, '/', { plain = true })
                  if #parts > 3 and api.nvim_win_get_width(0) >= 90 then
                    for i = 1, #parts - 2 do parts[i] = parts[i]:sub(1, 1) end
                    p = table.concat(parts, '/')
                  else
                    p = fn.pathshorten(p)
                  end
                  return p
                end),
                hl = hl(colors.white, colors.black),
              }),
            },
            {
              provider = prof('winbar.special', function()
                local label, icon = ft_label_and_icon()
                return string.format(' %s %s ', icon or '', label or 'Special')
              end),
              hl = hl(colors.yellow, colors.black),
            },
          }

          -- Setup (race-safe disable callback)
          heir.setup({
            statusline = {
              fallthrough = false,
              SpecialBuffer,
              DefaultStatusline,
            },
            winbar = Winbar,
            opts = {
              disable_winbar_cb = function(args)
                if not (args and buf_valid(args.buf)) then return false end
                return safe_buffer_matches({
                  buftype = { 'nofile','prompt','help','quickfix','terminal' },
                  filetype = {
                    '^git.*','fugitive','TelescopePrompt','TelescopeResults',
                    'lazy','mason','alpha','dashboard','fzf','fzf%-lua',
                  },
                }, args.buf)
              end,
            },
          })

          -- Dim NC a bit
          api.nvim_set_hl(0, 'StatusLine',   hl(colors.white, colors.black))
          api.nvim_set_hl(0, 'StatusLineNC', hl(colors.white_dim, colors.black))

          -- Final ping
          if dbg_enabled() then dbg_notify('initialized (debug ON)') end
        end)
      end,
    })
  end,
}
