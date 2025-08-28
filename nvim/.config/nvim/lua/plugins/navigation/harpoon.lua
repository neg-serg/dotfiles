-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ ThePrimeagen/harpoon                                                         │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  main = "harpoon",
  opts = {},
  keys = {
    { "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
    { "<C-e>", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
    { "<C-h>", function() require("harpoon"):list():select(1) end, desc = "Harpoon 1" },
    { "<C-t>", function() require("harpoon"):list():select(2) end, desc = "Harpoon 2" },
    { "<C-n>", function() require("harpoon"):list():select(3) end, desc = "Harpoon 3" },
    { "<C-s>", function() require("harpoon"):list():select(4) end, desc = "Harpoon 4" },
    { "<C-S-P>", function() require("harpoon"):list():prev() end, desc = "Harpoon prev" },
    { "<C-S-N>", function() require("harpoon"):list():next() end, desc = "Harpoon next" },
  },
  event = "VeryLazy",
}
