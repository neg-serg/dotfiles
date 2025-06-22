-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ ahmedkhalf/project.nvim                                                      │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'ahmedkhalf/project.nvim', -- superior project management
    config=function()
        require'project_nvim'.setup{
            manual_mode=true,
            detection_methods={'pattern','lsp'},
            show_hidden=true,
            silent_chdir=false,
        }
        map('n', 'er', '<Cmd>ProjectRoot<CR>', {silent=true})
    end
}
