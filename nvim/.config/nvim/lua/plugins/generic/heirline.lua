-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ rebelot/heirline.nvim                                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'rebelot/heirline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = function()
        vim.schedule(function()
          local ok_heir, heir = pcall(require, 'heirline'); if not ok_heir then return end
          local ok_cond, c = pcall(require, 'heirline.conditions')
          local ok_utils, utils = pcall(require, 'heirline.utils')
          if not ok_cond or not ok_utils then return end

          local api, fn = vim.api, vim.fn
          local ok_devicons, devicons = pcall(require, 'nvim-web-devicons')

          -- ── Hidden debug ──────────────────────────────────────────────────────────
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
              local t0 = vim.loop.hrtime()
              local ok, res = pcall(f, ...)
              local dt = (vim.loop.hrtime() - t0) / 1e6
              if dt > T then dbg_push(string.format('slow %-18s %.2f ms', name, dt)) end
              if not ok then dbg_push(string.format('err  %-18s %s', name, tostring(res))); return '' end
              return res
            end
          end
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
              callback = function(ev) dbg_push('event: ' .. ev.event) end,
            })
          end

          -- ── Compat toggles & symbols ──────────────────────────────────────────────
          local USE_ICONS = vim.g.heirline_use_icons
          if USE_ICONS == nil then
            USE_ICONS = not (vim.env.NERD_FONT == '0') and (vim.g.have_nerd_font == true or true)
          end
          local SHOW_ENV = vim.g.heirline_env_indicator == true
          local USE_THEME = vim.g.heirline_use_theme_colors
          if USE_THEME == nil then USE_THEME = true end

          local function I(icons, ascii) return USE_ICONS and icons or ascii end
          local S = {
            folder   = I('','[dir]'),
            sep      = I(' ¦ ',' | '),
            modified = I(' ',' *'),
            lock     = I(' 🔒',' RO'),
            search   = I('  ',' / '),
            rec      = I(' ','REC'),
            gear     = I('  ',' [LSP] '),
            branch   = I('  ',' [git] '),
            close    = I('  ',' [x] '),
            err      = I(' ','E:'),
            warn     = I(' ','W:'),
            utf8     = I('','utf8'),
            latin    = I('','enc'),
            linux    = I('','unix'),
            mac      = I('','mac'),
            win      = I('','dos'),
            pilcrow  = I(' ¶',' ¶'),
            wrap     = I(' ⤶',' ↩'),
            doc      = I('','[buf]'),
            plus     = I('','+'),
            tilde    = I('󰜥','~'),
            minus    = I('','-'),
          }

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
          local function tohex(n) if not n then return nil end; return string.format("#%06x", n) end
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
          local function win_w() return api.nvim_win_get_width(0) end
          local function is_narrow() return win_w() < 80 end
          local function is_tiny() return win_w() < 60 end
          local function is_empty()  return fn.empty(fn.expand('%:t')) == 1 end
          local function has_mod(name) local ok = pcall(require, name); return ok end
          local function notify(msg, lvl)
            if vim.notify then vim.notify(msg, lvl or vim.log.levels.INFO, { title = 'Heirline' }) end
          end

          local function env_label()
            local parts = {}
            if vim.env.SSH_CONNECTION or vim.env.SSH_CLIENT then table.insert(parts, 'SSH') end
            if (fn.has('wsl') == 1) or vim.env.WSLENV then table.insert(parts, 'WSL') end
            if fn.has('gui_running') == 1 then table.insert(parts, 'GUI') end
            local term = vim.env.TERM_PROGRAM or vim.env.TERM or ''
            if term ~= '' then table.insert(parts, term) end
            return table.concat(parts, '|')
          end

          -- Openers
          local function open_file_browser_cwd()
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
          local function open_git_ui()
            if has_mod('telescope') and require('telescope.builtin').git_branches then
              return require('telescope.builtin').git_branches()
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

          -- ── Special types (icons) ─────────────────────────────────────────────────
          local FT_ICON = {
            help={'','Help'}, quickfix={'','Quickfix'}, terminal={'','Terminal'}, prompt={'','Prompt'}, nofile={'','Scratch'},
            TelescopePrompt={'','Telescope'}, TelescopeResults={'','Telescope'},
            fzf={'','FZF'}, ['fzf-lua']={'','FZF'}, ['fzf-checkmarks']={'','FZF'},
            ['grug-far']={'󰈞','GrugFar'}, Spectre={'','Spectre'}, spectre_panel={'','Spectre'}, ['spectre-replace']={'','Spectre'},
            NvimTree={'','Explorer'}, ['neo-tree']={'','Neo-tree'}, Neotree={'','Neo-tree'}, ['neo-tree-popup']={'','Neo-tree'},
            oil={'','Oil'}, dirbuf={'','Dirbuf'}, lir={'','Lir'}, fern={'','Fern'}, chadtree={'','CHADTree'},
            defx={'','Defx'}, ranger={'','Ranger'}, vifm={'','Vifm'}, minifiles={'','MiniFiles'}, mf={'','MiniFiles'},
            vaffle={'','Vaffle'}, netrw={'','Netrw'}, explore={'','Explore'}, dirvish={'','Dirvish'}, yazi={'','Yazi'},
            fugitive={'','Fugitive'}, fugitiveblame={'','Git Blame'},
            DiffviewFiles={'','Diffview'}, DiffviewFileHistory={'','Diffview'},
            gitcommit={'','Commit'}, gitrebase={'','Rebase'}, gitconfig={'','Git Config'},
            NeogitCommitMessage={'','Neogit'}, NeogitStatus={'','Neogit'}, gitgraph={'','GitGraph'},
            gitstatus={'','GitStatus'}, lazygit={'','LazyGit'}, gitui={'','GitUI'},
            lazy={'󰒲','Lazy'}, mason={'󰏖','Mason'}, notify={'','Notify'}, noice={'','Noice'},
            ['noice-log']={'','Noice'}, ['noice-history']={'','Noice'},
            toggleterm={'','Terminal'}, Floaterm={'','Terminal'}, FTerm={'','FTerm'}, termwrapper={'','TermWrap'},
            Outline={'','Outline'}, aerial={'','Aerial'}, ['symbols-outline']={'','Symbols'}, OutlinePanel={'','Outline'},
            lspinfo={'','LSP Info'}, checkhealth={'','Health'}, OverseerList={'','Overseer'}, Overseer={'','Overseer'},
            Trouble={'','Trouble'}, ['trouble']={'','Trouble'},
            alpha={'','Alpha'}, dashboard={'','Dashboard'}, startify={'','Startify'}, ['start-screen']={'','Start'},
            helpview={'','Help'}, todo_comments={'','TODO'}, comment_box={'','CommentBox'},
            markdown_preview={'','Preview'}, glow={'','Glow'}, peek={'','Peek'},
            httpResult={'','HTTP'}, ['rest-nvim']={'','REST'},
            neoformat={'','Neoformat'}, undotree={'','Undotree'}, tagbar={'','Tagbar'}, vista={'','Vista'},
            octo={'','Octo'}, harpoon={'󰛢','Harpoon'}, which_key={'','WhichKey'},
            snacks_dashboard={'','Dashboard'}, snacks_notifier={'','Notify'}, snacks_indent={'','Indent'},
            zen_mode={'','Zen'}, goyo={'','Goyo'}, twilight={'','Twilight'},
            SagaOutline={'','Lspsaga'}, saga_codeaction={'','Code Action'}, SagaRename={'','Rename'},
            ['lspsaga-code-action']={'','Code Action'}, ['lspsaga-outline']={'','Lspsaga'},
            conform_info={'','Conform'}, ['null-ls-info']={'','Null-LS'}, ['diagnostic-navigator']={'','Diagnostics'},
            dapui_scopes={'','DAP Scopes'}, dapui_breakpoints={'','DAP Breakpoints'},
            dapui_stacks={'','DAP Stacks'}, dapui_watches={'','DAP Watches'},
            ['dap-repl']={'','DAP REPL'}, dapui_console={'','DAP Console'}, dapui_hover={'','DAP Hover'},
            dap_floating={'','DAP Float'},
            ['neotest-summary']={'','Neotest'}, ['neotest-output']={'','Neotest'}, ['neotest-output-panel']={'','Neotest'},
            copilot={'','Copilot'}, ['copilot-chat']={'','Copilot Chat'},
            ['vim-plug']={'','vim-plug'},
          }

          local function build_special_list()
            local base = {
              'qf','help','man','lspinfo','checkhealth','undotree','tagbar','vista','which_key',
              'TelescopePrompt','TelescopeResults','fzf','fzf%-lua','fzf%-checkmarks','grug%-far','Spectre','spectre_panel','spectre%-replace',
              'NvimTree','neo%-tree','Neotree','neo%-tree%-popup','oil','dirbuf','lir','fern','chadtree','defx','ranger','vifm','minifiles','mf','vaffle','netrw','explore','dirvish','yazi',
              '^git.*','fugitive','fugitiveblame','DiffviewFiles','DiffviewFileHistory','gitcommit','gitrebase','gitconfig',
              'NeogitCommitMessage','NeogitStatus','gitgraph','gitstatus','lazygit','gitui',
              'lazy','mason','notify','noice','noice%-log','noice%-history','toggleterm','Floaterm','FTerm','termwrapper',
              'Outline','aerial','symbols%-outline','OutlinePanel','OverseerList','Overseer','Trouble','trouble',
              'alpha','dashboard','startify','start%-screen','helpview','todo%-comments','comment%-box',
              'markdown_preview','glow','peek',
              'httpResult','rest%-nvim','neoformat','snacks_dashboard','snacks_notifier','snacks_indent','zen_mode','goyo','twilight',
              'SagaOutline','saga_codeaction','SagaRename','lspsaga%-code%-action','lspsaga%-outline','conform_info','null%-ls%-info','diagnostic%-navigator',
              'dapui_scopes','dapui_breakpoints','dapui_stacks','dapui_watches','dap%-repl','dapui_console','dapui_hover','dap_floating',
              'neotest%-summary','neotest%-output','neotest%-output%-panel',
              'copilot','copilot%-chat','vim%-plug',
              'terminal',
            }
            local extra = vim.g.heirline_special_ft_extra
            if type(extra) == 'table' then for _, pat in ipairs(extra) do table.insert(base, pat) end end
            return base
          end
          local SPECIAL_FT = build_special_list()

          local function ft_label_and_icon()
            local bt, ft = vim.bo.buftype, vim.bo.filetype
            if bt ~= '' then
              local m=FT_ICON[bt]; if m then return m[2], (USE_ICONS and m[1] or '['..m[2]..']') end
              return bt, '['..bt..']'
            end
            if ft ~= '' then
              if ft=='Neotree' then ft='neo-tree' end
              local m=FT_ICON[ft]; if m then return m[2], (USE_ICONS and m[1] or '['..m[2]..']') end
              return ft, '['..ft..']'
            end
            return 'Special','[special]'
          end

          -- ── Smart truncation helpers ───────────────────────────────────────────────
          local function truncate_filename(name, max)
            if #name <= max then return name end
            local base, ext = name:match('^(.*)%.([^.]+)$')
            if not base then return name:sub(1, math.max(3, max-1)) .. '…' end
            local keep = math.max(3, max - (#ext + 2))
            return base:sub(1, keep) .. '….' .. ext
          end
          local function adapt_fname(max_hint)
            local w = api.nvim_win_get_width(0)
            local max = max_hint or math.max(10, math.floor(w * 0.25))
            local n = fn.expand('%:t')
            return ' ' .. truncate_filename(n, max)
          end

          -- ── Left (file info) ──────────────────────────────────────────────────────
          local _icon_color_cache = {}
          local CurrentDir = {
            provider = prof('CurrentDir', function() return fn.fnamemodify(fn.getcwd(), ':~') end),
            hl = function() return { fg = colors.white, bg = colors.base_bg } end,
            update = { 'DirChanged', 'BufEnter' },
            on_click = { callback = vim.schedule_wrap(function() dbg_push('click: cwd'); open_file_browser_cwd() end), name = 'heirline_cwd_open' },
          }
          local FileIcon = {
            condition = function() return not is_empty() end,
            provider = prof('FileIcon', function()
              local name = fn.expand('%:t')
              if ok_devicons and USE_ICONS then
                return devicons.get_icon(name) or S.doc
              end
              return S.doc
            end),
            hl = function()
              if not ok_devicons or not USE_ICONS then return { fg = colors.cyan, bg = colors.base_bg } end
              local name = fn.expand('%:t')
              if _icon_color_cache[name] then
                return { fg = _icon_color_cache[name], bg = colors.base_bg }
              end
              local _, color = devicons.get_icon_color(name, nil, { default = false })
              if color then _icon_color_cache[name] = color; return { fg = color, bg = colors.base_bg } end
              return { fg = colors.cyan, bg = colors.base_bg }
            end,
            update = { 'BufEnter', 'BufFilePost' },
          }
          local Readonly = {
            condition = function() return vim.bo.readonly or not vim.bo.modifiable end,
            provider = S.lock,
            hl = function() return { fg = colors.blue, bg = colors.base_bg } end,
            update = { 'OptionSet', 'BufEnter' },
          }
          local FileNameClickable = {
            provider = prof('FileName', function() return adapt_fname() end),
            hl = function() return { fg = colors.white, bg = colors.base_bg } end,
            update = { 'BufEnter', 'BufFilePost', 'WinResized' },
            on_click = { callback = vim.schedule_wrap(function()
              local path = fn.expand('%:p'); if path == '' then return end
              pcall(fn.setreg, '+', path); notify('Copied path: ' .. path); dbg_push('click: filename -> copied path')
            end), name = 'heirline_copy_abs_path' },
          }
          local LeftComponents = {
            condition = function() return not is_empty() end,
            { provider = S.folder .. ' ', hl = function() return { fg = colors.blue, bg = colors.base_bg } end },
            CurrentDir,
            { provider = S.sep, hl = function() return { fg = colors.blue, bg = colors.base_bg } end },
            FileIcon,
            FileNameClickable,
            Readonly,
            {
              condition = function() return vim.bo.modified end,
              provider = S.modified,
              hl = function() return { fg = colors.blue, bg = colors.base_bg } end,
              update = { 'BufWritePost', 'TextChanged', 'TextChangedI', 'BufModifiedSet' },
            },
          }

          -- ── Small toggles ─────────────────────────────────────────────────────────
          local ListToggle = {
            provider = function() return S.pilcrow end,
            hl = function() return { fg = (vim.wo.list and colors.yellow or colors.white), bg = colors.base_bg } end,
            update = { 'OptionSet', 'BufWinEnter' },
            on_click = { callback = vim.schedule_wrap(function() vim.o.list = not vim.o.list; dbg_push('toggle: list -> '..tostring(vim.o.list)) end), name = 'heirline_toggle_list' },
          }
          local WrapToggle = {
            provider = function() return S.wrap end,
            hl = function() return { fg = (vim.wo.wrap and colors.yellow or colors.white), bg = colors.base_bg } end,
            update = { 'OptionSet', 'BufWinEnter' },
            on_click = { callback = vim.schedule_wrap(function() vim.wo.wrap = not vim.wo.wrap; dbg_push('toggle: wrap -> '..tostring(vim.wo.wrap)) end), name = 'heirline_toggle_wrap' },
          }

          -- ── Format panel (tabs/spaces, ts, sw) ────────────────────────────────────
          local function fmt_icon()
            return vim.bo.expandtab and 'Spaces' or 'Tabs'
          end
          local FormatPanel = {
            {
              provider = function() return ' ' .. fmt_icon() .. ' ' end,
              hl = function() return { fg = colors.cyan, bg = colors.base_bg } end,
              on_click = { callback = vim.schedule_wrap(function()
                vim.bo.expandtab = not vim.bo.expandtab
                dbg_push('toggle: expandtab -> '..tostring(vim.bo.expandtab))
              end), name = 'heirline_fmt_toggle_et' },
            },
            {
              provider = function() return 'ts=' .. vim.bo.tabstop .. ' ' end,
              hl = function() return { fg = colors.white, bg = colors.base_bg } end,
              on_click = { callback = vim.schedule_wrap(function()
                local ts = vim.bo.tabstop
                local cycle = {2, 4, 8}
                local idx = 1
                for i,v in ipairs(cycle) do if v == ts then idx = i end end
                idx = (idx % #cycle) + 1
                vim.bo.tabstop = cycle[idx]
                dbg_push('cycle: tabstop -> '..vim.bo.tabstop)
              end), name = 'heirline_fmt_cycle_ts' },
            },
            {
              provider = function() return 'sw=' .. vim.bo.shiftwidth .. ' ' end,
              hl = function() return { fg = colors.white, bg = colors.base_bg } end,
              on_click = { callback = vim.schedule_wrap(function()
                local sw = vim.bo.shiftwidth
                local cycle = {2, 4, 8}
                local idx = 1
                for i,v in ipairs(cycle) do if v == sw then idx = i end end
                idx = (idx % #cycle) + 1
                vim.bo.shiftwidth = cycle[idx]
                dbg_push('cycle: shiftwidth -> '..vim.bo.shiftwidth)
              end), name = 'heirline_fmt_cycle_sw' },
            },
          }

          -- ── Right-side helpers ────────────────────────────────────────────────────
          local function human_size()
            local size = fn.getfsize(fn.expand('%:p')); if size <= 0 then return '' end
            local i, suffix = 1, { 'B','K','M','G','T','P' }
            while size >= 1024 and i < #suffix do size = size/1024; i=i+1 end
            if i == 1 then return string.format('%d%s ', size, suffix[i]) end
            return string.format((i<=3) and '%.1f%s ' or '%.2f%s ', size, suffix[i])
          end
          local function os_icon()
            if not USE_ICONS then
              return ({ unix='unix ', mac='mac ', dos='dos ' })[vim.bo.fileformat] or 'unix '
            end
            return ({ unix=S.linux, mac=S.mac, dos=S.win })[vim.bo.fileformat] .. ' '
          end
          local function enc_icon()
            local enc = (vim.bo.fileencoding ~= '' and vim.bo.fileencoding) or vim.o.encoding or 'utf-8'
            enc = enc:lower()
            return (enc == 'utf-8') and (S.utf8 .. ' ') or (S.latin .. ' ')
          end

          -- Search debounce
          local SEARCH_DEBOUNCE_MS = 90
          local last_sc = { t = 0, out = '', pat = '', cur = 0, tot = 0 }
          local function now_ms() return math.floor(vim.loop.hrtime() / 1e6) end

          -- ── Mode pill ─────────────────────────────────────────────────────────────
          local function mode_info()
            local m = vim.fn.mode(1)
            if m:match('^i') then return 'INSERT', colors.mode_ins_bg, 'I'
            elseif m:match('^v') or m == 'V' or m == '\22' then return 'VISUAL', colors.mode_vis_bg, 'V'
            elseif m:match('^R') then return 'REPLACE', colors.mode_rep_bg, 'R'
            else return 'NORMAL', colors.base_bg, 'N' end
          end
          local ModePill = {
            init = function(self)
              self.label, self.bg, self.short = mode_info()
            end,
            provider = function(self)
              if is_tiny() then return ' ' .. self.short .. ' ' end
              return ' ' .. self.label .. ' '
            end,
            hl = function(self) return { fg = colors.white, bg = self.bg } end,
            update = { 'ModeChanged', 'WinEnter' },
          }

          -- ── Macro timer state ─────────────────────────────────────────────────────
          local macro_start = nil
          api.nvim_create_autocmd('RecordingEnter', {
            callback = function() macro_start = vim.loop.hrtime() end,
          })
          api.nvim_create_autocmd('RecordingLeave', {
            callback = function() macro_start = nil end,
          })
          local function macro_elapsed()
            if not macro_start then return '00:00' end
            local s = (vim.loop.hrtime() - macro_start) / 1e9
            local mm = math.floor(s / 60)
            local ss = math.floor(s % 60)
            return string.format('%02d:%02d', mm, ss)
          end

          -- ── Components ────────────────────────────────────────────────────────────
          local components = {
            macro = {
              condition = function() return fn.reg_recording() ~= '' end,
              provider = prof('macro', function()
                return ' ' .. S.rec .. ' @' .. fn.reg_recording() .. ' ' .. macro_elapsed() .. ' '
              end),
              hl = function() return { fg = colors.red, bg = colors.base_bg } end,
              update = { 'RecordingEnter', 'RecordingLeave', 'CursorHold', 'CursorHoldI' },
            },

            diag = {
              condition = function() return c.has_diagnostics() and not is_narrow() end,
              init = function(self)
                self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
              end,
              update = { 'DiagnosticChanged', 'BufEnter', 'BufNew', 'WinResized' },
              {
                provider = prof('diag.errors', function(self) return (self.errors or 0) > 0 and (S.err .. self.errors .. ' ') or '' end),
                hl = function() return { fg = colors.red, bg = colors.base_bg } end,
              },
              {
                provider = prof('diag.warns', function(self) return (self.warnings or 0) > 0 and (S.warn .. self.warnings .. ' ') or '' end),
                hl = function() return { fg = colors.yellow, bg = colors.base_bg } end,
              },
              on_click = { callback = vim.schedule_wrap(function(_,_,_,button)
                dbg_push('click: diagnostics ('..tostring(button)..')')
                if button == 'l' then open_diagnostics_list()
                elseif button == 'm' then pcall(vim.diagnostic.goto_next)
                elseif button == 'r' then pcall(vim.diagnostic.goto_prev)
                end
              end), name = 'heirline_diagnostics_click' },
            },

            lsp = {
              condition = c.lsp_attached,
              provider = S.gear,
              hl = function() return { fg = colors.cyan, bg = colors.base_bg } end,
              on_click = { callback = vim.schedule_wrap(function() dbg_push('click: lsp'); vim.cmd('LspInfo') end), name = 'heirline_lsp_info' },
              update = { 'LspAttach', 'LspDetach' },
            },

            lsp_progress = {
              condition = function() return c.lsp_attached end,
              init = function(self)
                self.frames = { '⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏' }
                self.idx = (self.idx or 0) + 1
                if self.idx > #self.frames then self.idx = 1 end
                local msgs = {}
                if vim.lsp and vim.lsp.util and vim.lsp.util.get_progress_messages then
                  for _, m in ipairs(vim.lsp.util.get_progress_messages()) do
                    local title = m.title or m.message or ''
                    local pct = m.percentage and (m.percentage .. '%%') or ''
                    if title ~= '' then table.insert(msgs, (pct ~= '' and (title .. ' ' .. pct) or title)) end
                  end
                end
                self.text = table.concat(msgs, ' | ')
              end,
              provider = function(self)
                if self.text == nil or self.text == '' then return '' end
                return string.format(' %s %s ', self.frames[self.idx], self.text)
              end,
              hl = function() return { fg = colors.blue_light, bg = colors.base_bg } end,
              update = { 'LspAttach', 'LspDetach', 'CursorHold', 'CursorHoldI' },
            },

            git = {
              condition = function() return c.is_git_repo() and not is_narrow() end,
              provider = prof('git', function()
                if vim.b.gitsigns_head == nil then return '' end
                local head = vim.b.gitsigns_head or ''
                if head == '' then return '' end
                return S.branch .. head .. ' '
              end),
              hl = function() return { fg = colors.blue, bg = colors.base_bg } end,
              update = { 'BufEnter', 'BufWritePost', 'WinResized' },
              on_click = { callback = vim.schedule_wrap(function() dbg_push('click: git'); open_git_ui() end), name = 'heirline_git_ui' },
            },

            gitdiff = {
              condition = function() return c.is_git_repo() and not is_narrow() end,
              init = function(self)
                local d = vim.b.gitsigns_status_dict or {}
                self.added = d.added or 0
                self.changed = d.changed or 0
                self.removed = d.removed or 0
              end,
              update = { 'BufEnter', 'BufWritePost', 'User', 'WinResized' },
              {
                condition = function(self) return (self.added or 0) > 0 end,
                provider  = function(self) return ' ' .. S.plus .. ' ' .. self.added .. ' ' end,
                hl        = function() return { fg = colors.diff_add, bg = colors.base_bg } end,
              },
              {
                condition = function(self) return (self.changed or 0) > 0 end,
                provider  = function(self) return S.tilde .. ' ' .. self.changed .. ' ' end,
                hl        = function() return { fg = colors.diff_change, bg = colors.base_bg } end,
              },
              {
                condition = function(self) return (self.removed or 0) > 0 end,
                provider  = function(self) return S.minus .. ' ' .. self.removed .. ' ' end,
                hl        = function() return { fg = colors.diff_del, bg = colors.base_bg } end,
              },
              on_click = { callback = vim.schedule_wrap(function(_,_,_,button)
                dbg_push('click: gitdiff ('..tostring(button)..')')
                local ok, gs = pcall(require,'gitsigns'); if not ok then return end
                if button == 'l' then gs.preview_hunk()
                elseif button == 'm' then gs.next_hunk()
                elseif button == 'r' then gs.prev_hunk()
                end
              end), name = 'heirline_gitdiff_click' },
            },

            encoding = {
              provider = prof('encoding', function() return ' ' .. os_icon() .. enc_icon() end),
              hl = function() return { fg = colors.cyan, bg = colors.base_bg } end,
              update = { 'OptionSet', 'BufEnter' },
            },

            size = {
              condition = function() return not is_empty() and not is_narrow() end,
              provider = prof('size', function() return human_size() end),
              hl = function() return { fg = colors.white, bg = colors.base_bg } end,
              update = { 'BufEnter', 'BufWritePost', 'WinResized' },
              on_click = {
                callback = vim.schedule_wrap(function()
                  dbg_push('click: size -> buffer fuzzy find')
                  if has_mod('telescope.builtin') then require('telescope.builtin').current_buffer_fuzzy_find() end
                end),
                name = 'heirline_size_click',
              },
            },

            search = {
              condition = function() return vim.v.hlsearch == 1 end,
              provider = prof('search', function()
                local t = now_ms()
                if t - last_sc.t < SEARCH_DEBOUNCE_MS then
                  return last_sc.out
                end
                local ok_sc, s = pcall(fn.searchcount, { recompute = 1, maxcount = 1000 })
                local pattern = fn.getreg('/')
                if not ok_sc or not pattern or pattern == '' then
                  last_sc.t, last_sc.out = t, ''
                  return ''
                end
                if #pattern > 15 then pattern = pattern:sub(1, 12) .. '...' end
                local cur = (s and s.current) or 0
                local tot = (s and s.total) or 0
                local out = (tot == 0) and '' or string.format('%s%s %d/%d ', S.search, pattern, cur, tot)
                last_sc.t, last_sc.out, last_sc.pat, last_sc.cur, last_sc.tot = t, out, pattern, cur, tot
                return out
              end),
              hl = function() return { fg = colors.yellow, bg = colors.base_bg } end,
              update = { 'CmdlineLeave', 'CursorMoved', 'CursorMovedI' },
              on_click = { callback = vim.schedule_wrap(function() dbg_push('click: search -> nohlsearch'); pcall(vim.cmd,'nohlsearch') end), name = 'heirline_search_clear' },
            },

            position = {
              provider = prof('position', function()
                local lnum = fn.line('.'); local col = fn.virtcol('.')
                if is_tiny() then
                  return string.format(' %d:%d ', lnum, col)
                end
                local last = math.max(1, fn.line('$')); local pct = math.floor(lnum * 100 / last)
                return string.format(' %3d:%-2d %3d%% ', lnum, col, pct)
              end),
              hl = function() return { fg = colors.white, bg = colors.base_bg } end,
              update = { 'CursorMoved', 'CursorMovedI', 'WinResized' },
            },

            env = {
              condition = function() return SHOW_ENV end,
              provider = prof('env', function()
                local lbl = env_label()
                return (lbl ~= '' and (' ['..lbl..'] ')) or ''
              end),
              hl = function() return { fg = colors.blue_light, bg = colors.base_bg } end,
              update = { 'VimResized' },
            },

            toggles = { ListToggle, WrapToggle },
            format_panel = FormatPanel,
          }

          -- ── Special buffer statusline ─────────────────────────────────────────────
          local SpecialBuffer = {
            condition = function()
              return safe_buffer_matches({
                buftype = { 'help','quickfix','terminal','prompt','nofile' },
                filetype = SPECIAL_FT,
              })
            end,
            hl = function() return { fg = colors.white, bg = colors.base_bg } end,

            {
              provider = prof('special.label', function()
                local label, icon = ft_label_and_icon()
                return string.format(' %s %s', icon or '[*]', label or 'Special')
              end),
              hl = function() return { fg = colors.cyan, bg = colors.base_bg } end,
            },
            { provider = '%=' },
            {
              condition = function() return not is_empty() end,
              provider = prof('special.filename', function() return ' ' .. adapt_fname(30) .. ' ' end),
              hl = function() return { fg = colors.white, bg = colors.base_bg } end,
              on_click = { callback = vim.schedule_wrap(function()
                local path = fn.expand('%:p'); if path == '' then return end
                pcall(fn.setreg, '+', path); notify('Copied path: ' .. path); dbg_push('click: special filename -> copied path')
              end), name = 'heirline_special_copy_path' },
            },
            {
              provider = ' ' .. S.close .. ' ',
              hl = function() return { fg = colors.red, bg = colors.base_bg } end,
              on_click = { callback = vim.schedule_wrap(function() dbg_push('click: close buffer'); vim.cmd('bd!') end), name = 'heirline_close_buf' },
            },
          }

          -- ── Default statusline ────────────────────────────────────────────────────
          local DefaultStatusline = {
            utils.surround({ '', '' }, colors.base_bg, {
              ModePill,
              { condition = is_empty, provider = '[N]', hl = function() return { fg = colors.white, bg = colors.base_bg } end },
              LeftComponents,
              components.search,
            }),
            {
              components.macro,
              align,
              components.diag,
              components.lsp,
              components.lsp_progress,
              components.git,
              components.gitdiff,
              components.encoding,
              components.size,
              components.position,
              components.env,
              components.format_panel,
              components.toggles,
            },
          }

          -- ── Ultra-compact statusline (tiny windows) ───────────────────────────────
          local TinyStatusline = {
            condition = is_tiny,
            utils.surround({ '', '' }, colors.base_bg, {
              ModePill,
              FileIcon,
              {
                provider = function() return adapt_fname(math.max(8, math.floor(win_w() * 0.35))) end,
                hl = function() return { fg = colors.white, bg = colors.base_bg } end,
                update = { 'BufEnter', 'BufFilePost', 'WinResized' },
              },
              align,
              components.position,
            }),
          }

          -- ── Winbar ────────────────────────────────────────────────────────────────
          local Winbar = {
            fallthrough = false,
            {
              condition = function() return vim.bo.buftype == '' end,
              utils.surround({ ' ', ' ' }, colors.base_bg, {
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
                hl = function() return { fg = colors.white, bg = colors.base_bg } end,
              }),
            },
            {
              provider = prof('winbar.special', function()
                local label, icon = ft_label_and_icon()
                return string.format(' %s %s ', icon or '[*]', label or 'Special')
              end),
              hl = function() return { fg = colors.yellow, bg = colors.base_bg } end,
            },
          }

          -- ── Setup ─────────────────────────────────────────────────────────────────
          heir.setup({
            statusline = { fallthrough = false, TinyStatusline, SpecialBuffer, DefaultStatusline },
            winbar = Winbar,
            opts = {
              disable_winbar_cb = function(args)
                if not (args and buf_valid(args.buf)) then return false end
                return safe_buffer_matches({
                  buftype = { 'nofile','prompt','help','quickfix','terminal' },
                  filetype = SPECIAL_FT,
                }, args.buf)
              end,
            },
          })

          -- Sync with theme + autos
          api.nvim_set_hl(0, 'StatusLine',   { fg = colors.white, bg = colors.base_bg })
          api.nvim_set_hl(0, 'StatusLineNC', { fg = colors.white_dim, bg = colors.nc_bg })

          api.nvim_create_autocmd('ColorScheme', {
            callback = function()
              _hl_cache = {}
              colors = themed_colors(colors_fallback)
              api.nvim_set_hl(0, 'StatusLine',   { fg = colors.white, bg = colors.base_bg })
              api.nvim_set_hl(0, 'StatusLineNC', { fg = colors.white_dim, bg = colors.nc_bg })
              if DEBUG then dbg_notify('colors refreshed from theme') end
            end,
          })

          if DEBUG then dbg_notify('initialized (debug ON)') end
        end)
      end,
    })
  end,
}
