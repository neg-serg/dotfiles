-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ lewis6991/gitsigns.nvim                                                      │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'lewis6991/gitsigns.nvim', -- fast git decorations
    dependencies='plenary.nvim',
    config=function()
        local status, gitsigns=pcall(require, 'gitsigns')
        if (not status) then return end
        gitsigns.setup {
            current_line_blame=true,
            current_line_blame_opts={
                delay=1000,
                virt_text = true,
                virt_text_pos = 'right_align',  -- Или 'eol'
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                vim.keymap.set('n', '<leader>b', function()
                    gs.preview_hunk()
                end, { buffer = bufnr, desc = 'Git: [H]over [B]lame' })
                vim.keymap.set('n', '<leader>q', function()
                    gs.blame_line({full=true})
                end, { buffer=bufnr})
            end,
            signs={
                add={text='▎', show_count=false},
                change={text='▎', show_count=false},
                delete={text='_', show_count=false},
                topdelete={text='‾', show_count=false},
                changedelete={text='~', show_count=false},
            },
            count_chars={
                [1]  ="",   [2]="₂",  [3]="₃",
                [4]  ="₄",  [5]="₅",  [6]="₆",
                [7]  ="₇",  [8]="₈",  [9]="₉",
                ["+"]="₊",
            },
            linehl=false, -- toggle with `:Gitsigns toggle_linehl`
            numhl=false, -- toggle with `:Gitsigns toggle_nunhl`
            signcolumn=true,  -- toggle with `:Gitsigns toggle_signs`
            word_diff=false, -- toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir={interval=500, follow_files=true},
            sign_priority=6,
            update_debounce=100,
            max_file_length=40000,
            status_formatter=nil,
            diff_opts={ algorithm="patience", internal=true, indent_heuristic=true,},
            attach_to_untracked=true,
            current_line_blame=false, -- Toggle with `:Gitsigns toggle_current_line_blame`
            current_line_blame_opts={
                virt_text=true,
                virt_text_pos='eol', -- 'eol' | 'overlay' | 'right_align'
                delay=1000,
                ignore_whitespace=false,
            },
        }
        local opts={silent=true, noremap=true}
        map('n', '<leader>gb', '<cmd>Gitsigns blame_line<cr>', opts)
        map('n', '<leader>g]', '<cmd>Gitsigns next_hunk<cr>', opts)
        map('n', '<leader>g[', '<cmd>Gitsigns prev_hunk<cr>', opts)
        map('n', '<leader>g?', '<cmd>Gitsigns preview_hunk<cr>', opts)
    end,
    event={'BufNewFile','BufRead'}} -- async gitsigns
