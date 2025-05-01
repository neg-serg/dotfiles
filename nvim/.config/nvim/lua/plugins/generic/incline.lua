-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ b0o/incline.nvim                                                             │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'b0o/incline.nvim',
  config = function()
    require('incline').setup()
  end,
  event = 'VeryLazy', -- Optional: Lazy load Incline
}
