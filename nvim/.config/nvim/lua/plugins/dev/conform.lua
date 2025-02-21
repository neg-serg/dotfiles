-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ stevearc/conform.nvim                                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
	"stevearc/conform.nvim", -- neovim modern formatter
	-- event='BufWritePre',
	cmd = { "ConformInfo" },
	config = function()
		local conform = require("conform")
		local prettier = { "prettierd", "prettier", stop_after_first = true }
		require("conform").setup({
			-- Set this to change the default values when calling conform.format()
			-- This will also affect the default values for format_on_save/format_after_save
			default_format_opts = { lsp_format = "fallback" },
			notify_on_error = true, -- Conform will notify you when a formatter errors
			notify_no_formatters = true, -- Conform will notify you when no formatters are available for the buffer
			format_on_save = { lsp_format = "fallback", timeout_ms = 500 }, -- I recommend these options. See :help conform.format for details.
			formatters_by_ft = {
				c = { "clang-format" },
				cmake = { "cmake-format" },
				cpp = { "clang-format" },
				css = prettier,
				go = { "goimports", "gofmt" }, -- Conform will run multiple formatters sequentially
				html = prettier,
				javascript = { "prettierd", "prettier" }, -- Use a sub-list to run only the first available formatter
				json = prettier,
				lua = { "stylua" },
				python = { "isort", "black" }, -- Conform will run multiple formatters sequentially
				rust = { "rustfmt", lsp_format = "fallback" }, -- You can also customize some of the format options for the filetype
				sh = { "shfmt" },
				["_"] = { "trim_whitespace" }, -- Use the "_" filetype to run formatters on filetypes that don't have other formatters configured.
			},
			formatters = {
				astyle = { command = "astyle", prepend_args = { "-s2", "-c", "-J", "-n", "-q", "-z2", "-xC80" } },
				["clang-format"] = { command = "clang-format", prepend_args = { "--style=file", "-i" } },
				["cmake-format"] = { command = "cmake-format", prepend_args = { "-i" } },
				prettier = { command = "prettier", prepend_args = { "-w" } },
				prettierd = { command = "prettierd", prepend_args = { "-w" } },
				shfmt = { command = "shfmt", prepend_args = { "-i", "0", "-sr", "-kp" } },
			},
		})
	end,
	keys = { {
		"<leader>rf",
		function()
			require("conform").format({ async = true })
		end,
		desc = "format buffer",
	} },
}
