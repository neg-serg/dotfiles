-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ neovim/nvim-lspconfig                                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'neovim/nvim-lspconfig',
    dependencies = {
        "SmiteshP/nvim-navbuddy",
        dependencies = { "SmiteshP/nvim-navic", "MunifTanjim/nui.nvim"},
        opts = { lsp = { auto_attach = true } }
    },
    config = function()
        local lspconfig = require('lspconfig')
        vim.diagnostic.config({
            virtual_text=true,
            signs=true,
            underline=true,
            update_in_insert=false,
            severity_sort=true,
            float={border='rounded', source='if_many'},
        })
        local handlers = {
          ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
          ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
        }
        -- Inlay hints (Neovim 0.10+)
        if vim.lsp.inlay_hint and pcall(vim.lsp.inlay_hint, bufnr, true) then
          map('n', '<leader>uh', function()
            local enabled = vim.lsp.inlay_hint.is_enabled(bufnr)
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
          end, 'Inlay Hints: toggle')
        end
        local function setup(server, extra)
          lspconfig[server].setup(vim.tbl_deep_extend('force', {
            on_attach = on_attach,
            capabilities = capabilities,
            handlers = handlers,
          }, extra or {}))
        end
        local signs={Error="", Warn="", Hint="", Info=""}
        for type, icon in pairs(signs) do
            local hl="DiagnosticSign" .. type
            vim.fn.sign_define(hl, {text=icon, texthl=hl, numhl=hl})
        end
        setup('bashls')
        setup('clangd', {
            cmd = { 'clangd', '--background-index', '--clang-tidy', '--completion-style=detailed', '--header-insertion=never' },
            init_options = { clangdFileStatus = true },
        })
        setup('nil_ls')      -- Nix
        setup('pyright', {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = 'basic',
                autoImportCompletions = true,
              },
            },
        }})
    end
}
