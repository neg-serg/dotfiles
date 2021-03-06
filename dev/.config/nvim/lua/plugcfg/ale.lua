-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ w0rp/ale                                                                     │
-- └───────────────────────────────────────────────────────────────────────────────────┘
vim.g.ale_fixers = {
    ['javascript'] = 'eslint',
    ['json'] = 'jq',
    ['html'] = 'prettier',
    ['scss'] = 'stylelint',
    ['less'] = 'stylelint',
    ['css'] = 'stylelint',
    ['python'] = 'yapf',
    ['rust'] = 'rustfmt'
}
vim.g.ale_linters = {['python'] = {'bandit', 'jedils', 'mypy',
'prospector', 'pycodestyle', 'pydocstyle', 'pyflakes', 'pylama', 'pylint',
'pyls', 'pyre', 'pyright', 'vulture'}}
vim.g["ale_echo_msg_format"] = '%linter% %s %severity%'
vim.g["ale_sign_highlight_linenrs"] = 1
vim.g["ale_sign_error"] = ''
vim.g["ale_sign_warning"] = ''
