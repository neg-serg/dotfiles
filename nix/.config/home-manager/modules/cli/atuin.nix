{...}: {
  programs.atuin = {
    enable = true;
    # Disable intrusive key hijacking (I prefer Ctrl-p)
    flags = [ "--disable-up-arrow" ];
    settings = {
      daemon = {
        enabled = false;
      };
      enter_accept = false; # Keep editing after selection
      inline_height = 25;
      invert = false;
      keys = {
        scroll_exits = false;
      };
      prefers_reduced_motion = true;
      preview = {
        max_preview_height = 0;
        strategy = "fixed";
      };

      search_mode = "skim";   # Closer to fzf-style fuzzy search
      smart_sort = true;

      show_help = false;
      show_preview = false;    # Prevent long lines at the bottom
      show_tabs = false;

      update_check = false;    # Managed by Nix
    };
  };
}
