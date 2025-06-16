return {
  -- ┌───────────────────────────────────────────────────────────────────────────────────┐
  -- │ █▓▒░ nvim-orgmode/orgmode                                                         │
  -- └───────────────────────────────────────────────────────────────────────────────────┘
  {"nvim-orgmode/orgmode",lazy=false,ft="org",config=function()
    require("orgmode").setup({
      org_agenda_files={"~/org/**/*"},
      org_default_notes_file="~/org/notes.org",
    })
  end},
  -- ┌───────────────────────────────────────────────────────────────────────────────────┐
  -- │ █▓▒░ nvim-neorg/neorg                                                             │
  -- └───────────────────────────────────────────────────────────────────────────────────┘
  {"nvim-neorg/neorg",build=":Neorg sync-parsers",lazy=true,ft="norg",
  dependencies={"nvim-lua/plenary.nvim"},config=function()
    require("neorg").setup({
      load={
        ["core.defaults"]={},
        ["core.concealer"]={},
        ["core.dirman"]={config={workspaces={notes="~/norg"}}},
      },
    })
  end},
}
