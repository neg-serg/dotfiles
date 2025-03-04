-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ ggandor/leap.nvim                                                            │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'ggandor/leap.nvim',
  config=function()
      require'leap'.opts = {
          max_phase_one_targets = nil,
          highlight_unlabeled_phase_one_targets = false,
          max_highlighted_traversal_targets = 10,
          case_sensitive = false,
          equivalence_classes = { ' \t\r\n', },
          substitute_chars = {},
          safe_labels = {
              "s", "f", "n", "u", "t", "/",
              "S", "F", "N", "L", "H", "M", "U", "G", "T", "?", "Z"
          },
          labels = {
              "s", "f", "n",
              "j", "k", "l", "h", "o", "d", "w", "e", "m", "b",
              "u", "y", "v", "r", "g", "t", "c", "x", "/", "z",
              "S", "F", "N",
              "J", "K", "L", "H", "O", "D", "W", "E", "M", "B",
              "U", "Y", "V", "R", "G", "T", "C", "X", "?", "Z"
          },
          special_keys = {
              repeat_search = '<enter>',
              next_phase_one_target = '<enter>',
              next_target = {'<enter>', ';'},
              prev_target = {'<tab>', ','},
              next_group = '<space>',
              prev_group = '<tab>',
              multi_accept = '<enter>',
              multi_revert = '<backspace>',
          },
      }
      vim.keymap.set('n', 's', '<Plug>(leap-anywhere)')
      vim.keymap.set('x', 's', '<Plug>(leap)')
      vim.keymap.set('o', 's', '<Plug>(leap-forward)')
      vim.keymap.set('o', 'S', '<Plug>(leap-backward)')
      -- If using the default mappings (`gs` for multi-window mode), you can
      -- map e.g. `gS` here.
      vim.keymap.set({'n', 'x', 'o'}, 'gs', function ()
          require('leap.remote').action()
      end)
  end
}
