-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ andymass/vim-matchup                                                         │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'andymass/vim-matchup', -- generic matcher
    config=function()
        vim.g.matchup_matchparen_enabled=0
        vim.g.matchup_motion_enabled=0
        -- text objects are enabled by default; no need to set
    end,
    event={'BufRead','BufNewFile'}}
