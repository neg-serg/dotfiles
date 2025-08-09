-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ nvim-telescope/telescope.nvim                                                │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'nvim-telescope/telescope.nvim',
  event = { 'VeryLazy' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'brookhong/telescope-pathogen.nvim',
    'debugloop/telescope-undo.nvim',
    'jvgrootveld/telescope-zoxide',
    'MrcJkb/telescope-manix',
    'nvim-telescope/telescope-frecency.nvim',
    'renerocksai/telekasten.nvim',
    'nvim-telescope/telescope-live-grep-args.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
    -- Speed booster:
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable('make') == 1 end },
  },
  config = function()
    local telescope = require('telescope')
    local previewers = require('telescope.previewers')
    local builtin = require('telescope.builtin')
    local actions = require('telescope.actions')
    local sorters = require('telescope.sorters')
    local action_state = require('telescope.actions.state')
    local lga_actions = require('telescope-live-grep-args.actions')

    -- Reuse your lists
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

    -- Fast & safe previewer: skip large/binary files
    local function safe_buffer_previewer_maker(filepath, bufnr, opts)
      -- Skip very large files (> 1.5 MB)
      local max_bytes = 1.5 * 1024 * 1024
      local stat = vim.loop.fs_stat(filepath)
      if stat and stat.size and stat.size > max_bytes then
        -- Show a tiny placeholder instead of trying to preview
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<< file too large to preview >>' })
        return
      end
      -- Skip obvious binaries
      if filepath:match('%.(%w+)$') and filepath:match('%.(png|jpg|jpeg|gif|webp|pdf|zip|7z|rar)$') then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { '<< binary file >>' })
        return
      end
      return previewers.buffer_previewer_maker(filepath, bufnr, opts)
    end

    telescope.setup({
      defaults = {
        vimgrep_arguments = {
          'rg',
          '--color=never', '--no-heading', '--with-filename',
          '--line-number', '--column', '--smart-case',
          '--hidden',
          -- Use separate args; no shell quotes here
          '--glob', '!.git',
          '--glob', '!.obsidian',
        },
        mappings = {
          i = {
            ['<esc>'] = actions.close,
            ['<C-u>'] = false,
            -- Quality-of-life openers:
            ['<C-s>'] = actions.select_horizontal,
            ['<C-v>'] = actions.select_vertical,
            ['<C-t>'] = actions.select_tab,
            ['<A-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<C-y>'] = function(prompt_bufnr)
              local e = action_state.get_selected_entry()
              if e and e.path then
                vim.fn.setreg('+', e.path)
                vim.notify('Path copied: ' .. e.path)
              end
            end,
          },
          n = {
            ['q'] = actions.close,
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
        path_display = { 'truncate' }, -- keeps tail of the path
        winblend = 8,
        border = {},
        borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        color_devicons = true,
        use_less = false,
        file_sorter = sorters.get_fuzzy_file,
        generic_sorter = sorters.get_generic_fuzzy_sorter,
        file_previewer = previewers.vim_buffer_cat.new,
        grep_previewer = previewers.vim_buffer_vimgrep.new,
        qflist_previewer = previewers.vim_buffer_qflist.new,
        -- Safe previewer to avoid lag with big/binary files
        buffer_previewer_maker = safe_buffer_previewer_maker,
        -- Better colors for bat, if installed
        set_env = { ['COLORTERM'] = 'truecolor' },
      },

      pickers = {
        find_files = {
          theme = 'ivy',
          border = false,
          previewer = false,
          sorting_strategy = 'descending',
          prompt_title = false,
          find_command = short_find,
          layout_config = { height = 12 },
        },
        buffers = {
          sort_lastused = true,
          theme = 'ivy',
          previewer = false,
          mappings = { i = { ['<C-d>'] = actions.delete_buffer } },
        },
      },

      extensions = {
        file_browser = {
          theme = 'ivy',
          border = true,
          previewer = false,
          sorting_strategy = 'descending',
          prompt_title = false,
          find_command = short_find,
          layout_config = { height = 18 },
          hijack_netrw = false,
          grouped = true,
          hide_parent_dir = true,
          prompt_path = true,
          display_stat = false,
          git_status = false,
          depth = 2,
          hidden = { file_browser = false, folder_browser = false },
          mappings = {
            ['i'] = {
              -- Keep your smart <C-w>
              ['<C-w>'] = function(prompt_bufnr, bypass)
                local cur = action_state.get_current_picker(prompt_bufnr)
                if cur:_get_prompt() == '' then
                  require('telescope').extensions.file_browser.actions.goto_parent_dir(prompt_bufnr, bypass)
                else
                  local function t(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end
                  vim.api.nvim_feedkeys(t('<C-u>'), 'i', true)
                end
              end,
              ['<A-d>'] = false,
              ['<bs>'] = false,
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
        undo = {
          use_delta = true,
          side_by_side = true,
          previewer = true,
          layout_strategy = 'flex',
          layout_config = {
            horizontal = { prompt_position = 'bottom', preview_width = 0.70 },
            vertical = { mirror = false },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            i = {
              ['<CR>']   = require('telescope-undo.actions').yank_additions,
              ['<S-CR>'] = require('telescope-undo.actions').yank_deletions,
              ['<C-CR>'] = require('telescope-undo.actions').restore,
            },
          },
        },
        zoxide = {
          mappings = {
            ['<S-Enter>'] = { action = function(sel) require('telescope').extensions.pathogen.find_files({ cwd = sel.path }) end },
            ['<Tab>']     = { action = function(sel) require('telescope').extensions.pathogen.find_files({ cwd = sel.path }) end },
            ['<C-e>']     = { action = require('telescope._extensions.zoxide.utils').create_basic_command('edit') },
            ['<C-j>']     = actions.cycle_history_next,
            ['<C-k>']     = actions.cycle_history_prev,
            ['<C-b>']     = {
              keepinsert = true,
              action = function(sel) require('telescope').extensions.file_browser.file_browser({ cwd = sel.path }) end,
            },
            ['<C-f>']     = {
              keepinsert = true,
              action = function(sel) builtin.find_files({ cwd = sel.path }) end,
            },
            ['<Esc>'] = actions.close,
            ['<C-Enter>'] = { action = function(_) end },
          },
        },
      },

      -- Live Grep Args
      live_grep_args = {
        auto_quoting = true,
        mappings = {
          i = {
            ['<C-k>']     = lga_actions.quote_prompt(),
            ['<C-i>']     = lga_actions.quote_prompt({ postfix = ' --iglob ' }),
            ['<C-space>'] = lga_actions.to_fuzzy_refine,
            -- Grep only open buffers:
            ['<C-o>']     = function()
              require('telescope').extensions.live_grep_args.live_grep_args({ grep_open_files = true })
            end,
            -- Grep in current buffer dir:
            ['<C-.>']     = function()
              require('telescope').extensions.live_grep_args.live_grep_args({ cwd = vim.fn.expand('%:p:h') })
            end,
          },
        },
      },
    })

    -- Always load extensions AFTER setup
    pcall(telescope.load_extension, 'fzf')
    pcall(telescope.load_extension, 'file_browser')
    pcall(telescope.load_extension, 'frecency')
    pcall(telescope.load_extension, 'undo')
    pcall(telescope.load_extension, 'live_grep_args')
    pcall(telescope.load_extension, 'pathogen')
    pcall(telescope.load_extension, 'manix')
    pcall(telescope.load_extension, 'zoxide')
    -- telekasten integrates via its own setup; leave as-is

    -- Helper: git_files with fallback to find_files
    local function smart_files()
      local ok = pcall(builtin.git_files, { show_untracked = true })
      if not ok then
        builtin.find_files({ find_command = short_find })
      end
    end

    local opts = { silent = true, noremap = true }

    -- Your mappings (kept), plus a couple of tiny quality-of-life ones
    Map('n', 'cd', function()
      require('telescope').load_extension('zoxide').list(
        require('telescope.themes').get_ivy({ layout_config = { height = 8 }, border = false })
      )
    end, opts)

    Map('n', '<leader>.', function()
      vim.cmd('Telescope frecency theme=ivy layout_config={height=12} sorting_strategy=descending')
    end, opts)

    vim.keymap.set('n', '<leader>l', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', opts)

    Map('n', 'E', function()
      if vim.bo.filetype then
        require('oil.actions').cd.callback()
      else
        vim.cmd('chdir %:p:h')
      end
      require('telescope').extensions.pathogen.find_files({})
    end, opts)

    Map('n', 'ee', smart_files, opts)

    Map('n', '<leader>L', function()
      if vim.bo.filetype then
        require('oil.actions').cd.callback()
      else
        vim.cmd('ProjectRoot')
      end
      require('telescope').extensions.pathogen.find_files({})
    end, opts)

    -- Bonus: visual grep with LGA
    vim.keymap.set('v', '<leader>sg', function()
      local text = vim.fn.escape(vim.fn.getreg('v'), [[\]])
      require('telescope').extensions.live_grep_args.live_grep_args({ default_text = text })
    end, opts)
  end,
}
