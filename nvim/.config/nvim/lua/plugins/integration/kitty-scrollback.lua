-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ mikesmithgh/kitty-scrollback.nvim                                            │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'mikesmithgh/kitty-scrollback.nvim', -- kitty modern neovim scrollback support
    enabled=true, lazy=true,
    cmd={'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth', 'KittyScrollbackGenerateCommandLineEditing'},
    event={'User KittyScrollbackLaunch'},
    config=function()
        require'kitty-scrollback'.setup({
          status_window = { show_timer = true, },
          kitty_get_text = {
            ansi = true, -- boolean If true, the text will include the ANSI formatting escape codes for colors, bold, italic, etc.
            -- string What text to get. The default of screen means all text currently on the screen. all means all the screen+scrollback
            -- and selection means the currently selected text. first_cmd_output_on_screen means the output of the first command that was run in the window
            -- on screen. last_cmd_output means the output of the last command that was run in the window. last_visited_cmd_output means the first command
            -- output below the last scrolled position via scroll_to_prompt. last_non_empty_output is the output from the last command run in the window
            -- that had some non empty output. The last four require shell_integration to be enabled. Choices: screen, all, first_cmd_output_on_screen,
            -- last_cmd_output, last_non_empty_output, last_visited_cmd_output, selection
            extent = 'screen',
            clear_selection = true, -- boolean If true, clear the selection in the matched window, if any.
          },
      })
    end
}
