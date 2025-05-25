-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ Saghen/blink.cmp                                                             │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' }, -- optional: provides snippets for the snippet source
  version = '1.*', -- use a release tag to download pre-built binaries
  -- build = 'nix run .#build-plugin',
  opts = {
    keymap = { preset = 'default' }, -- See :h blink-cmp-config-keymap for defining your own keymap
    appearance = { nerd_font_variant = 'mono'},
    completion = { documentation = { auto_show = false } }, -- (Default) Only show the documentation popup when manually triggered
    sources = {default = { 'lsp', 'path', 'snippets', 'buffer' },},
    fuzzy = { implementation = "prefer_rust_with_warning" },
    -- highlight = {use_nvim_cmp_as_default = true,},
    -- windows = {
    --   documentation = {
    --     border = vim.g.borderStyle,
    --     min_width = 15,
    --     max_width = 45, -- smaller, due to https://github.com/Saghen/blink.cmp/issues/194
    --     max_height = 10,
    --     auto_show = true,
    --     auto_show_delay_ms = 250,
    --   },
    --   autocomplete = {
    --     border = vim.g.borderStyle,
    --     min_width = 10, -- max_width controlled by draw-function
    --     max_height = 10,
    --     cycle = { from_top = false }, -- cycle at bottom, but not at the top
    --     draw = function(ctx)
    --       -- https://github.com/Saghen/blink.cmp/blob/9846c2d2bfdeaa3088c9c0143030524402fffdf9/lua/blink/cmp/types.lua#L1-L6
    --       -- https://github.com/Saghen/blink.cmp/blob/9846c2d2bfdeaa3088c9c0143030524402fffdf9/lua/blink/cmp/windows/autocomplete.lua#L298-L349
    --       -- differentiate LSP snippets from user snippets and emmet snippets
    --       local source, client = ctx.item.source_id, ctx.item.client_id
    --       if client and vim.lsp.get_client_by_id(client).name == "emmet_language_server" then source = "emmet" end
    --       local sourceIcons = { snippets = "󰩫", buffer = "󰦨", emmet = "" }
    --       local icon = sourceIcons[source] or ctx.kind_icon
    --       return {
    --         {
    --           " " .. ctx.item.label .. " ",
    --           fill = true,
    --           hl_group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
    --           max_width = 40,
    --         },
    --         { icon .. " ", hl_group = "BlinkCmpKind" .. ctx.kind },
    --       }
    --     end,
    --   },
    -- },
    -- kind_icons = {
    --   Text = "",
    --   Method = "󰊕",
    --   Function = "󰊕",
    --   Constructor = "",
    --   Field = "󰇽",
    --   Variable = "󰂡",
    --   Class = "󰜁",
    --   Interface = "",
    --   Module = "",
    --   Property = "󰜢",
    --   Unit = "",
    --   Value = "󰎠",
    --   Enum = "",
    --   Keyword = "󰌋",
    --   Snippet = "󰒕",
    --   Color = "󰏘",
    --   Reference = "",
    --   File = "",
    --   Folder = "󰉋",
    --   EnumMember = "",
    --   Constant = "󰏿",
    --   Struct = "",
    --   Event = "",
    --   Operator = "󰆕",
    --   TypeParameter = "󰅲",
    -- },
  },
  opts_extend = { "sources.default" }
}
