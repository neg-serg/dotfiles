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

          -- Special types (expanded x4–5)
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
            provider = function() return fn.fnamemodify(fn.getcwd(), ':~') end,
            hl = hl(colors.white, colors.black),
            update = { 'DirChanged', 'BufEnter' },
            on_click = { callback = vim.schedule_wrap(open_file_browser_cwd), name = 'heirline_cwd_open' },
          }

          local FileIcon = {
            condition = function() return not is_empty() end,
            provider = function()
              local name = fn.expand('%:t')
              local icon = devicons.get_icon(name)
              return icon or ''
            end,
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
            provider = function() return ' ' .. fn.expand('%:t') end,
            hl = hl(colors.white, colors.black),
            update = { 'BufEnter', 'BufFilePost' },
            on_click = {
              callback = vim.schedule_wrap(function()
                local path = fn.expand('%:p'); if path == '' then return end
                pcall(fn.setreg, '+', path); notify('Copied path: ' .. path)
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
            on_click = { callback = vim.schedule_wrap(function() vim.o.list = not vim.o.list end), name = 'heirline_toggle_list' },
          }

          local WrapToggle = {
            provider = function() return ' ⤶' end,
            hl = function() return hl(vim.wo.wrap and colors.yellow or colors.white, colors.black) end,
            update = { 'OptionSet', 'BufWinEnter' },
            on_click = { callback = vim.schedule_wrap(function() vim.wo.wrap = not vim.wo.wrap end), name = 'heirline_toggle_wrap' },
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
              provider = function() return '  REC @' .. fn.reg_recording() .. ' ' end,
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
                provider = function(self) return (self.errors or 0) > 0 and (' ' .. self.errors .. ' ') or '' end,
                hl = hl(colors.red, colors.black),
              },
              {
                provider = function(self) return (self.warnings or 0) > 0 and (' ' .. self.warnings .. ' ') or '' end,
                hl = hl(colors.yellow, colors.black),
              },
              on_click = {
                callback = vim.schedule_wrap(function(_, _, _, button)
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
              on_click = { callback = vim.schedule_wrap(function() vim.cmd('LspInfo') end), name = 'heirline_lsp_info' },
              update = { 'LspAttach', 'LspDetach' },
            },

            git = {
              condition = function() return c.is_git_repo() and not is_narrow() end,
              provider = function()
                if vim.b.gitsigns_head == nil then return '' end
                local head = vim.b.gitsigns_head or ''
                if head == '' then return '' end
                return '  ' .. head .. ' '
              end,
              hl = hl(colors.blue, colors.black),
              update = { 'BufEnter', 'BufWritePost', 'WinResized' },
              on_click = { callback = vim.schedule_wrap(open_git_ui), name = 'heirline_git_ui' },
            },

            encoding = {
              provider = function()
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

            size = {
              condition = function() return not is_empty() and not is_narrow() end,
              provider = function() return human_size() end,
              hl = hl(colors.white, colors.black),
              update = { 'BufEnter', 'BufWritePost', 'WinResized' },
              on_click = {
                callback = vim.schedule_wrap(function()
                  if has_mod('telescope.builtin') then
                    require('telescope.builtin').current_buffer_fuzzy_find()
                  end
                end),
                name = 'heirline_size_click',
              },
            },

            search = {
              condition = function() return vim.v.hlsearch == 1 end,
              provider = function()
                local pattern = fn.getreg('/')
                if not pattern or pattern == '' then return '' end
                if #pattern > 15 then pattern = pattern:sub(1, 12) .. '...' end
                local s = fn.searchcount({ recompute = 1, maxcount = 1000 })
                local cur = s.current or 0
                local tot = s.total   or 0
                if tot == 0 then return '' end
                return string.format('  %s %d/%d ', pattern, cur, tot)
              end,
              hl = hl(colors.yellow, colors.black),
              update = { 'CmdlineLeave', 'CursorMoved', 'CursorMovedI' },
              on_click = { callback = vim.schedule_wrap(function() pcall(vim.cmd, 'nohlsearch') end), name = 'heirline_search_clear' },
            },

            position = {
              provider = function()
                local lnum = fn.line('.'); local col = fn.virtcol('.')
                local last = math.max(1, fn.line('$'))
                local pct  = math.floor(lnum * 100 / last)
                return string.format(' %3d:%-2d %3d%% ', lnum, col, pct)
              end,
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
              provider = function()
                local label, icon = ft_label_and_icon()
                return string.format(' %s %s', icon or '', label or 'Special')
              end,
              hl = hl(colors.cyan, colors.black),
            },

            { provider = '%=' },

            {
              condition = function() return not is_empty() end,
              provider = function() return ' ' .. fn.fnamemodify(fn.expand('%:t'), ':t') .. ' ' end,
              hl = hl(colors.white, colors.black),
              on_click = {
                callback = vim.schedule_wrap(function()
                  local path = fn.expand('%:p'); if path == '' then return end
                  pcall(fn.setreg, '+', path); notify('Copied path: ' .. path)
                end),
                name = 'heirline_special_copy_path',
              },
            },

            {
              provider = '  ',
              hl = hl(colors.red, colors.black),
              on_click = { callback = vim.schedule_wrap(function() vim.cmd('bd!') end), name = 'heirline_close_buf' },
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
                provider = function()
                  local p = fn.expand('%:~:.')
                  local parts = vim.split(p, '/', { plain = true })
                  if #parts > 3 and api.nvim_win_get_width(0) >= 90 then
                    for i = 1, #parts - 2 do parts[i] = parts[i]:sub(1, 1) end
                    p = table.concat(parts, '/')
                  else
                    p = fn.pathshorten(p)
                  end
                  return p
                end,
                hl = hl(colors.white, colors.black),
              }),
            },
            {
              provider = function()
                local label, icon = ft_label_and_icon()
                return string.format(' %s %s ', icon or '', label or 'Special')
              end,
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
        end)
      end,
    })
  end,
}
