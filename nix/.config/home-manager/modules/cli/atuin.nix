{...}: {
  programs.atuin = {
    enable = true;
    # I *despise* this hijacking of the up key, even though I use Ctrl-p
    flags = ["--disable-up-arrow"];
    settings = {
      daemon.enabled = false;
      enter_accept = false; # I like being able to edit my commands
      inline_height = 25;
      invert = false;
      keys.scroll_exits = false;
      prefers_reduced_motion = true;
      preview.max_preview_height = 0;
      preview.strategy = "fixed";
      search_mode = "skim"; # Get closer to fzf's fuzzy search
      show_help = false;
      show_preview = false; # Show long command lines at the bottom
      show_tabs = false;
      smart_sort = true;
      update_check = false; # The package is managed by Nix
    };
  };
}
