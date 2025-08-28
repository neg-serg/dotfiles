-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ folke/noice.nvim                                                             │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'folke/noice.nvim', -- better UX
    event={'VeryLazy'},
    config=function()
        local status, noice = pcall(require, 'noice')
        if (not status) then return end

        noice.setup({
            cmdline={
                enabled=true,
                view='cmdline',
                format={
                    IncRename={title=' Rename '},
                    substitute={pattern='^:%%?s/', icon=' ', ft='regex', title=''},
                    input={icon=' ', lang='text', view='cmdline_popup', title=''},
                },
            },
            presets={
                bottom_search=true, -- use a classic bottom cmdline for search
                command_palette=false, -- position the cmdline and popupmenu together
                long_message_to_split=true, -- long messages will be sent to a split
                lsp_doc_border=true, -- add a border to hover docs and signature help
                inc_rename=true, -- enables an input dialog for inc-rename.nvim
            },
            smart_move={
                -- noice tries to move out of the way of existing floating windows.
                enabled=false, -- you can disable this behaviour here
                -- add any filetypes here, that shouldn't trigger smart move.
                excluded_filetypes={'cmp_menu', 'cmp_docs', 'notify'},
            },
            routes={
                {opts={skip=true},
                filter={
                    any={
                        {event='msg_show', kind='search_count'},
                        {event='msg_show', find='^E486:',},
                        {event='msg_show', find='^/.*$',},
                        {event='msg_show', kind='', find='written',},
                        {event='msg_show', kind='', find='1 time',},
                        {event='msg_show', kind='', find='Nothing to repeat',},
                        {event='msg_show', kind='', find='yanked',},
                        {event='msg_show', find='; before #',},
                        {event='msg_show', find='; after #',},
                        {event='msg_show', find='%d+ lines, %d+ bytes'},
                        {event='msg_show', kind='', find='line less',},
                        {event='msg_show', kind='', find='more line',},
                        {event='msg_show', find='go up one level',},
                        {event='msg_show', find='line %d+ of %d+'},
                        {event='msg_show', find='%d+ line'},
                        {event='msg_show', find='%d+ more line'},
                        {event='msg_show', kind='search_count'},
                        {event='msg_show', find='%d+L, %d+B'},
                        {event='msg_show', find='^Hunk %d+ of %d'},
                        {event='msg_show', find='%d+ change'},
                    }
                }
            },
            {filter={find='No active Snippet'}, opts={skip=true}},
            {filter={find='waiting for cargo metadata'}, opts={skip=true}},
            -- Show 'recording' messages
            {view='notify', filter={event='msg_showmode'}},
            -- Hide 'No information available' messages
            {view='notify', filter={find='No information available',}, opts={skip=true}},
        },
        views={
            vsplit={size={width="auto"}},
            split={win_options={winhighlight={Normal="Normal"}}},
            popup={
                border={style=border, padding={0, 1}},
            },
            cmdline_popup={
                position={row=5, col="50%"},
                size={width="auto", height="auto"},
                border={style=border, padding={0, 1}},
            },
            confirm={
                border={style=border, padding={0, 1}, text={top=""}},
            },
            popupmenu={
                relative="editor",
                size={width=60, height=8},
                border={style=border, padding={0, 1}},
                win_options={winhighlight={Normal="NotifyFloat", FloatBorder="FloatBorder"}},
            },
        },
        lsp={
            progress={
                enabled=true,
                format='lsp_progress',
                format_done='lsp_progress_done',
                throttle=1000 / 30, -- frequency to update lsp progress message
                view='mini',
            },
            override={
                ['vim.lsp.util.convert_input_to_markdown_lines']=true,
                ['vim.lsp.util.stylize_markdown']=true,
                ['cmp.entry.get_documentation']=true,
            },
            hover={enabled=false},
            signature={
                enabled=true,
                auto_open={
                    enabled=true,
                    trigger=true, -- Automatically show signature help when typing a trigger character from the LSP
                    luasnip=true, -- Will open signature help when jumping to Luasnip insert nodes
                    throttle=50, -- Debounce lsp signature help request by 50ms
                },
            },
            documentation={
                opts={
                    border={ style=border },
                    position={ row=2 },
                },
            },
            messages={
                -- Messages shown by lsp servers
                enabled=true,
                view='notify',
                view_error='notify', -- view for errors
                view_warn='notify', -- view for warnings
                view_history='messages', -- view for :messages
                view_search=false, -- view for search count messages. Set to `false` to disable
                opts={},
            },
            popupmenu={
                enabled=true, -- enables the Noice popupmenu UI
                backend='nui', -- backend to use to show regular cmdline completions
                kind_icons={}, -- set to `false` to disable icons
            },
        },
    })
    end,
    dependencies={'MunifTanjim/nui.nvim'}}
