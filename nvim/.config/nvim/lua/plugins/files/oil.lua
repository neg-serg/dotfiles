-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ stevearc/oil.nvim                                                            │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'stevearc/oil.nvim',  -- nice netrw replacement
    enabled=false,
    config=function()
        require'oil'.setup({
            columns={
                "icon",
            },
            buf_options={ buflisted=false, bufhidden="hide"}, -- Buffer-local options to use for oil buffers
            -- Window-local options to use for oil buffers
            win_options={
                wrap=false,
                signcolumn="yes",
                cursorcolumn=false,
                foldcolumn="0",
                spell=false,
                list=false,
                conceallevel=3,
                concealcursor="n",
            },
            default_file_explorer=true, -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`
            restore_win_options=true, -- Restore window options to previous values when leaving an oil buffer
            skip_confirm_for_simple_edits=false, -- Skip the confirmation popup for simple operations
            delete_to_trash=false, -- Deleted files will be removed with the trash_command (below).
            prompt_save_on_select_new_entry=true, -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
            -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
            -- options with a `callback` (e.g. {callback=function() ... end, desc="", nowait=true})
            -- Additionally, if it is a string that matches "actions.<name>",
            -- it will use the mapping at require("oil.actions").<name>
            -- Set to `false` to remove a keymap
            -- See :help oil-actions for a list of all available actions
            keymaps={
                ["g?"]="actions.show_help",
                ["<CR>"]="actions.select",
                ["<C-s>"]="actions.select_vsplit",
                ["<C-h>"]="actions.select_split",
                ["<C-t>"]="actions.select_tab",
                ["<C-p>"]="actions.preview",
                ["<C-c>"]="actions.close",
                ["<C-l>"]="actions.refresh",
                ["-"]="actions.parent",
                ["_"]="actions.open_cwd",
                ["`"]="actions.cd",
                ["~"]="actions.tcd",
                ["g."]="actions.toggle_hidden",
            },
            -- Set to false to disable all of the above keymaps
            use_default_keymaps=true,
            view_options={
                show_hidden=true, -- Show files and directories that start with "."
                is_hidden_file=function(name, bufnr) -- This function defines what is considered a "hidden" file
                    return vim.startswith(name, ".")
                end,
                is_always_hidden=function(name, bufnr) -- This function defines what will never be shown, even when `show_hidden` is set
                    return false
                end,
            },
            -- Configuration for the floating window in oil.open_float
            float={
                -- Padding around the floating window
                padding=2,
                max_width=0,
                max_height=0,
                border='rounded',
                win_options={winblend=10},
            },
            -- Configuration for the actions floating preview window
            preview={
                -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
                -- min_width and max_width can be a single value or a list of mixed integer/float types.
                -- max_width={100, 0.8} means "the lesser of 100 columns or 80% of total"
                max_width=0.9,
                -- min_width={40, 0.4} means "the greater of 40 columns or 40% of total"
                min_width={40, 0.4},
                -- optionally define an integer/float for the exact width of the preview window
                width=nil,
                -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
                -- min_height and max_height can be a single value or a list of mixed integer/float types.
                -- max_height={80, 0.9} means "the lesser of 80 columns or 90% of total"
                max_height=0.9,
                -- min_height={5, 0.1} means "the greater of 5 columns or 10% of total"
                min_height={5, 0.1},
                -- optionally define an integer/float for the exact height of the preview window
                height=nil,
                border='rounded',
                win_options={winblend=0},
            },
            -- Configuration for the floating progress window
            progress={
                max_width=0.9,
                min_width={40, 0.4},
                width=nil,
                max_height={10, 0.9},
                min_height={5, 0.1},
                height=nil,
                border='rounded',
                minimized_border='none',
                win_options={
                    winblend=0,
                },
            },
        })
        vim.api.nvim_buf_set_keymap(0, 'n', 'q', '<Cmd>q<CR>', {noremap=true})
        vim.api.nvim_buf_set_keymap(0, 'n', '<BS>', 'function() require("oil").open() end, { desc = "oil: goto parent dir" }', {noremap=true})
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ed', ':q<CR>', {noremap=true})
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" }) -- mimic the vim-vinegar
    end,
    dependencies={'nvim-tree/nvim-web-devicons'}}
