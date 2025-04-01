-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ hrsh7th/nvim-cmp                                                             │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'hrsh7th/nvim-cmp', -- completion engine
  dependencies={
    'hrsh7th/cmp-nvim-lsp', -- cmp lsp support
    'hrsh7th/cmp-nvim-lua', -- cmp neovim lua api support
    'hrsh7th/cmp-path', -- cmp path completion support
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-buffer',
    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-nvim-lua',
    'onsails/lspkind-nvim',
    { 'roobert/tailwindcss-colorizer-cmp.nvim', config = true }
  },
  config=function()
    local ok, cmp=pcall(require, 'cmp')
    if not ok then return end
    local ok, lsp_kind=pcall(require, 'lspkind')
    if not ok then return end
    local ok_snip, luasnip=pcall(require, 'luasnip')
    if not ok_snip then return end
    local has_words_before=function()
      local line, col=unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
    end
    local kind_icons={
      Text="",
      Method="",
      Function="",
      Constructor="",
      Field="",
      Variable="",
      Class="",
      Interface="",
      Module="",
      Property="",
      Unit="",
      Value="",
      Enum="",
      Keyword="",
      Snippet="",
      Color="",
      File="",
      Reference="",
      Folder="",
      EnumMember="",
      Constant="",
      Struct="",
      Event="",
      Operator="",
      TypeParameter="",
    }
    local cmp_next = function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        elseif require("luasnip").expand_or_jumpable() then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
        else
            fallback()
        end
    end
    local cmp_prev = function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        elseif require("luasnip").jumpable(-1) then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
        else
            fallback()
        end
    end
    lsp_kind.init()
    cmp.setup({
      preselect = cmp.PreselectMode.None,
      window = {
          completion = cmp.config.window.bordered({
              winhighlight = "Normal:Normal,FloatBorder:LspBorderBG,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
              winhighlight = "Normal:Normal,FloatBorder:LspBorderBG,CursorLine:PmenuSel,Search:None",
          }),
      },
      mapping={
        ["<C-Space>"]=cmp.mapping.complete(),
        -- ['<C-d>']=cmp.mapping(cmp.mapping.scroll_docs(-4), {'i','c'}),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<S-Space>"] = cmp.mapping.complete(),
        ['<C-u>']=cmp.mapping(cmp.mapping.scroll_docs(4), {'i','c'}),
        ['<C-e>']=cmp.mapping({i=cmp.mapping.abort(), c=cmp.mapping.close(), }),
        ['<CR>']=cmp.mapping.confirm({behavior=cmp.ConfirmBehavior.Replace, select=true,}),
        ["<tab>"] = cmp_next,
        ['<S-Tab>']=cmp.prev,
        ["<down>"] = cmp_next,
        ["<C-p>"] = cmp_prev,
        ["<up>"] = cmp_prev,
      },
      view={
          entries='bordered'
      },
      window={documentation=cmp.config.disable,},
      snippet={expand=function(args) require'luasnip'.lsp_expand(args.body) end},
      cmp.setup.filetype('gitcommit', {
        sources=cmp.config.sources({
          {name='cmp_git'},  -- You can specify the `cmp_git` source if you were installed it.
          {name='buffer'},
          {name='cmdline'},
          -- { name = "nvim_lsp_signature_help", group_index = 1 },
          -- { name = "luasnip",                 max_item_count = 5,  group_index = 1 },
          -- { name = "nvim_lsp",                max_item_count = 20, group_index = 1 },
          -- { name = "nvim_lua",                group_index = 1 },
          -- { name = "vim-dadbod-completion",   group_index = 1 },
          -- { name = "path",                    group_index = 2 },
          -- { name = "buffer",                  keyword_length = 2,  max_item_count = 5, group_index = 2 },
        })
      }),
      sources=cmp.config.sources({{name='nvim_lsp'}, {name='nvim_lua'}, {name='luasnip'}, {name='path'},}),
      confirm_opts={
        behavior=cmp.ConfirmBehavior.Replace,
        select=true,
      },
      sorting={
        comparators={
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },
      formatting={
        format=function(_, vim_item)
          vim_item.kind=string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
          return vim_item
        end,
      },
    })
    local presentAutopairs, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
    if not presentAutopairs then
        return
    end
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
    end,
}
