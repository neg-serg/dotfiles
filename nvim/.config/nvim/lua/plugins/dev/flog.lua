-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ rbong/vim-flog                                                               │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
	"rbong/vim-flog",
	event = "VeryLazy",
	dependencies = {
      "tpope/vim-fugitive",
	},
	cmd = { "Flog", "G", "GBrowse", "GDelete", "GMove", "GRemove",
      "GRename", "GUnlink", "Gcd", "Gclog", "Gdiffsplit", "Gdrop",
      "Gedit", "Ggrep", "Ghdiffsplit", "Git", "Glcd", "Glgrep", "Gllog",
      "Gpedit", "Gread", "Gsplit", "Gtabedit", "Gvdiffsplit", "Gvsplit",
      "Gwq", "Gwrite",
	},
}
