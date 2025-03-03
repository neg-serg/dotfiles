-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ neovim/nvim-lspconfig                                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'neovim/nvim-lspconfig',
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
        lspconfig.bashls.setup{}
        lspconfig.clangd.setup{}
        lspconfig.nil_ls.setup{}
        lspconfig.pyright.setup{}
    end,
}
