-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ Chaitanyabsprip/fastaction.nvim                                              │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'Chaitanyabsprip/fastaction.nvim',
  opts = {},
  config=function()
      vim.keymap.set({'n', 'x'}, 'eq', '<cmd>lua require("fastaction").code_action()<CR>', { buffer = bufnr })
  end
}
