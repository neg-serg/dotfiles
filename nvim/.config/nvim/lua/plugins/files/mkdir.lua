-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ jghauser/mkdir.nvim                                                          │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'jghauser/mkdir.nvim', -- auto make dir when needed
    config=function() require'mkdir' end, event='BufWritePre'}
