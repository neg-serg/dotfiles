-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ epwalsh/obsidian.nvim                                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'epwalsh/obsidian.nvim', -- obsidian helpers for neovim
    tag='v3.9.0',
    lazy=true,
    ft='markdown',
    dependencies={
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim'},
    config=function()
        require'obsidian'.setup({
              workspaces = {{name = "personal", path = "~/1st_level/",},},
              new_notes_location="current_dir",
              completion={nvim_cmp=false,}, -- If using nvim-cmp, otherwise set to false
              mappings={
                  ["gf"]={ -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
                      action=function()
                          return require'obsidian'.util.gf_passthrough()
                      end,
                      opts={ noremap=false, expr=true, buffer=true },
                  },
              },
              note_id_func=function(title)
                  local suffix=""
                  if title ~= nil then
                      suffix=title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                  else
                      for _=1, 4 do
                          suffix=suffix .. string.char(math.random(65, 90))
                      end
                  end
                  return tostring(os.time()) .. "-" .. suffix
              end,
              disable_frontmatter=true,
              note_frontmatter_func=function(note)
                  local out={ id=note.id, aliases=note.aliases, tags=note.tags }
                  if note.metadata ~= nil and require("obsidian").util.table_length(note.metadata) > 0 then
                      for k, v in pairs(note.metadata) do
                          out[k]=v
                      end
                  end
                  return out
              end,
              follow_url_func=function(url)
                  vim.fn.jobstart({"xdg-open", url})  -- linux
              end,
              use_advanced_uri=true, -- https://github.com/Vinzent03/obsidian-advanced-uri
              open_app_foreground=false,
              finder="telescope.nvim",
              sort_by="modified",
              sort_reversed=true,
              open_notes_in="current"
        })
    end}
