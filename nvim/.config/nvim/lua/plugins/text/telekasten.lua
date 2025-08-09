-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ renerocksai/telekasten.nvim                                                  │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'renerocksai/telekasten.nvim', ft='md', -- better md wiki stuff
        config=function()
            local home=vim.fn.expand("~/1st_level")
            local status, telekasten = pcall(require, 'telekasten')
            if (not status) then return end

            telekasten.setup({
                home=home,
                take_over_my_home=true, -- if true, telekasten will be enabled when opening a note within the configured home
                auto_set_filetype=false,
                dailies='',
                weeklies='',
                templates='',
                image_subdir='',
                extension=".md",
                new_note_filename="title",
                uuid_type="%Y%m%d%H%M",
                uuid_sep="-",
                follow_creates_nonexisting=true,
                dailies_create_nonexisting=true,
                weeklies_create_nonexisting=true,
                journal_auto_open=false,
                image_link_style="markdown",
                sort="filename",
                close_after_yanking=false,
                insert_after_inserting=true,
                tag_notation='#tag',
                command_palette_theme="ivy",
                show_tags_theme="ivy",
                subdirs_in_links=true, -- when linking to a note in subdir/, create a [[subdir/title]] link instead of a [[title only]] link
                template_handling="always_ask",
                rename_update_links=true, -- should all links be updated when a file is renamed
                media_previewer="telescope-media-files",
            })

            local opts={silent=true, noremap=true, buffer=true}
            vim.api.nvim_create_autocmd({"BufNewFile","BufRead"}, {
                pattern="*.md",
                group=vim.api.nvim_create_augroup('telekasten_only_keymap', {clear=true}),
                callback=function()
                    vim.keymap.set('i', '<leader>[', '<Cmd>lua require"telekasten".insert_link({i=true})<CR>', opts)
                    vim.keymap.set('n', '<C-S-i>', '<Cmd>lua require"telekasten".insert_img_link({ i=true })<CR>', opts)
                    vim.keymap.set('n', '<C-a>', '<Cmd>lua require"telekasten".show_tags()<CR>', opts)
                    vim.keymap.set('n', '<C-i>', '<Cmd>lua require"telekasten".paste_img_and_link()<CR>', opts)
                    vim.keymap.set('n', '<C-m>', '<Cmd>lua require"telekasten".follow_link()<CR>', opts)
                    vim.keymap.set('n', '<S-m>', '<Cmd>lua require"telekasten".browse_media()<CR>', opts)
                    vim.keymap.set('n', '<C-t>', '<Cmd>lua require"telekasten".toggle_todo()<CR>', opts)
                    vim.keymap.set('n', '<C-y>', '<Cmd>lua require"telekasten".yank_notelink()<CR>', opts)
                    vim.keymap.set('n', '<leader>b', '<Cmd>lua require"telekasten".show_backlinks()<CR>', opts)
                end,
            })
        end}
