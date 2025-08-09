-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ renerocksai/telekasten.nvim                                                  │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'renerocksai/telekasten.nvim',
  ft = 'md', -- lazy-load on markdown buffers
  config = function()
    local home = vim.fn.expand('~/1st_level')

    -- Ensure important subdirs exist (idempotent)
    local function ensure_dirs()
      local dirs = { home, home .. '/images', home .. '/templates', home .. '/dailies', home .. '/weeklies' }
      for _, d in ipairs(dirs) do
        if vim.fn.isdirectory(d) == 0 then vim.fn.mkdir(d, 'p') end
      end
    end
    ensure_dirs()

    local ok, telekasten = pcall(require, 'telekasten')
    if not ok then return end

    telekasten.setup({
      -- Core vault settings
      home = home,
      take_over_my_home = true,      -- enable TK for files in vault
      auto_set_filetype = false,     -- let your md/treesitter handle filetype
      extension = '.md',
      new_note_filename = 'title',   -- filename from title
      uuid_type = '%Y%m%d%H%M%S',    -- collision-safe, second precision
      uuid_sep = '-',
      sort = 'modified',             -- search notes by last modified first
      follow_creates_nonexisting = true,
      rename_update_links = true,
      subdirs_in_links = true,

      -- Structure
      dailies   = home .. '/dailies',
      weeklies  = home .. '/weeklies',
      templates = home .. '/templates',
      image_subdir = 'images',

      -- Behavior & UI
      image_link_style = 'markdown',
      template_handling = 'always_ask',
      close_after_yanking = false,
      insert_after_inserting = true,
      tag_notation = '#tag',
      command_palette_theme = 'ivy',
      show_tags_theme = 'ivy',

      -- Media preview via Telescope (make sure extension is loaded)
      media_previewer = 'telescope-media-files',

      -- Optional calendar integration (uncomment if you use calendar-vim)
      -- plug_into_calendar = true,
      -- calendar_opts = { weeknm = 4, calendar_monday = 1 },
    })

    -- Buffer-local mappings only for files inside the vault
    local group = vim.api.nvim_create_augroup('telekasten_vault_keymap', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
      group = group,
      pattern = home .. '/**/*.md',
      callback = function(args)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, buffer = args.buf, desc = desc })
        end

        -- Links & images
        map('i', '<leader>[',  function() require('telekasten').insert_link({ i = true }) end, 'TK: Insert link (i)')
        map('n', '<C-i>',      function() require('telekasten').paste_img_and_link() end,    'TK: Paste image & link')
        map('n', '<C-S-i>',    function() require('telekasten').insert_img_link({ i = true }) end, 'TK: Insert image link')

        -- Navigation / actions
        map('n', '<C-m>',      function() require('telekasten').follow_link() end,           'TK: Follow link')
        map('n', '<S-m>',      function() require('telekasten').browse_media() end,          'TK: Browse media')
        map('n', '<C-t>',      function() require('telekasten').toggle_todo() end,           'TK: Toggle TODO')
        map('n', '<C-y>',      function() require('telekasten').yank_notelink() end,         'TK: Yank note link')
        map('n', '<leader>b',  function() require('telekasten').show_backlinks() end,        'TK: Backlinks')
        map('n', '<leader>tt', function() require('telekasten').show_tags() end,             'TK: Show tags')

        -- Finders (useful quick picks)
        map('n', '<leader>nf', function() require('telekasten').find_notes() end,            'TK: Find notes')
        map('n', '<leader>ns', function() require('telekasten').search_notes() end,          'TK: Search notes')
        map('n', '<leader>nl', function() require('telekasten').list_notes() end,            'TK: List notes')

        -- Daily / weekly (enable if you actually use them)
        map('n', '<leader>nd', function() require('telekasten').goto_today() end,            'TK: Today')
        map('n', '<leader>nw', function() require('telekasten').goto_thisweek() end,         'TK: This week')

        -- Create from title / template
        map('n', '<leader>nn', function() require('telekasten').new_note() end,              'TK: New note')
        map('n', '<leader>nt', function() require('telekasten').new_templated_note() end,    'TK: New templated note')
      end,
    })

    -- Optional: light-weight Markdown UX in vault (no global side effects)
    vim.api.nvim_create_autocmd('FileType', {
      group = group,
      pattern = 'markdown',
      callback = function(args)
        local path = vim.api.nvim_buf_get_name(args.buf)
        if not path:find(vim.pesc(home), 1, true) then return end
        -- Pretty defaults inside vault
        vim.opt_local.wrap = true
        vim.opt_local.conceallevel = 2
        vim.opt_local.spell = false -- set true if you want spellcheck
      end,
    })

    -- Telescope media-files extension (required for media_previewer)
    -- Make sure you have 'nvim-telescope/telescope-media-files.nvim' in your plugin list.
    pcall(function()
      local telescope_ok, telescope = pcall(require, 'telescope')
      if telescope_ok then
        telescope.load_extension('media_files')
      end
    end)
  end,
}
