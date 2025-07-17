-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ MeanderingProgrammer/render-markdown.nvim                                    │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'MeanderingProgrammer/render-markdown.nvim',
  dependencies={'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim'}, -- if you use the mini.nvim suite
  -- ft={'markdown', 'quarto'},
  config=function()
    require'render-markdown'.setup{
      completions={blink={enabled=true}},
      render_modes=true,
      heading={
        icons={'󰼏  ', '󰼐  ', '󰼑  ', '󰼒  ', '󰼓  ', '󰼔  ', },
        position='overlay',
      },
      link={wiki={icon='󰌹 '},},
      win_options={
        conceallevel={default=vim.o.conceallevel, rendered=3},
        concealcursor={default=vim.o.concealcursor, rendered=''},
      },
      indent = {
        enabled = true,
        character = " "  -- можно указать символ отступа (пробел или что угодно)
      },
      checkbox={
        enabled=true,
        render_modes=true, -- Additional modes to render checkboxes.
        bullet=false, -- Render the bullet point before the checkbox.
        right_pad=1, -- Padding to add to the right of checkboxes.
        unchecked={
          icon='✘ ', -- Replaces '[ ]' of 'task_list_marker_unchecked'.
          highlight='MoreMsg', -- Highlight for the unchecked icon.
        },
        checked={
          icon='✔ ', -- Replaces '[x]' of 'task_list_marker_checked'.
          highlight='RenderMarkdownChecked', -- Highlight for the checked icon.
        }
    }
  }
  end
}

-- local maputil = require 'user.util.map'
-- local ft = maputil.ft
--
-- ft({ 'markdown', 'Avante', 'mdx' }, function(bufmap)
--   vim.o.wrap = false
--
--   bufmap('n', '<localleader>C', function()
--     ---@diagnostic disable-next-line: invisible
--     local config = require('render-markdown.state').config
--     pcall(
--       require('render-markdown').setup,
--       vim.tbl_deep_extend('force', config, config.anti_conceal.enabled and {
--         anti_conceal = { enabled = false },
--         win_options = {
--           concealcursor = { rendered = 'n' },
--         },
--       } or {
--         anti_conceal = { enabled = true },
--         win_options = {
--           concealcursor = { rendered = '' },
--         },
--       })
--     )
--   end, 'Markdown: Toggle concealcursor')
--
--   bufmap('n', '<localleader>M', '<cmd>RenderMarkdown toggle<Cr>', 'Markdown: Toggle')
-- end)
--
