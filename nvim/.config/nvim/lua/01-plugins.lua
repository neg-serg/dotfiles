local lazypath=vim.fn.stdpath('data')..'/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git', lazypath})
end
vim.opt.rtp:prepend(lazypath)
require'lazy'.setup({
    spec={
        {import='plugins/performance'}, -- █▓▒░ Performance / Fixes
        {import='plugins/generic'},     -- █▓▒░ Generic
        {import='plugins/completion'},  -- █▓▒░ Completion
        {import='plugins/dev'},         -- █▓▒░ Dev
        {import='plugins/debug'},       -- █▓▒░ Debug
        {import='plugins/text'},        -- █▓▒░ Text
        {import='plugins/edit'},        -- █▓▒░ Edit
        {import='plugins/appearance'},  -- █▓▒░ Appearance
        {import='plugins/filetypes'},   -- █▓▒░ Filetypes
        {import='plugins/dcvs'},        -- █▓▒░ DCVS
        {import='plugins/panel'},       -- █▓▒░ Panel
    },
    defaults={lazy=false},
    install={colorscheme={"neg"}},
    ui={icons={ft="", lazy="󰂠 ", loaded="", not_loaded=""},},
	performance={
	  cache={enabled=true,},
	  reset_packpath=true,
	  rtp={disabled_plugins={"gzip","matchparen","netrwPlugin","tarPlugin","tohtml","tutor","zipPlugin",},},
	},
})
