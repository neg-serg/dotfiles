-- :profile start profile.log
-- :profile func *
-- :profile file *
-- " At this point do slow actions
-- :profile pause
-- :noautocmd qall!
if vim.fn.has("nvim-0.9.2") ~= 1 then
    local message=table.concat({"You are using an unsupported version of Neovim."}, "\n")
    vim.notify(message, vim.log.levels.ERROR)
end
if vim.loader then vim.loader.enable() end
vim.g.mapleader = ','
vim.g.maplocalleader = ','
require'00-settings'
require'01-helpers'
require'01-plugins'
require'02-bindings'
require'04-aucmds'
require'08-cmds'
require'14-abbr'
require'62-sort-operator'
require'75-smart-cd'.setup()
local ok, langmapper = pcall(require, 'langmapper')
if ok then
    langmapper.automapping({ global = true, buffer = true })
end
