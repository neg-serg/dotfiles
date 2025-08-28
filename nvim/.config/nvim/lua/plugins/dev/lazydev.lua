-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ folke/lazydev.nvim                                                           │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      -- Extra type libraries to inject into lua-ls
      library = {
        -- luv/uv types for vim.uv / vim.loop
        { path = "${3rd}/luv/library", words = { "vim%.uv", "vim%.loop" } },
        -- Optional examples (uncomment if you need them):
        { path = "${3rd}/busted/library", words = { "describe", "it", "before_each", "after_each" } },
        { path = "${3rd}/luassert/library", words = { "assert" } },
        { path = "${3rd}/luafun/library", words = { "fun%." } },
      },

      -- Enable faster indexing
      fast = true,

      -- Treat identifiers starting with "_" as private
      private = { "^_" },
    },
  },

  -- lua-language-server setup to work with lazydev
  {"neovim/nvim-lspconfig",
    ft = "lua",
    opts = {
      servers = {
        lua_ls = {
          on_init = function(client)
            -- Disable third-party checks prompts
            client.config.settings.Lua.workspace.checkThirdParty = false
          end,
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = {
                globals = { "vim" },
                disable = { "incomplete-signature-doc", "lowercase-global" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                maxPreload = 2000,
                preloadFileSize = 1000,
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
                keywordSnippet = "Replace",
              },
              hint = { enable = true },
              telemetry = { enable = false },
              doc = { privateName = { "^_" } },
            },
          },
        },
      },
    },
  },
}
