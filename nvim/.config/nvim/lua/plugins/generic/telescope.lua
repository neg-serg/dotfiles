-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ nvim-telescope/telescope.nvim                                                │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'nvim-telescope/telescope.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'debugloop/telescope-undo.nvim',
    'jvgrootveld/telescope-zoxide',
    'MrcJkb/telescope-manix',
    'nvim-telescope/telescope-frecency.nvim',
    'nvim-telescope/telescope-live-grep-args.nvim',
    'brookhong/telescope-pathogen.nvim',
    -- NOTE: DO NOT put Telekasten here; configure it as its own plugin.
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

    -- Lazy builtin helper for keymaps
    local function builtin(name, opts)
      return function() return require('telescope.builtin')[name](opts or {}) end
    end

    -- Reuse your ignore list
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
    local short_find = { 'fd', '-H', '--ignore-vcs', '-d', '4', '--strip-cwd-prefix' }

    -- Safe previewer: keep it (cheap) but do not require previewers module at top
    local function safe_buffer_previewer_maker(filepath, bufnr, opts)
      local max_bytes = 1.5 * 1024 * 1024
      local stat = vim.loop.fs_stat(filepath)
      if stat and stat.size and stat.size > max_bytes then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<< file too large to preview >>' })
        return
      end
      if filepath:match('%.(%w+)$') and filepath:match('%.(png|jpg|jpeg|gif|webp|pdf|zip|7z|rar)$') then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<< binary file >>' })
        return
      end
      -- Lazy require previewer only when actually needed
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
          -- Optional safety limits (keep if you liked them):
          -- '--max-filesize','1M','--max-columns','200','--max-columns-preview',
        },
        mappings = {
          i = {
            ['<esc>'] = act('close'),
            ['<C-u>'] = false,
            ['<C-s>'] = act('select_horizontal'),
            ['<C-v>'] = act('select_vertical'),
            ['<C-t>'] = act('select_tab'),
            ['<A-q>'] = function(...) return require('telescope.actions').smart_send_to_qflist(...), require('telescope.actions').open_qflist(...) end,
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
        -- DO NOT set explicit sorter/previewer functions to avoid loading those modules at setup time
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
          theme = 'ivy', border = true, previewer = false,
          sorting_strategy = 'descending', prompt_title = false,
          find_command = short_find, layout_config = { height = 18 },
          hijack_netrw = false, grouped = true, hide_parent_dir = true,
          prompt_path = true, display_stat = false, git_status = false, depth = 2,
          hidden = { file_browser = false, folder_browser = false },
          mappings = {
            i = {
              ['<C-w>'] = function(prompt_bufnr, bypass)
                local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
                if picker:_get_prompt() == '' then
                  require('telescope').extensions.file_browser.actions.goto_parent_dir(prompt_bufnr, bypass)
                else
                  local t = function(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end
                  vim.api.nvim_feedkeys(t('<C-u>'), 'i', true)
                end
              end,
              ['<A-d>'] = false, ['<bs>'] = false,
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
          disable_devicons = false, ignore_patterns = ignore_patterns,
          path_display = { 'relative' }, previewer = false,
          prompt_title = false, results_title = false,
          show_scores = false, show_unindexed = true, use_sqlite = false,
        },
        undo = {
          use_delta = true, side_by_side = true, previewer = true,
          layout_strategy = 'flex',
          layout_config = {
            horizontal = { prompt_position = 'bottom', preview_width = 0.70 },
            vertical = { mirror = false }, width = 0.87, height = 0.80, preview_cutoff = 120,
          },
          mappings = {
            i = {
              ['<CR>']   = lazy_call('telescope-undo.actions', 'yank_additions'),
              ['<S-CR>'] = lazy_call('telescope-undo.actions', 'yank_deletions'),
              ['<C-CR>'] = lazy_call('telescope-undo.actions', 'restore'),
            },
          },
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
            ['<C-e>'] = { action = require('telescope._extensions.zoxide.utils').create_basic_command('edit') },
            ['<C-j>'] = act('cycle_history_next'),
            ['<C-k>'] = act('cycle_history_prev'),
            ['<C-b>'] = {
              keepinsert = true,
              action = function(sel)
                local t = require('telescope'); pcall(t.load_extension, 'file_browser')
                t.extensions.file_browser.file_browser({ cwd = sel.path })
              end,
            },
            ['<C-f>'] = {
              keepinsert = true,
              action = function(sel) return require('telescope.builtin').find_files({ cwd = sel.path }) end,
            },
            ['<Esc>'] = act('close'),
            ['<C-Enter>'] = { action = function(_) end },
          },
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
    })

    -- Only fzf is worth loading at startup; others load on demand
    pcall(telescope.load_extension, 'fzf')

    -- Smart files helper (git_files with graceful fallback)
    local function smart_files()
      local ok = pcall(require('telescope.builtin').git_files, { show_untracked = true })
      if not ok then require('telescope.builtin').find_files({ find_command = short_find }) end
    end

    local opts = { silent = true, noremap = true }

    -- Keymaps (all require modules lazily on press)
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
        vim.cmd('ProjectRoot')
      end
      local t = require('telescope'); pcall(t.load_extension, 'pathogen')
      t.extensions.pathogen.find_files({})
    end, opts)

    vim.keymap.set('v', '<leader>sg', function()
      local text = vim.fn.escape(vim.fn.getreg('v'), [[\]])
      local t = require('telescope'); pcall(t.load_extension, 'live_grep_args')
      t.extensions.live_grep_args.live_grep_args({ default_text = text })
    end, opts)
  end,
}
