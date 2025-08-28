-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ L3MON4D3/LuaSnip                                                             │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'L3MON4D3/LuaSnip', -- snippets engine
    tag="v2.1.1",
    config=function()
        local status, vscode_snips = pcall(require, 'luasnip.loaders.from_vscode')
        if (not status) then return end
        vscode_snips.lazy_load()    
        local status, snipmate_snips = pcall(require'luasnip.loaders.from_snipmate')
        if (not status) then return end
        snipmate_snips.lazy_load()
        local status, luasnip_snips = pcall(require'luasnip.loaders.from_luasnip')
        if (not status) then return end
        luasnip_snips.lazy_load()
    end,
    dependencies={'rafamadriz/friendly-snippets',},
    event={'InsertEnter'}}
