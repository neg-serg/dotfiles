-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ MeanderingProgrammer/render-markdown.nvim                                    │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown', 'quarto', 'Avante', 'mdx' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    { 'echasnovski/mini.nvim', optional = true },
  },
  opts = {
    -- optional: explicitly list filetypes (not required if you use `ft=` above)
    file_types = { 'markdown', 'quarto', 'Avante', 'mdx' },
    completions = { blink = { enabled = true } },
    render_modes = true,
    heading = { icons = { '󰼏  ','󰼐  ','󰼑  ','󰼒  ','󰼓  ','󰼔  ' }, position = 'overlay' },
    link = { wiki = { icon = '󰌹 ' } },
    win_options = {
      conceallevel = { default = vim.o.conceallevel, rendered = 3 },
      concealcursor = { default = vim.o.concealcursor, rendered = '' },
    },
    indent = { enabled = true, character = ' ' },
    checkbox = {
      enabled = true, render_modes = true, bullet = false, right_pad = 1,
      unchecked = { icon = '✘ ', highlight = 'MoreMsg' },
      checked   = { icon = '✔ ', highlight = 'RenderMarkdownChecked' },
    },
  },
  keys = {
    { '<localleader>M', '<cmd>RenderMarkdown buf_toggle<CR>', desc = 'Markdown: Toggle (buffer)' },
    {
      '<localleader>C',
      function()
        local ok_state, state = pcall(require, 'render-markdown.state'); if not ok_state then return end
        local ok_mod, mod = pcall(require, 'render-markdown'); if not ok_mod then return end
        local cfg = state.config
        local new = vim.tbl_deep_extend('force', cfg,
          cfg.anti_conceal and cfg.anti_conceal.enabled and {
            anti_conceal = { enabled = false },
            win_options = { concealcursor = { rendered = 'n' } },
          } or {
            anti_conceal = { enabled = true },
            win_options = { concealcursor = { rendered = '' } },
          })
        pcall(mod.setup, new)
      end,
      desc = 'Markdown: Toggle concealcursor/anti_conceal',
    },
  },
}
