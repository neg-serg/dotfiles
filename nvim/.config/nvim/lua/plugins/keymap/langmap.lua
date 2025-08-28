-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ Wansmer/langmapper.nvim                                                      │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'Wansmer/langmapper.nvim',
  lazy = false,
  priority = 1, -- High priority is needed if you will use `autoremap()`
  config = function()
    local function escape(str)
        -- You need to escape these characters to work correctly
        local escape_chars = [[;,."|\]]
        return vim.fn.escape(str, escape_chars)
    end

    -- Recommended to use lua template string
    local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm]]
    local ru = [[ёйцукенгшщзхъфывапролджэячсмить]]
    local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
    local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]

    vim.opt.langmap = vim.fn.join({
        escape(ru_shift) .. ';' .. escape(en_shift),
        escape(ru) .. ';' .. escape(en),
    }, ',')
    require('langmapper').setup({
        disable_hack_modes = {},
        automapping_modes = { 'n', 'v', 'x', 's', 'i' },
    })
  end,
}
