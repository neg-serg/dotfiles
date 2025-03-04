-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ folke/lazydev.nvim                                                           │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {{"folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {library = {},},
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },
}
