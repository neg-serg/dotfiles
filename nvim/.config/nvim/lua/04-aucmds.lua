local au = vim.api.nvim_create_autocmd
local gr = vim.api.nvim_create_augroup

local main = gr("main", {clear=true})
local shada = gr("shada", {clear=true})
local utils = gr("utils", {clear=true})
local mode_change = gr("mode_change", {clear=true})
local custom_updates = gr("custom_updates", {clear=true})
local hi_yank = gr("hi_yank", {clear=true})

local function restore_cursor()
    au({"FileType"}, { buffer=0, once=true,
        callback = function()
            local types = {"nofile", "fugitive", "gitcommit", "gitrebase", "commit", "rebase", }
            if vim.fn.expand("%") == "" or types[vim.bo.filetype] ~= nil then
                return
            end
            local line = vim.fn.line
            if line([['"]]) > 0 and line([['"]]) <= line("$") then
                vim.api.nvim_command("normal! " .. [[g`"zv']])
            end
        end,
    })
end

au({'FocusGained','BufEnter','FileChangedShell','WinEnter'}, {command='checktime', group=main})
-- Disables automatic commenting on newline:
au({'Filetype'}, {
    pattern={'help', 'startuptime', 'qf', 'lspinfo'},
    command='nnoremap <buffer><silent> q :close<CR>',
    group=main})
au({"BufNewFile","BufRead"}, {
    group=main,
    pattern="**/systemd/**/*.service",
    callback=function() vim.bo.filetype="systemd" end})
-- Update binds when sxhkdrc is updated.
au({'BufWritePost'}, {pattern={'*sxhkdrc'}, command='!pkill -USR1 sxhkd', group=main})
au({'BufEnter'}, {command='set noreadonly', group=main})
au({'TermOpen'}, {pattern={'term://*'}, command='startinsert | setl nonumber | let &l:stl=" terminal %="', group=main})
au({'BufLeave'}, {pattern={'term://*'}, command='stopinsert', group=main})
au({"BufReadPost"}, {callback=restore_cursor, group=main, desc="auto line return"})
-- Clear search context when entering insert mode, which implicitly stops the
-- highlighting of whatever was searched for with hlsearch on. It should also
-- not be persisted between sessions.
au({'BufReadPre','FileReadPre'}, {command=[[let @/ = '']], group=mode_change})
au({'BufWritePost'}, {pattern='fonts.conf', command='!fc-cache', group=custom_updates})
au({'TextYankPost'}, {
    callback=function() vim.hl.on_yank{timeout=60, higroup="Search"} end,
    group=hi_yank})
au({'DirChanged'}, {pattern={'window','tab','tabpage','global'}, callback=function()
    vim.cmd("silent !zoxide add " .. vim.fn.getcwd())
    end,group=main})
if true == false then
    au({'CursorHold','TextYankPost','FocusGained','FocusLost'}, {pattern={'*'}, command='if exists(":rshada") | rshada | wshada | endif', group=shada})
end
au({'BufWritePost'}, {pattern={'*'}, 
    callback=function()
        if string.match(vim.fn.getline(1), "^#!") ~= nil then
            if string.match(vim.fn.getline(1), "/bin/") ~= nil then vim.cmd([[silent !chmod a+x <afile>]]) end
        end
    end, group=utils})
au({'BufNewFile','BufWritePre'}, {pattern={'*'},
    command=[[if @% !~# '\(://\)' | call mkdir(expand('<afile>:p:h'), 'p') | endif]],
    group=utils
})

vim.g.markdown_fenced_languages={'shell=bash'}
local file_syntax_map={
    {pattern='*.rasi',     syntax='scss'},
    {pattern='flake.lock', syntax='json'},
    {pattern='*.ignore',   syntax='gitignore'}, -- also ignore for fd/ripgrep
    {pattern='*.ojs',      syntax='javascript'},
    {pattern='*.astro',    syntax='astro'},
    {pattern='*.mdx',      syntax='mdx'}
}
for _, elem in ipairs(file_syntax_map) do
    au({'BufNewFile', 'BufRead'}, {
        pattern=elem.pattern,
        command='set syntax=' .. elem.syntax,
   })
end
