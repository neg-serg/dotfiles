-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ mikavilpas/yazi.nvim                                                         │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {"mikavilpas/yazi.nvim",
  event = "VeryLazy",
  dependencies = {
    "folke/snacks.nvim" -- check the installation instructions at https://github.com/folke/snacks.nvim
  },
  keys = {
    { "<leader>-", mode = { "n", "v" }, "<cmd>Yazi<cr>", desc = "Open yazi at the current file", },
    { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Open the file manager in nvim's working directory", }, -- Open in the current working directory
    { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Resume the last yazi session",
    },
  },
  opts = {
    open_for_directories = true, -- if you want to open yazi instead of netrw, see below for more info
    keymaps = { show_help = "<f1>", },
  },
  init = function()
    require'yazi'.setup()
    vim.g.loaded_netrwPlugin = 1
  end,
}
