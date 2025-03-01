-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ hrsh7th/nvim-cmp                                                             │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'hrsh7th/nvim-cmp', -- completion engine
  config=function()
    local ok, cmp=pcall(require, 'cmp')
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
      Snippet="",
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
    cmp.setup({
      mapping={
        ["<C-Space>"]=cmp.mapping.complete(),
        ['<C-d>']=cmp.mapping(cmp.mapping.scroll_docs(-4), {'i','c'}),
        ['<C-u>']=cmp.mapping(cmp.mapping.scroll_docs(4), {'i','c'}),
        ['<C-e>']=cmp.mapping({i=cmp.mapping.abort(), c=cmp.mapping.close(), }),
        -- disabled for autopairs mapping
        ['<CR>']=cmp.mapping.confirm({
          behavior=cmp.ConfirmBehavior.Replace,
          select=false,
        }),
        ['<Tab>']=cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
          elseif has_words_before() then cmp.complete()
          else fallback()
          end
        end, { 'i', 's', }),
        ['<S-Tab>']=cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then luasnip.jump(-1)
          else fallback()
          end
        end, {'i','s',}),
      },
      view={entries='native'},
      window={documentation=cmp.config.disable,},
      snippet={expand=function(args) require'luasnip'.lsp_expand(args.body) end},
      cmp.setup.filetype('gitcommit', {
        sources=cmp.config.sources({
          {name='cmp_git'},  -- You can specify the `cmp_git` source if you were installed it.
          {name='buffer'},
          {name='cmdline'},
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
    end,
    dependencies={
        'hrsh7th/cmp-nvim-lsp', -- cmp lsp support
        'hrsh7th/cmp-nvim-lua', -- cmp neovim lua api support
        'hrsh7th/cmp-path', -- cmp path completion support
    }}
