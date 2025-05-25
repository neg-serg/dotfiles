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
            severity_sort=false,
        })
        local signs={Error="", Warn="", Hint="", Info=""}
        for type, icon in pairs(signs) do
            local hl="DiagnosticSign" .. type
            vim.fn.sign_define(hl, {text=icon, texthl=hl, numhl=hl})
        end
        vim.lsp.config('bashls', {})
        vim.lsp.config('clangd', {})
        vim.lsp.config('nil_ls', {})
        vim.lsp.config('pyright', {})
    end,
}
