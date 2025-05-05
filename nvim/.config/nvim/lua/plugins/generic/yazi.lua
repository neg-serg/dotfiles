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
  },
  opts = {
    open_for_directories = true, -- if you want to open yazi instead of netrw, see below for more info
    keymaps = {
        show_help = "<f1>",
        open_file_in_vertical_split = "<c-v>",
        open_file_in_horizontal_split = "<c-x>",
        open_file_in_tab = "<c-t>",
        grep_in_directory = "<c-f>",
        replace_in_directory = "<c-g>",
        cycle_open_buffers = "<NOP>",
        copy_relative_path_to_selected_files = "<c-y>",
        send_to_quickfix_list = "<c-q>",
        change_working_directory = "<tab>",
    },
    yazi_floating_window_border = "double",
  },
  init = function()
    require'yazi'.setup()
    vim.g.loaded_netrwPlugin = 1
  end,
}
