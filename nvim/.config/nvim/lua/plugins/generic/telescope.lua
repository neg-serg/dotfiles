-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ nvim-telescope/telescope.nvim                                                │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'nvim-telescope/telescope.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable('make') == 1 end },
    { 'brookhong/telescope-pathogen.nvim',          lazy = true },
    { 'jvgrootveld/telescope-zoxide',               lazy = true },
    { 'nvim-telescope/telescope-frecency.nvim',     lazy = true },
    { 'nvim-telescope/telescope-live-grep-args.nvim', lazy = true },
    { 'nvim-telescope/telescope-file-browser.nvim', lazy = true },
  },
  config = function()
    local telescope = require('telescope')

    -- ---------- Helpers ----------
    local function lazy_call(mod, fn)
      return function(...)
        local ok, m = pcall(require, mod); if not ok then return end
        local f = m
        for name in tostring(fn):gmatch('[^%.]+') do
          f = f[name]; if not f then return end
        end
        return f(...) 
      end
    end
    local function act(name) return function(...) return require('telescope.actions')[name](...) end end
    local function builtin(name, opts) return function() return require('telescope.builtin')[name](opts or {}) end end

    local function best_find_cmd()
      if vim.fn.executable('fd') == 1 then
        return { 'fd', '-H', '--ignore-vcs', '--strip-cwd-prefix' }
      else
        return { 'rg', '--files', '--hidden', '--iglob', '!.git' }
      end
    end

    local function project_root()
      local cwd = vim.loop.cwd()
      for _, marker in ipairs({ '.git', '.hg', 'pyproject.toml', 'package.json', 'Cargo.toml', 'go.mod' }) do
        local p = vim.fn.finddir(marker, cwd .. ';'); if p ~= '' then return vim.fn.fnamemodify(p, ':h') end
        p = vim.fn.findfile(marker, cwd .. ';'); if p ~= '' then return vim.fn.fnamemodify(p, ':h') end
      end
      return cwd
    end

    -- ---------- Ignore rules ----------
    local ignore_patterns = {
      '__pycache__/', '__pycache__/*',
      'build/', 'gradle/', 'node_modules/', 'node_modules/*',
      'smalljre_*/*', 'target/', 'vendor/*',
      '.dart_tool/', '.git/', '.github/', '.gradle/', '.idea/', '.vscode/',
      '%.sqlite3', '%.ipynb', '%.lock', '%.pdb', '%.dll', '%.class', '%.exe',
      '%.cache', '%.pdf', '%.dylib', '%.jar', '%.docx', '%.met', '%.burp',
      '%.mp4', '%.mkv', '%.rar', '%.zip', '%.7z', '%.tar', '%.bz2', '%.epub',
      '%.flac', '%.tar.gz',
    }
    local short_find = best_find_cmd()

    -- ---------- Previewer guard ----------
    local function safe_buffer_previewer_maker(filepath, bufnr, opts)
      local max_bytes = 1.5 * 1024 * 1024
      local stat = vim.loop.fs_stat(filepath)
      if stat and stat.size and stat.size > max_bytes then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<< file too large to preview >>' }); return
      end
      if filepath:match('%.(png|jpe?g|gif|webp|pdf|zip|7z|rar)$') then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<< binary file >>' }); return
      end
      return require('telescope.previewers').buffer_previewer_maker(filepath, bufnr, opts)
    end

    -- ---------- File Browser custom actions (Block #1) ----------
    -- Deep create: mkdir -p and create empty file
    local function fb_create_deep(prompt_bufnr)
      local fb = require('telescope').extensions.file_browser
      local actions = fb.actions
      local state = require('telescope.actions.state')
      local picker = state.get_current_picker(prompt_bufnr)
      local cwd = (picker and picker._cwd) or vim.loop.cwd()
      vim.ui.input({ prompt = 'New path (relative): ' }, function(input)
        if not input or input == '' then return end
        local abs = vim.fs.normalize(cwd .. '/' .. input)
        vim.fn.mkdir(vim.fn.fnamemodify(abs, ':h'), 'p')
        if vim.fn.filereadable(abs) == 0 then vim.fn.writefile({}, abs) end
        actions.refresh(prompt_bufnr)
        vim.cmd.edit(abs)
      end)
    end
    -- Duplicate selected file
    local function fb_duplicate(prompt_bufnr)
      local e = require('telescope.actions.state').get_selected_entry(); if not e or not e.path then return end
      local src = e.path
      local default = src .. '.copy'
      vim.ui.input({ prompt = 'Duplicate to: ', default = default }, function(dst)
        if not dst or dst == '' then return end
        vim.fn.mkdir(vim.fn.fnamemodify(dst, ':h'), 'p')
        vim.fn.writefile(vim.fn.readfile(src, 'b'), dst, 'b')
        require('telescope').extensions.file_browser.actions.refresh(prompt_bufnr)
        vim.notify('Duplicated → ' .. dst)
      end)
    end

    -- ---------- Diff helpers (Block #5) ----------
    -- Diff two selected files (multi-select with <Tab>)
    local function fb_diff_two()
      local st = require('telescope.actions.state')
      local pick = st.get_current_picker(0)
      local sels = pick and pick:get_multi_selection() or {}
      if #sels < 2 then return vim.notify('Select two files (use <Tab>)', vim.log.levels.WARN) end
      local a = sels[1].path or sels[1].value
      local b = sels[2].path or sels[2].value
      vim.cmd('tabnew')
      vim.cmd('edit ' .. vim.fn.fnameescape(a))
      vim.cmd('vert diffsplit ' .. vim.fn.fnameescape(b))
    end
    -- Diff against HEAD (uses fugitive if present, else fallback)
    local function fb_diff_head()
      local e = require('telescope.actions.state').get_selected_entry(); if not e or not e.path then return end
      local file = e.path
      if vim.fn.exists(':Gvdiffsplit') == 2 then
        vim.cmd('Gvdiffsplit ' .. vim.fn.fnameescape(file))
        return
      end
      local root = project_root()
      local rel = file:gsub('^' .. vim.pesc(root) .. '/?', '')
      local lines = vim.fn.systemlist({ 'git', '-C', root, 'show', 'HEAD:' .. rel })
      if vim.v.shell_error ~= 0 then return vim.notify('Not in git or file not tracked at HEAD', vim.log.levels.WARN) end
      vim.cmd('tabnew')
      local head_buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_option(head_buf, 'buftype', 'nofile')
      vim.api.nvim_buf_set_option(head_buf, 'bufhidden', 'wipe')
      vim.api.nvim_buf_set_name(head_buf, 'HEAD:' .. rel)
      vim.api.nvim_buf_set_lines(head_buf, 0, -1, false, lines)
      vim.cmd('vert diffsplit ' .. vim.fn.fnameescape(file))
    end

    -- ---------- Quickfix helpers (Block #10 + interaction) ----------
    local function apply_cmd_to_qf(cmd)
      if not cmd or cmd == '' then return end
      vim.cmd('copen')
      vim.cmd('cdo ' .. cmd)
    end
    local function qf_toggle()
      local winid = vim.fn.getqflist({ winid = 0 }).winid
      if winid ~= 0 then vim.cmd('cclose') else vim.cmd('copen') end
    end
    local function qf_clear()
      vim.fn.setqflist({})
      vim.notify('Quickfix cleared')
    end
    local function qf_picker()
      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf = require('telescope.config').values
      local actions = require('telescope.actions')
      local state = require('telescope.actions.state')

      local qf = vim.fn.getqflist({ items = 1 }).items or {}
      if #qf == 0 then return vim.notify('Quickfix is empty') end

      pickers.new({}, {
        prompt_title = 'Quickfix',
        finder = finders.new_table({
          results = qf,
          entry_maker = function(item)
            local bufname = (item.bufnr and vim.api.nvim_buf_is_valid(item.bufnr)) and vim.api.nvim_buf_get_name(item.bufnr) or item.filename or ''
            local disp = (bufname ~= '' and (vim.fn.fnamemodify(bufname, ':.')) or '[No Name]') ..
                         ':' .. (item.lnum or 0) .. ':' .. (item.col or 0) .. '  ' .. (item.text or '')
            return {
              value = item,
              display = disp,
              ordinal = disp,
              path = bufname,
              lnum = item.lnum, col = item.col,
            }
          end
        }),
        sorter = conf.generic_sorter({}),
        previewer = conf.qflist_previewer({}),
        attach_mappings = function(bufnr, map)
          -- open (default <CR> already works)
          -- delete current selection(s) from qf
          local function delete_selected()
            local picker = state.get_current_picker(bufnr)
            local sels = picker:get_multi_selection()
            if #sels == 0 then
              local cur = state.get_selected_entry(bufnr); if cur then sels = { cur } end
            end
            if #sels == 0 then return end
            local current = vim.fn.getqflist({ items = 1 }).items or {}
            local function key(e)
              return table.concat({ e.bufnr or 0, e.lnum or 0, e.col or 0, e.text or '' }, '|')
            end
            local rm = {}
            for _, s in ipairs(sels) do rm[key(s.value)] = true end
            local kept = {}
            for _, it in ipairs(current) do if not rm[key(it)] then table.insert(kept, it) end end
            vim.fn.setqflist({}, ' ', { items = kept })
            require('telescope.actions').close(bufnr)
            qf_picker()
          end
          map('i', 'dd', delete_selected)
          map('n', 'dd', delete_selected)
          return true
        end,
      }):find()
    end

    -- ---------- Setup ----------
    local layout_actions = require('telescope.actions.layout')

    telescope.setup({
      defaults = {
        vimgrep_arguments = {
          'rg','--color=never','--no-heading','--with-filename',
          '--line-number','--column','--smart-case','--hidden',
          '--glob','!.git','--glob','!.obsidian',
          '--max-filesize','1M','--no-binary',
        },
        mappings = {
          i = {
            ['<esc>'] = act('close'),
            ['<C-u>'] = false,
            ['<C-s>'] = act('select_horizontal'),
            ['<C-v>'] = act('select_vertical'),
            ['<C-t>'] = act('select_tab'),
            -- send to qf + open
            ['<A-q>'] = function(...) local a=require('telescope.actions'); a.smart_send_to_qflist(...); return a.open_qflist(...) end,
            -- add to qf (keep picker)
            ['<C-q>'] = function(...) local a=require('telescope.actions'); a.smart_send_to_qflist(...); a.open_qflist(...) end,
            -- copy path variations
            ['<C-y>'] = (function()
              local function copier(kind)
                return function()
                  local e = require('telescope.actions.state').get_selected_entry(); if not e then return end
                  local p = e.path or e.value; if not p then return end
                  if kind == 'name' then p = vim.fn.fnamemodify(p, ':t')
                  elseif kind == 'rel' then p = vim.fn.fnamemodify(p, ':.')
                  else p = vim.fn.fnamemodify(p, ':p') end
                  vim.fn.setreg('+', p); vim.notify('Copied: ' .. p)
                end
              end
              return copier('abs')
            end)(),
            ['<A-y>'] = (function()
              local function copier(kind)
                return function()
                  local e = require('telescope.actions.state').get_selected_entry(); if not e then return end
                  local p = e.path or e.value; if not p then return end
                  if kind == 'name' then p = vim.fn.fnamemodify(p, ':t')
                  elseif kind == 'rel' then p = vim.fn.fnamemodify(p, ':.')
                  else p = vim.fn.fnamemodify(p, ':p') end
                  vim.fn.setreg('+', p); vim.notify('Copied: ' .. p)
                end
              end
              return copier('rel')
            end)(),
            ['<S-y>'] = (function()
              local function copier(kind)
                return function()
                  local e = require('telescope.actions.state').get_selected_entry(); if not e then return end
                  local p = e.path or e.value; if not p then return end
                  if kind == 'name' then p = vim.fn.fnamemodify(p, ':t')
                  elseif kind == 'rel' then p = vim.fn.fnamemodify(p, ':.')
                  else p = vim.fn.fnamemodify(p, ':p') end
                  vim.fn.setreg('+', p); vim.notify('Copied: ' .. p)
                end
              end
              return copier('name')
            end)(),
            ['<C-S-p>'] = layout_actions.toggle_preview,
          },
          n = {
            ['q'] = act('close'),
            ['<C-p>'] = layout_actions.toggle_preview,
          },
        },
        dynamic_preview_title = true,
        prompt_prefix = '❯> ',
        selection_caret = '• ',
        entry_prefix = '  ',
        initial_mode = 'insert',
        selection_strategy = 'reset',
        sorting_strategy = 'descending',
        layout_strategy = 'vertical',
        layout_config = { prompt_position = 'bottom', vertical = { width = 0.9, height = 0.9, preview_height = 0.6 } },
        file_ignore_patterns = ignore_patterns,
        path_display = { truncate = 3 },
        winblend = 8,
        border = {},
        borderchars = { '─','│','─','│','╭','╮','╯','╰' },
        buffer_previewer_maker = safe_buffer_previewer_maker,
        set_env = { COLORTERM = 'truecolor' },
        scroll_strategy = 'limit',
        wrap_results = true,
        history = { path = vim.fn.stdpath('state') .. '/telescope_history', limit = 200 },
      },

      pickers = {
        find_files = {
          theme = 'ivy', border = false, previewer = false,
          sorting_strategy = 'descending', prompt_title = false,
          find_command = short_find, layout_config = { height = 12 },
        },
        buffers = {
          sort_lastused = true, theme = 'ivy', previewer = false,
          mappings = { i = { ['<C-d>'] = act('delete_buffer') } },
        },
      },

      extensions = {
        fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = 'smart_case' },

        file_browser = {
          theme = 'ivy',
          border = true,
          prompt_title = false,
          grouped = true,
          hide_parent_dir = true,
          sorting_strategy = 'descending',
          layout_config = { height = 18 },
          hidden = { file_browser = false, folder_browser = false },
          hijack_netrw = false,
          git_status = false,

          mappings = {
            i = {
              ['<C-w>'] = function(prompt_bufnr, bypass)
                local state = require('telescope.actions.state')
                local picker = state.get_current_picker(prompt_bufnr)
                if picker and picker:_get_prompt() == '' then
                  local fb = require('telescope').extensions.file_browser.actions
                  return fb.goto_parent_dir(prompt_bufnr, bypass)
                else
                  local t = function(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end
                  vim.api.nvim_feedkeys(t('<C-u>'), 'i', true)
                end
              end,
              -- FIX: use core select_default, not fb_actions.select_default
              ['<CR>']  = act('select_default'),
              ['<C-s>'] = act('select_horizontal'),
              ['<C-v>'] = act('select_vertical'),
              ['<C-t>'] = act('select_tab'),

              ['N'] = fb_create_deep,   -- deep create file/dir
              ['Y'] = fb_duplicate,     -- duplicate file
              ['='] = fb_diff_two,      -- diff two selected
              ['H'] = fb_diff_head,     -- diff vs HEAD

              -- keep existing:
              ['.']     = function(...) return require('telescope').extensions.file_browser.actions.toggle_hidden(...) end,
              ['g.']    = function(...) return require('telescope').extensions.file_browser.actions.toggle_respect_gitignore(...) end,
              ['<Tab>']   = function(...) return require('telescope').extensions.file_browser.actions.toggle_selected(...) end,
              ['<S-Tab>'] = function(...) return require('telescope').extensions.file_browser.actions.select_all(...) end,
              ['<C-y>'] = function(prompt_bufnr)
                local entry = require('telescope.actions.state').get_selected_entry(); if not entry then return end
                local p = entry.path or entry.value; if not p then return end
                p = vim.fn.fnamemodify(p, ':p'); vim.fn.setreg('+', p); vim.notify('Path copied: ' .. p)
              end,
              ['<C-f>'] = function(prompt_bufnr)
                local state = require('telescope.actions.state')
                local picker = state.get_current_picker(prompt_bufnr)
                local cwd = (picker and picker._cwd) or vim.loop.cwd()
                require('telescope.builtin').find_files({ cwd = cwd, find_command = best_find_cmd(), theme = 'ivy', previewer = false })
              end,
              ['<Esc>'] = act('close'),
            },
            n = {
              ['q']     = act('close'),
              ['.']     = function(...) return require('telescope').extensions.file_browser.actions.toggle_hidden(...) end,
              ['g.']    = function(...) return require('telescope').extensions.file_browser.actions.toggle_respect_gitignore(...) end,
              ['N'] = fb_create_deep,
              ['Y'] = fb_duplicate,
              ['='] = fb_diff_two,
              ['H'] = fb_diff_head,
              ['<Tab>']   = function(...) return require('telescope').extensions.file_browser.actions.toggle_selected(...) end,
              ['<S-Tab>'] = function(...) return require('telescope').extensions.file_browser.actions.select_all(...) end,
              ['h']       = function(...) return require('telescope').extensions.file_browser.actions.goto_parent_dir(...) end,
              -- FIX: use core select_default, not fb_actions.select_default
              ['l']       = act('select_default'),
              ['s']       = act('select_horizontal'),
              ['v']       = act('select_vertical'),
              ['t']       = act('select_tab'),
              ['/']       = function() vim.cmd('startinsert') end,
            },
          },
        },

        pathogen = {
          use_last_search_for_live_grep = false,
          attach_mappings = function(map, acts)
            map('i', '<C-o>', acts.proceed_with_parent_dir)
            map('i', '<C-l>', acts.revert_back_last_dir)
            map('i', '<C-b>', acts.change_working_directory)
          end,
        },

        frecency = {
          disable_devicons = false,
          ignore_patterns = ignore_patterns,
          path_display = { 'relative' },
          previewer = false,
          prompt_title = false,
          results_title = false,
          show_scores = false,
          show_unindexed = true,
          use_sqlite = true,
        },

        zoxide = {
          mappings = {
            ['<S-Enter>'] = { action = function(sel)
              local t = require('telescope'); pcall(t.load_extension, 'pathogen')
              t.extensions.pathogen.find_files({ cwd = sel.path })
            end },
            ['<Tab>'] = { action = function(sel)
              local t = require('telescope'); pcall(t.load_extension, 'pathogen')
              t.extensions.pathogen.find_files({ cwd = sel.path })
            end },
            ['<C-b>'] = {
              keepinsert = true,
              action = function(sel)
                local t = require('telescope'); pcall(t.load_extension, 'file_browser')
                t.extensions.file_browser.file_browser({ cwd = sel.path })
              end,
            },
            ['<C-f>'] = {
              keepinsert = true,
              action = function(sel)
                require('telescope.builtin').find_files({ cwd = sel.path, find_command = best_find_cmd() })
              end,
            },
          },
        },

        live_grep_args = {
          auto_quoting = true,
          mappings = {
            i = {
              ['<C-k>']     = lazy_call('telescope-live-grep-args.actions', 'quote_prompt'),
              ['<C-i>']     = function() return require('telescope-live-grep-args.actions').quote_prompt({ postfix = ' --iglob ' })() end,
              ['<C-space>'] = lazy_call('telescope-live-grep-args.actions', 'to_fuzzy_refine'),
              ['<C-o>']     = function()
                local t = require('telescope'); pcall(t.load_extension, 'live_grep_args')
                t.extensions.live_grep_args.live_grep_args({ grep_open_files = true })
              end,
              ['<C-.>']     = function()
                local t = require('telescope'); pcall(t.load_extension, 'live_grep_args')
                t.extensions.live_grep_args.live_grep_args({ cwd = vim.fn.expand('%:p:h') })
              end,
              ['<C-g>']     = function()
                local a = require('telescope-live-grep-args.actions')
                return a.quote_prompt({ postfix = ' -g !**/node_modules/** -g !**/dist/** ' })()
              end,
              ['<C-t>']     = function()
                local a = require('telescope-live-grep-args.actions')
                return a.quote_prompt({ postfix = ' -t rust ' })()
              end,
              ['<C-p>']     = layout_actions.toggle_preview, -- also useful in LGA
            },
          },
        },
      },
    })

    -- ---------- Extensions ----------
    pcall(telescope.load_extension, 'fzf')
    -- ---------- Smart/Turbo helpers ----------
    local function smart_files()
      local ok = pcall(require('telescope.builtin').git_files, { show_untracked = true })
      if not ok then require('telescope.builtin').find_files({ find_command = best_find_cmd() }) end
    end
    local function turbo_find_files(opts)
      opts = opts or {}
      local cwd = opts.cwd or vim.fn.expand('%:p:h')
      require('telescope.builtin').find_files({
        cwd = cwd,
        find_command = { (vim.fn.executable('fd') == 1 and 'fd' or 'fdfind'), '-H', '--ignore-vcs', '-d', '2', '--strip-cwd-prefix' },
        theme = 'ivy', previewer = false, prompt_title = false, sorting_strategy = 'descending', path_display = { 'truncate' },
      })
    end
    local function turbo_file_browser(opts)
      opts = opts or {}
      local cwd = opts.cwd or vim.fn.expand('%:p:h')
      local t = require('telescope'); pcall(t.load_extension, 'file_browser')
      t.extensions.file_browser.file_browser({
        cwd = cwd, theme = 'ivy', previewer = false, grouped = false, git_status = false,
        hidden = { file_browser = false, folder_browser = false }, respect_gitignore = true, prompt_title = false,
        layout_config = { height = 12 },
      })
    end

    -- ---------- Keymaps ----------
    local opts = { silent = true, noremap = true }
    -- zoxide (note: consider <leader>cd if 'cd' conflicts)
    vim.keymap.set('n', 'cd', function()
      local t = require('telescope')
      pcall(t.load_extension, 'zoxide')
      t.extensions.zoxide.list(require('telescope.themes').get_ivy({ layout_config = { height = 8 }, border = false }))
    end, opts)

    vim.keymap.set('n', '<leader>.', function()
      local t = require('telescope')
      pcall(t.load_extension, 'frecency')
      vim.cmd('Telescope frecency theme=ivy layout_config={height=12} sorting_strategy=descending')
    end, opts)

    vim.keymap.set('n', '<leader>l', function()
      local t = require('telescope'); pcall(t.load_extension, 'file_browser')
      vim.cmd('Telescope file_browser path=%:p:h select_buffer=true')
    end, opts)

    vim.keymap.set('n', 'E', function()
      if vim.bo.filetype then pcall(function() require('oil.actions').cd.callback() end)
      else vim.cmd('chdir %:p:h') end
      local t = require('telescope'); pcall(t.load_extension, 'pathogen')
      t.extensions.pathogen.find_files({})
    end, opts)

    vim.keymap.set('n', 'ee', smart_files, opts)
    vim.keymap.set('n', '<leader>L', function()
      if vim.bo.filetype then pcall(function() require('oil.actions').cd.callback() end)
      else pcall(vim.cmd, 'ProjectRoot') end
      local t = require('telescope'); pcall(t.load_extension, 'pathogen')
      t.extensions.pathogen.find_files({})
    end, opts)

    -- TURBO mode
    vim.keymap.set('n', '<leader>sf', function() turbo_find_files({ cwd = vim.fn.expand('%:p:h') }) end, opts)
    vim.keymap.set('n', '<leader>sF', function() turbo_find_files({ cwd = project_root() }) end, opts)
    vim.keymap.set('n', '<leader>sb', function() turbo_file_browser({ cwd = vim.fn.expand('%:p:h') }) end, opts)

    -- Resume last picker
    vim.keymap.set('n', '<leader>sr', builtin('resume'), opts)

    -- Project helpers
    vim.keymap.set('n', 'gz', function()
      require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h'), find_command = best_find_cmd(), theme = 'ivy', previewer = false })
    end, opts)

    -- Quickfix interaction
    vim.keymap.set('n', '<C-q>',  qf_picker, opts)  -- Telescope quickfix picker (delete with "dd")
    vim.keymap.set('n', '<C-q>q', qf_toggle, opts)  -- toggle quickfix window
    vim.keymap.set('n', '<C-q>d', qf_clear, opts)   -- clear quickfix (d = delete)
    vim.keymap.set('n', '<C-q>a', function()
        vim.ui.input({ prompt = ':cdo ' }, function(cmd) if cmd and cmd ~= '' then apply_cmd_to_qf(cmd) end end)
    end, opts)
  end,
}
