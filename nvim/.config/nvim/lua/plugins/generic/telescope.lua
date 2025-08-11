-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ nvim-telescope/telescope.nvim                                                │
-- └───────────────────────────────────────────────────────────────────────────────────┘
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ nvim-telescope/telescope.nvim                                                │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'nvim-telescope/telescope.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'brookhong/telescope-pathogen.nvim', lazy = true },
    { 'jvgrootveld/telescope-zoxide', lazy = true },
    { 'nvim-telescope/telescope-frecency.nvim', lazy = true },
    { 'nvim-telescope/telescope-live-grep-args.nvim', lazy = true },
    { 'nvim-telescope/telescope-file-browser.nvim', lazy = true },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable('make') == 1 end },
  },
  config = function()
    local telescope = require('telescope')

    -- Lazy require helper: resolves module only on first call
    local function lazy_call(mod, fn)
      return function(...)
        local ok, m = pcall(require, mod); if not ok then return end
        local f = m
        for name in tostring(fn):gmatch('[^%.]+') do
          f = f[name]
          if not f then return end
        end
        return f(...)
      end
    end

    -- Lazy action helper: avoids requiring actions at setup-time
    local function act(name)
      return function(...) return require('telescope.actions')[name](...) end
    end

    -- Keep around for potential external mappings
    local function builtin(name, opts)
      return function() return require('telescope.builtin')[name](opts or {}) end
    end

    -- Shared ignore list
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

    local long_find  = { 'rg', '--files', '--hidden', '--iglob', '!.git' }
    local short_find = { 'fd', '-H', '--ignore-vcs', '--strip-cwd-prefix' } -- default quick files

    -- Safe previewer: guard large/binary files; defer to real previewer otherwise
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
        },
        mappings = {
          i = {
            ['<esc>'] = act('close'),
            ['<C-u>'] = false,
            ['<C-s>'] = act('select_horizontal'),
            ['<C-v>'] = act('select_vertical'),
            ['<C-t>'] = act('select_tab'),
            -- FIX: do actions sequentially (no multi-return)
            ['<A-q>'] = function(...)
              local actions = require('telescope.actions')
              actions.smart_send_to_qflist(...)
              return actions.open_qflist(...)
            end,
            ['<C-y>'] = function(prompt_bufnr)
              local e = require('telescope.actions.state').get_selected_entry()
              if e and (e.path or e.value) then
                local p = e.path or e.value
                vim.fn.setreg('+', p)
                vim.notify('Path copied: ' .. p)
              end
            end,
          },
          n = { ['q'] = act('close') },
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
        path_display = { 'truncate' },
        winblend = 8,
        border = {},
        borderchars = { '─','│','─','│','╭','╮','╯','╰' },
        buffer_previewer_maker = safe_buffer_previewer_maker,
        set_env = { COLORTERM = 'truecolor' },
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
          git_status = false, -- keep off by default

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

              -- Toggle visibility / gitignore
              ['.']     = function(...) return require('telescope').extensions.file_browser.actions.toggle_hidden(...) end,
              ['g.']    = function(...) return require('telescope').extensions.file_browser.actions.toggle_respect_gitignore(...) end,

              -- Batch select
              ['<Tab>']   = function(...) return require('telescope').extensions.file_browser.actions.toggle_selected(...) end,
              ['<S-Tab>'] = function(...) return require('telescope').extensions.file_browser.actions.select_all(...) end,

              -- Copy path
              ['<C-y>'] = function(prompt_bufnr)
                local entry = require('telescope.actions.state').get_selected_entry()
                if not entry then return end
                local p = entry.path or entry.value
                if not p then return end
                vim.fn.setreg('+', p)
                vim.notify('Path copied: ' .. p)
              end,

              -- FAST scoped find_files from current dir (FIX: use prompt_bufnr)
              ['<C-f>'] = function(prompt_bufnr)
                local state = require('telescope.actions.state')
                local picker = state.get_current_picker(prompt_bufnr)
                local cwd = (picker and picker._cwd) or vim.loop.cwd()
                require('telescope.builtin').find_files({
                  cwd = cwd,
                  find_command = { 'fd', '-H', '--ignore-vcs', '--strip-cwd-prefix' },
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
              ['<Tab>']   = function(...) return require('telescope').extensions.file_browser.actions.toggle_selected(...) end,
              ['<S-Tab>'] = function(...) return require('telescope').extensions.file_browser.actions.select_all(...) end,
              ['h']       = function(...) return require('telescope').extensions.file_browser.actions.goto_parent_dir(...) end,
              ['l']       = function(...) return require('telescope').extensions.file_browser.actions.select_default(...) end,
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
                require('telescope.builtin').find_files({ cwd = sel.path })
              end,
            },
            -- Note: avoid Telescope prompt-history actions here; this table is zoxide-specific.
          },
        },

        live_grep_args = {
          auto_quoting = true,
          mappings = {
            i = {
              ['<C-k>']     = lazy_call('telescope-live-grep-args.actions', 'quote_prompt'),
              ['<C-i>']     = function()
                return require('telescope-live-grep-args.actions').quote_prompt({ postfix = ' --iglob ' })()
              end,
              ['<C-space>'] = lazy_call('telescope-live-grep-args.actions', 'to_fuzzy_refine'),
              ['<C-o>']     = function()
                local t = require('telescope'); pcall(t.load_extension, 'live_grep_args')
                t.extensions.live_grep_args.live_grep_args({ grep_open_files = true })
              end,
              ['<C-.>']     = function()
                local t = require('telescope'); pcall(t.load_extension, 'live_grep_args')
                t.extensions.live_grep_args.live_grep_args({ cwd = vim.fn.expand('%:p:h') })
              end,
            },
          },
        },
      },
    })

    -- Only keep fzf eagerly; everything else loads on demand via keymaps
    pcall(telescope.load_extension, 'fzf')

    -- Smart files (git_files with graceful fallback)
    local function smart_files()
      local ok = pcall(require('telescope.builtin').git_files, { show_untracked = true })
      if not ok then require('telescope.builtin').find_files({ find_command = short_find }) end
    end

    -- TURBO mode helpers (super-lightweight for huge repos)
    local function turbo_find_files(opts)
      opts = opts or {}
      local cwd = opts.cwd or vim.fn.expand('%:p:h')
      require('telescope.builtin').find_files({
        cwd = cwd,
        -- shallow listing; super fast on massive trees
        find_command = { 'fd', '-H', '--ignore-vcs', '-d', '2', '--strip-cwd-prefix' },
        theme = 'ivy',
        previewer = false,
        prompt_title = false,
        sorting_strategy = 'descending',
        path_display = { 'truncate' },
        -- no devicons toggles here to avoid extra deps/work
      })
    end

    local function turbo_file_browser(opts)
      opts = opts or {}
      local cwd = opts.cwd or vim.fn.expand('%:p:h')
      local t = require('telescope'); pcall(t.load_extension, 'file_browser')
      t.extensions.file_browser.file_browser({
        cwd = cwd,
        theme = 'ivy',
        previewer = false,         -- drop preview for speed
        grouped = false,           -- flat list is faster
        git_status = false,        -- keep lightweight
        hidden = { file_browser = false, folder_browser = false },
        respect_gitignore = true,
        prompt_title = false,
        layout_config = { height = 12 },
      })
    end

    local opts = { silent = true, noremap = true }

    -- NOTE: 'cd' as a bare normal-mode mapping can collide with typing. Keep as-is for muscle memory.
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
      if vim.bo.filetype then
        pcall(function() require('oil.actions').cd.callback() end)
      else
        vim.cmd('chdir %:p:h')
      end
      local t = require('telescope'); pcall(t.load_extension, 'pathogen')
      t.extensions.pathogen.find_files({})
    end, opts)

    vim.keymap.set('n', 'ee', smart_files, opts)

    vim.keymap.set('n', '<leader>L', function()
      if vim.bo.filetype then
        pcall(function() require('oil.actions').cd.callback() end)
      else
        pcall(vim.cmd, 'ProjectRoot')
      end
      local t = require('telescope'); pcall(t.load_extension, 'pathogen')
      t.extensions.pathogen.find_files({})
    end, opts)

    -- TURBO mode keymaps:
    -- <leader>sf : turbo find_files in current buffer dir
    -- <leader>sF : turbo find_files in project root (cwd)
    -- <leader>sb : turbo file_browser in current buffer dir
    vim.keymap.set('n', '<leader>sf', function() turbo_find_files({ cwd = vim.fn.expand('%:p:h') }) end, opts)
    vim.keymap.set('n', '<leader>sF', function() turbo_find_files({ cwd = vim.fn.getcwd() }) end, opts)
    vim.keymap.set('n', '<leader>sb', function() turbo_file_browser({ cwd = vim.fn.expand('%:p:h') }) end, opts)
  end,
}
