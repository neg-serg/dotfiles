-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ akinsho/git-conflict.nvim                                                    │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'akinsho/git-conflict.nvim',
  opts = {
    default_commands = true,
    disable_diagnostics = true,
    list_opener = 'botright copen',
    default_mappings = { next = ']C', prev = '[C', },
  },
  event = 'VeryLazy',
}
