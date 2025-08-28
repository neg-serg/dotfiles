-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ haya14busa/vim-asterisk                                                      │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'haya14busa/vim-asterisk', -- smartcase star
    config=function() 
        map('n', '*',   '<Plug>(asterisk-#)')
        map('n', '#',   '<Plug>(asterisk-*)')
        map('n', 'g*',  '<Plug>(asterisk-g#)')
        map('n', 'g#',  '<Plug>(asterisk-g*)')
        map('n', 'z*',  '<Plug>(asterisk-z#)')
        map('n', 'gz*', '<Plug>(asterisk-gz#)')
        map('n', 'z#',  '<Plug>(asterisk-z*)')
        map('n', 'gz#', '<Plug>(asterisk-gz*)')
    end
}
