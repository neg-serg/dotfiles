-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ nvim-telescope/telescope.nvim                                                │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'nvim-telescope/telescope.nvim', -- modern fuzzy-finder over lists
    event={'VeryLazy'},
    dependencies={
        'nvim-lua/plenary.nvim', -- lua functions
        'brookhong/telescope-pathogen.nvim', -- telescope change directory on the fly
        'debugloop/telescope-undo.nvim', -- telescope show undo
        'jvgrootveld/telescope-zoxide', -- telescope zoxide integration
        'MrcJkb/telescope-manix', -- manix support
        'nvim-telescope/telescope-frecency.nvim', -- MRU frecency
        'renerocksai/telekasten.nvim', -- telekasten support
        'nvim-telescope/telescope-live-grep-args.nvim', -- ripgrep integration
        'nvim-telescope/telescope-file-browser.nvim', -- file browser via telescope
    },
    config=function()
        local telescope=require'telescope'
        local pathogen=telescope.load_extension'pathogen'
        local z_utils=require'telescope._extensions.zoxide.utils'
        local previewers=require'telescope.previewers'
        local builtin=require'telescope.builtin'
        local actions=require'telescope.actions'
        local manix=telescope.load_extension'manix'
        local zoxide=telescope.load_extension'zoxide'
        local sorters=require'telescope.sorters'
        local long_find={'rg','--files','--hidden','-g','!.git'}
        local short_find={'fd','-H','--ignore-vcs','-d','4','--strip-cwd-prefix'}
        local fb_actions=telescope.extensions.file_browser.actions
        local action_state=require'telescope.actions.state'
        local lga_actions=require'telescope-live-grep-args.actions'
        local ignore_patterns={
            '__pycache__/', '__pycache__/*',
            'build/', 'gradle/', 'node_modules/', 'node_modules/*',
            'smalljre_*/*', 'target/', 'vendor/*',
            '.dart_tool/', '.git/', '.github/', '.gradle/', '.idea/', '.vscode/',
            '%.sqlite3', '%.ipynb', '%.lock', '%.pdb', '%.dll', '%.class', '%.exe',
            '%.cache', '%.pdf', '%.dylib', '%.jar', '%.docx', '%.met', '%.burp',
            '%.mp4', '%.mkv', '%.rar', '%.zip', '%.7z', '%.tar', '%.bz2', '%.epub',
            '%.flac','%.tar.gz',
        }

        telescope.setup{
            defaults={
                vimgrep_arguments={
                    'rg',
                    '--color=never', '--no-heading', '--with-filename',
                    '--line-number', '--column', '--smart-case',
                    "--glob='!*.git*'", "--glob='!*.obsidian'",
                    "--hidden"
                },
                mappings={i={["<esc>"]=actions.close, ["<C-u>"]=false}},
                dynamic_preview_title=true,
                prompt_prefix="❯> ",
                selection_caret="• ",
                entry_prefix="  ",
                initial_mode="insert",
                selection_strategy="reset",
                sorting_strategy="descending",
                layout_strategy="vertical",
                layout_config={
                    prompt_position="bottom",
                    horizontal={mirror=false},
                    vertical={mirror=false},
                },
                file_ignore_patterns=ignore_patterns,
                path_display={shorten=8},
                winblend=8,
                border={},
                borderchars={'─', '│', '─', '│', '╭', '╮', '╯', '╰'},
                color_devicons=true,
                use_less=false,
                file_sorter=sorters.get_fuzzy_file,
                generic_sorter=sorters.get_generic_fuzzy_sorter,
                file_previewer=previewers.vim_buffer_cat.new,
                grep_previewer=previewers.vim_buffer_vimgrep.new,
                qflist_previewer=previewers.vim_buffer_qflist.new,
                buffer_previewer_maker=previewers.buffer_previewer_maker
            },
            extensions={
                file_browser={
                    theme='ivy',
                    border=true,
                    previewer=false,
                    sorting_strategy="descending",
                    prompt_title=false,
                    find_command=short_find,
                    layout_config={height=18},
                    hijack_netrw=false,
                    grouped=true,
                    hide_parent_dir=true,
                    prompt_path=true,
                    display_stat=false,
                    git_status=false,
                    depth=2,
                    hidden={
                        file_browser=false,
                        folder_browser=false 
                    },
                    mappings={
                        ['i']={
                            ["<C-w>"] = function(prompt_bufnr, bypass)
                                local current_picker = action_state.get_current_picker(prompt_bufnr)
                                if current_picker:_get_prompt() == "" then
                                    fb_actions.goto_parent_dir(prompt_bufnr, bypass)
                                else
                                    local function t(str)
                                        return vim.api.nvim_replace_termcodes(str, true, true, true)
                                    end
                                    vim.api.nvim_feedkeys(t'<C-u>', 'i', true)
                                end
                            end,
                            ['<A-d>']=false,
                            ['<bs>']=false,
                        },
                        ['n']={},
                    },
                },
                pathogen={
                    use_last_search_for_live_grep=false,
                    attach_mappings = function(map, actions)
                        map("i", "<C-o>", actions.proceed_with_parent_dir)
                        map("i", "<C-l>", actions.revert_back_last_dir)
                        map("i", "<C-b>", actions.change_working_directory)
                    end,
                },
                frecency={
                    disable_devicons=false,
                    ignore_patterns=ignore_patterns,
                    path_display={"relative"},
                    previewer=false,
                    prompt_title=false,
                    results_title=false,
                    show_scores=false,
                    show_unindexed=true,
                    use_sqlite=false,
                },
                undo={
                    use_delta=true,
                    side_by_side=true,
                    previewer=true,
                    layout_strategy="flex",
                    layout_config={
                        horizontal={prompt_position="bottom", preview_width=0.70},
                        vertical={mirror=false},
                        width=0.87,
                        height=0.80,
                        preview_cutoff=120,
                    },
                    mappings={
                        i={
                            ['<CR>']=require'telescope-undo.actions'.yank_additions,
                            ['<S-CR>']=require'telescope-undo.actions'.yank_deletions,
                            ['<C-CR>']=require'telescope-undo.actions'.restore,
                        },
                        n={
                            ["cd"]=function(prompt_bufnr)
                                local selection=require("telescope.actions.state").get_selected_entry()
                                local dir=vim.fn.fnamemodify(selection.path, ":p:h")
                                require("telescope.actions").close(prompt_bufnr)
                                vim.cmd(string.format("silent lcd %s", dir)) -- Depending on what you want put `cd`, `lcd`, `tcd`
                            end
                        }
                    },
                },
                zoxide={
                    mappings={
                        ["<S-Enter>"]={action=function(selection) pathogen.find_files{cwd=selection.path} end},
                        ["<Tab>"]={action=function(selection) pathogen.find_files{cwd=selection.path} end},
                        ["<C-e>"]={action=z_utils.create_basic_command("edit")},
                        ["<C-j>"]=actions.cycle_history_next,
                        ["<C-k>"]=actions.cycle_history_prev,
                        ["<C-b>"]={
                            keepinsert=true,
                            action=function(selection)
                                telescope.extensions.file_browser.file_browser({cwd=selection.path})
                            end,
                        },
                        ["<C-f>"]={
                            keepinsert=true,
                            action=function(selection)
                                builtin.find_files({cwd=selection.path})
                            end,
                        },
                        ["<Esc>"]=actions.close,
                        ["<C-Enter>"]={action=function(_) end},
                    },
                },
            },
            pickers={
                find_files={
                    theme="ivy",
                    border=false,
                    previewer=false,
                    sorting_strategy="descending",
                    prompt_title=false,
                    find_command=short_find,
                    layout_config={height=12},
                }
            },
            live_grep_args={
                auto_quoting=true, -- enable/disable auto-quoting define mappings, e.g.
                mappings={ -- extend mappings
                    i={
                        ["<C-k>"]=lga_actions.quote_prompt(),
                        ["<C-i>"]=lga_actions.quote_prompt({ postfix=" --iglob " }),
                        ["<C-space>"]=lga_actions.to_fuzzy_refine, -- freeze the current list and start a fuzzy search in the frozen list
                    },
                },
            }
        }
        telescope.load_extension'file_browser'
        telescope.load_extension'frecency'
        telescope.load_extension'undo'
        telescope.load_extension'live_grep_args'

        local opts={silent=true, noremap=true}
        Map('n', 'cd', function()
            telescope.load_extension'zoxide'.list(
                require'telescope.themes'.get_ivy(
                    {layout_config={height=8}, border=false}
        )) end, opts)
        Map('n', "<leader>.", function()
            vim.cmd'Telescope frecency theme=ivy layout_config={height=12} sorting_strategy=descending'
        end, opts)
        vim.keymap.set("n", "<leader>l", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")
        Map('n', 'E', function()
            if vim.bo.filetype then
                require'oil.actions'.cd.callback()
            else 
                vim.cmd'chdir %:p:h'
            end
            pathogen.find_files{}
        end, opts)
        Map('n', '[Qleader]e', function() pathogen.find_files{} end, opts)
        Map('n', '<leader>L', function() 
            if vim.bo.filetype then
                require'oil.actions'.cd.callback()
            else
                vim.cmd'ProjectRoot'
            end
            pathogen.find_files{}
        end, opts)
    end
}
