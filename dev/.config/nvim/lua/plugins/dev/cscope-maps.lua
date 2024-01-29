-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ dhananjaylatkar/cscope_maps.nvim                                             │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'dhananjaylatkar/cscope_maps.nvim', -- cscope mapping support
    dependencies={
        'nvim-telescope/telescope.nvim', -- optional [for picker='telescope']
        'ibhagwan/fzf-lua', -- optional [for picker='fzf-lua']
        'nvim-tree/nvim-web-devicons', -- optional [for devicons in telescope or fzf]
    enabled=false,
    }, opts={}}
