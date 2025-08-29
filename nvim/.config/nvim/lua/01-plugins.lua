local ok, nixCats = pcall(require, "nixCats")
local lazy
if ok and nixCats.lazy then
    lazy = nixCats.lazy
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
else
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath,
        })
    end
    vim.opt.rtp:prepend(lazypath)
    lazy = require("lazy")
    lazy.setup({
        spec = { { import = "plugins" } },
        defaults = { lazy = false },
        install = { colorscheme = { "neg" } },
        ui = { icons = { ft = "", lazy = "󰂠 ", loaded = "", not_loaded = "" } },
        performance = {
            cache = { enabled = true },
            reset_packpath = true,
            rtp = { disabled_plugins = { "gzip", "matchparen", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
        },
    })
end
