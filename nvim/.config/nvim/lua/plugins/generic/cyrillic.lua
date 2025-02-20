-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ nativerv/cyrillic.nvim                                                       │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
	"nativerv/cyrillic.nvim",
	event = { "VeryLazy" },
	config = function()
		require("cyrillic").setup({
			no_cyrillic_abbrev = false, -- default
		})
	end,
}
