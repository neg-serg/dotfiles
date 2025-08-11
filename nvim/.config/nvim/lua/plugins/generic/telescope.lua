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
    -- Resolve module only on first call; walk dotted path to function
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

    -- Lazy action helper (avoids requiring on setup)
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
        local p = vim.fn.finddir(marker, cwd .. ';')
        if p ~= '' then return vim.fn.fnamemodify(p, ':h') end
        p = vim.fn.findfile(marker, cwd .. ';')
        if p ~= '' then return vim.fn.fnamemodify(p, ':h') end
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
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<< file too large to preview >>' })
        return
      end
      if filepath:match('%.(png|jpe?g|gif|webp|pdf|zip|7z|rar)$') then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<< binary file >>' })
        return
      end
      return require('telescope.previewers').buffer_previewer_maker(filepath, bufnr, opts)
    end

    -- ---------- Setup ----------
    telescope.setup({
      defaults = {
        vimgrep_arguments = {
          'rg',
          '--color=never', '--no-heading', '--with-filename',
          '--line-number', '--column', '--smart-case',
          '--hidden',
          '--glob', '!.git',
          '--glob', '!.obsidian',
          '--max-filesize', '1M',
          '--no-binary',
        },
        mappings = {
          i = {
            ['<esc>'] = act('close'),
            ['<C-u>'] = false,
            ['<C-s>'] = act('select_horizontal'),
            ['<C-v>'] = act('select_vertical'),
            ['<C-t>'] = act('select_tab'),
            -- Send to quickfix & open (sequential, not multi-return)
            ['<A-q>'] = function(...)
              local a = require('telescope.actions')
              a.smart_send_to_qflist(...); return a.open_qflist(...)
            end,
            -- Alternative: add without closing picker
            ['<C-q>'] = function(...)
              local a = require('telescope.actions')
              a.smart_send_to_qflist(...); a.open_qflist(...)
            end,
            -- Copy path variations
            ['<C-y>'] = (function()
              local function copier(kind)
                return function(prompt_bufnr)
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
                return function(prompt_bufnr)
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
                return function(prompt_bufnr)
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
          },
          n = {
            ['q'] = act('close'),
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
        layout_config = {
          prompt_position = 'bottom',
          vertical = { width = 0.9, height = 0.9, preview_height = 0.6 },
        },
        file_ignore_patterns = ignore_patterns,
        path_display = { truncate = 3 }, -- keep tail segments visible
        winblend = 8,
        border = {},
        borderchars = { '─','│','─','│','╭','╮','╯','╰' },
        buffer_previewer_maker = safe_buffer_previewer_maker,
        set_env = { COLORTERM = 'truecolor' },
        scroll_strategy = 'limit',
        wrap_results = true,
        history = {
          path = vim.fn.stdpath('state') .. '/telescope_history',
          limit = 200,
        },
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
        -- fzf-native: override sorters globally
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },

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
          git_status = false, -- off by default

          mappings = {
            i = {
              -- Parent dir on empty prompt; else clear input
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

              -- Open variants
              ['<CR>']  = function(...) return require('telescope').extensions.file_browser.actions.select_default(...) end,
              ['<C-s>'] = act('select_horizontal'),
              ['<C-v>'] = act('select_vertical'),
              ['<C-t>'] = act('select_tab'),

              -- File ops
              ['a']     = function(...) return require('telescope').extensions.file_browser.actions.create(...) end,
              ['r']     = function(...) return require('telescope').extensions.file_browser.actions.rename(...) end,
              ['D']     = function(...) return require('telescope').extensions.file_browser.actions.remove(...) end,
              ['m']     = function(...) return require('telescope').extensions.file_browser.actions.move(...) end,
              ['c']     = function(...) return require('telescope').extensions.file_browser.actions.copy(...) end,

              -- Safer "trash" instead of hard delete
              ['T'] = function(prompt_bufnr)
                local e = require('telescope.actions.state').get_selected_entry(); if not e or not e.path then return end
                local cmd
                if vim.fn.executable('gio') == 1 then cmd = { 'gio', 'trash', e.path }
                elseif vim.fn.executable('trash-put') == 1 then cmd = { 'trash-put', e.path } end
                if not cmd then return vim.notify('No trash utility found', vim.log.levels.WARN) end
                vim.fn.jobstart(cmd, { detach = true })
                vim.notify('Trashed: ' .. e.path)
                require('telescope').extensions.file_browser.actions.refresh(prompt_bufnr)
              end,

              -- Open with system handler
              ['o'] = function()
                local e = require('telescope.actions.state').get_selected_entry(); if not e or not e.path then return end
                local opener = (vim.fn.executable('xdg-open') == 1) and { 'xdg-open', e.path }
                             or (vim.fn.executable('gio') == 1)      and { 'gio', 'open', e.path } or nil
                if not opener then return vim.notify('No system opener found', vim.log.levels.WARN) end
                vim.fn.jobstart(opener, { detach = true })
              end,

              -- Toggle visibility / gitignore
              ['.']     = function(...) return require('telescope').extensions.file_browser.actions.toggle_hidden(...) end,
              ['g.']    = function(...) return require('telescope').extensions.file_browser.actions.toggle_respect_gitignore(...) end,

              -- Batch select
              ['<Tab>']   = function(...) return require('telescope').extensions.file_browser.actions.toggle_selected(...) end,
              ['<S-Tab>'] = function(...) return require('telescope').extensions.file_browser.actions.select_all(...) end,

              -- Copy path (absolute)
              ['<C-y>'] = function(prompt_bufnr)
                local entry = require('telescope.actions.state').get_selected_entry(); if not entry then return end
                local p = entry.path or entry.value; if not p then return end
                p = vim.fn.fnamemodify(p, ':p'); vim.fn.setreg('+', p); vim.notify('Path copied: ' .. p)
              end,

              -- FAST scoped find_files from current dir
              ['<C-f>'] = function(prompt_bufnr)
                local state = require('telescope.actions.state')
                local picker = state.get_current_picker(prompt_bufnr)
                local cwd = (picker and picker._cwd) or vim.loop.cwd()
                require('telescope.builtin').find_files({
                  cwd = cwd,
                  find_command = best_find_cmd(),
                  theme = 'ivy',
                  previewer = false,
                })
              end,

              ['<Esc>'] = act('close'),
            },

            n = {
              ['q']     = act('close'),
              ['.']     = function(...) return require('telescope').extensions.file_browser.actions.toggle_hidden(...) end,
              ['g.']    = function(...) return require('telescope').extensions.file_browser.actions.toggle_respect_gitignore(...) end,
              ['a']     = function(...) return require('telescope').extensions.file_browser.actions.create(...) end,
              ['r']     = function(...) return require('telescope').extensions.file_browser.actions.rename(...) end,
              ['D']     = function(...) return require('telescope').extensions.file_browser.actions.remove(...) end,
              ['m']     = function(...) return require('telescope').extensions.file_browser.actions.move(...) end,
              ['c']     = function(...) return require('telescope').extensions.file_browser.actions.copy(...) end,
              ['T']     = function(...) return vim.cmd.normal({ args = { 'i' } }) end, -- hint: use insert 'T'
              ['<Tab>']   = function(...) return require('telescope').extensions.file_browser.actions.toggle_selected(...) end,
              ['<S-Tab>'] = function(...) return require('telescope').extensions.file_browser.actions.select_all(...) end,
              ['h']       = function(...) return require('telescope').extensions.file_browser.actions.goto_parent_dir(...) end,
              ['l']       = function(...) return require('telescope').extensions.file_browser.actions.select_default(...) end,
              ['s']       = act('select_horizontal'),
              ['v']       = act('select_vertical'),
              ['t']       = act('select_tab'),
              ['/']       = function() vim.cmd('startinsert') end,
              ['o']       = function()
                local e = require('telescope.actions.state').get_selected_entry(); if not e or not e.path then return end
                local opener = (vim.fn.executable('xdg-open') == 1) and { 'xdg-open', e.path }
                             or (vim.fn.executable('gio') == 1)      and { 'gio', 'open', e.path } or nil
                if not opener then return vim.notify('No system opener found', vim.log.levels.WARN) end
                vim.fn.jobstart(opener, { detach = true })
              end,
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
          use_sqlite = false,
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
              -- Quick filters/types (examples)
              ['<C-g>']     = function()
                local a = require('telescope-live-grep-args.actions')
                return a.quote_prompt({ postfix = ' -g !**/node_modules/** -g !**/dist/** ' })()
              end,
              ['<C-t>']     = function()
                local a = require('telescope-live-grep-args.actions')
                return a.quote_prompt({ postfix = ' -t rust ' })()
              end,
              ['<C-p>']     = function()
                local t = require('telescope'); pcall(t.load_extension, 'live_grep_args')
                t.extensions.live_grep_args.live_grep_args({ grep_open_files = true })
              end,
            },
          },
        },
      },
    })

    -- ---------- Extensions ----------
    pcall(telescope.load_extension, 'fzf') -- keep only fzf eagerly

    -- ---------- Smart/Turbo helpers ----------

    -- git_files with graceful fallback
    local function smart_files()
      local ok = pcall(require('telescope.builtin').git_files, { show_untracked = true })
      if not ok then require('telescope.builtin').find_files({ find_command = best_find_cmd() }) end
    end

    -- ultra-light listing for huge trees
    local function turbo_find_files(opts)
      opts = opts or {}
      local cwd = opts.cwd or vim.fn.expand('%:p:h')
      require('telescope.builtin').find_files({
        cwd = cwd,
        find_command = { (vim.fn.executable('fd') == 1 and 'fd' or 'fdfind'), '-H', '--ignore-vcs', '-d', '2', '--strip-cwd-prefix' },
        theme = 'ivy',
        previewer = false,
        prompt_title = false,
        sorting_strategy = 'descending',
        path_display = { 'truncate' },
      })
    end

    local function turbo_file_browser(opts)
      opts = opts or {}
      local cwd = opts.cwd or vim.fn.expand('%:p:h')
      local t = require('telescope'); pcall(t.load_extension, 'file_browser')
      t.extensions.file_browser.file_browser({
        cwd = cwd,
        theme = 'ivy',
        previewer = false,
        grouped = false,
        git_status = false,
        hidden = { file_browser = false, folder_browser = false },
        respect_gitignore = true,
        prompt_title = false,
        layout_config = { height = 12 },
      })
    end

    -- Only modified/unstaged files
    local function git_modified_files()
      local root = project_root()
      require('telescope.builtin').find_files({
        cwd = root,
        find_command = { 'git', '-C', root, 'ls-files', '-m', '-o', '--exclude-standard' },
        theme = 'ivy', previewer = false, prompt_title = 'Modified/Untracked',
      })
    end

    -- Grep across changed files only
    local function grep_changed()
      local root = project_root()
      local files = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(root) .. ' ls-files -m -o --exclude-standard')
      if #files == 0 then return vim.notify('No changed files', vim.log.levels.INFO) end
      local cfg = require('telescope.config').values
      local args = vim.deepcopy(cfg.vimgrep_arguments)
      for _, f in ipairs(files) do table.insert(args, f) end
      require('telescope.builtin').grep_string({
        search = '',
        cwd = root,
        grep_open_files = false,
        vimgrep_arguments = args,
        prompt_title = 'Grep changed files',
      })
    end

    -- ---------- Keymaps ----------
    local opts = { silent = true, noremap = true }

    -- zoxide list (consider mapping to <leader>cd if 'cd' collides)
    vim.keymap.set('n', 'cd', function()
      local t = require('telescope')
      pcall(t.load_extension, 'zoxide')
      t.extensions.zoxide.list(require('telescope.themes').get_ivy({ layout_config = { height = 8 }, border = false }))
    end, opts)

    -- frecency
    vim.keymap.set('n', '<leader>.', function()
      local t = require('telescope')
      pcall(t.load_extension, 'frecency')
      vim.cmd('Telescope frecency theme=ivy layout_config={height=12} sorting_strategy=descending')
    end, opts)

    -- file browser in current buffer dir
    vim.keymap.set('n', '<leader>l', function()
      local t = require('telescope'); pcall(t.load_extension, 'file_browser')
      vim.cmd('Telescope file_browser path=%:p:h select_buffer=true')
    end, opts)

    -- pathogen from file dir / project root
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

    -- Project-scoped helpers
    vim.keymap.set('n', '<leader>sd', function()
      require('telescope.builtin').find_files({
        cwd = vim.fn.expand('%:p:h'),
        find_command = best_find_cmd(),
        theme = 'ivy', previewer = false,
      })
    end, opts)

    vim.keymap.set('n', '<leader>*', function()
      require('telescope.builtin').grep_string({ cwd = project_root(), word_match = '-w' })
    end, opts)

    vim.keymap.set('n', '<leader>sm', git_modified_files, opts)
    vim.keymap.set('n', '<leader>sg', grep_changed, opts)
  end,
}
