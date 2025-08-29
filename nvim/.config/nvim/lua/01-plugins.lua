local lazy = require("nixCats").lazy

lazy.setup({
    defaults = { lazy = false },
    install = { colorscheme = { "neg" } },
    ui = { icons = { ft = "", lazy = "󰂠 ", loaded = "", not_loaded = "" } },
    performance = {
        cache = { enabled = true },
        reset_packpath = true,
        rtp = { disabled_plugins = { "gzip", "matchparen", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
    },
})
