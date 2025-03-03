-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ kosayoda/nvim-lightbulb                                                      │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'kosayoda/nvim-lightbulb', -- shows you where code actions can be applied
  config=function()
    require("nvim-lightbulb").setup({
      autocmd = { enabled = true }
    })
  end
} 
