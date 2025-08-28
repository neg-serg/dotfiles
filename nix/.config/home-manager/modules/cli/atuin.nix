{...}: {
  programs.atuin = {
    enable = true;
    # I *despise* this hijacking of the up key, even though I use Ctrl-p
    flags = ["--disable-up-arrow"];
    settings = {
      enter_accept = false; # I like being able to edit my commands
      inline_height = 15;
      invert = true;
      keys.scroll_exits = false;
      prefers_reduced_motion = true;
      search_mode = "skim"; # Get closer to fzf's fuzzy search
      show_help = false;
      show_preview = true; # Show long command lines at the bottom
      show_tabs = false;
      style = "compact"; # I don't care for the fancy display
      update_check = false; # The package is managed by Nix
    };
  };
}
