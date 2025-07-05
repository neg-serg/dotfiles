-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ MeanderingProgrammer/render-markdown.nvim                                    │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'MeanderingProgrammer/render-markdown.nvim',
  -- enabled=false,
  name='render-markdown',
  dependencies={'nvim-treesitter/nvim-treesitter'}, -- if you use the mini.nvim suite
  ft={'markdown', 'quarto', 'md'}, opts={},
  opts = {
      theme = "dark",
      headings = {
          ["h1"] = { fg = "#FFD700", bold = true },
          ["h2"] = { fg = "#FFA500", bold = true },
          ["h3"] = { fg = "#FF8C00", bold = true },
      },
      bullets = { "•", "◦", "▪" },    -- свои маркеры
      code = { background = "#1e1e2e", border = "rounded", },
  },
  config = function(_, opts)
      require("render-markdown").setup(opts)
  end,
}
