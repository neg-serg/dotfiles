{
  lib,
  config,
  pkgs,
  ...
}: {
  # Consolidate minor activation tasks via shared key in other modules

  home.packages = with pkgs; config.lib.neg.pkgsList [
    amfora # terminal browser for gemini
    antiword # convert ms word to text or ps
    epr # cli epub reader
    glow # markdown viewer
    lowdown # cat for markdown
    recoll # full-text search tool
    sioyek # nice zathura alternative
    tesseract # ocr
    zotero # tool to organize cites
  ];
  programs.zathura = {
    enable = true;
    options = {
      font = "Iosevka 10";
      database = "sqlite";
      statusbar-h-padding = 0;
      statusbar-v-padding = 0;
      page-padding = 1;

      # (Or use colors from stylix)
      default-bg = "#020202";
      default-fg = "#617287";
      statusbar-bg = "#020202";
      statusbar-fg = "#617287";
      inputbar-bg = "#000000";
      inputbar-fg = "#cccccc";
      completion-group-bg = "#101010";
      completion-group-fg = "#eeeeee";
      completion-highlight-fg = "#6A9FB5";
      completion-highlight-bg = "#073642";
      highlight-color = "#073642";
      highlight-active-color = "#47A2B9";
      completion-bg = "#000000";
      completion-fg = "#666666";
      notification-error-bg = "#AC4142";
      notification-error-fg = "#151515";
      notification-warning-bg = "#AC4142";
      notification-warning-fg = "#151515";
      notification-bg = "#191C21";
      notification-fg = "#6A9FB5";
      recolor-lightcolor = "#020202";
      recolor-darkcolor = "#617287";

      statusbar-home-tilde = true;
      window-title-home-tilde = true;
      window-title-basename = true;
      window-title-page = true;
      statusbar-basename = false;
      # Align internal links to the left (e.g. index), thx to Badacadabra
      link-hadjust = true;
      # Optimal adjustment of the document when it is loaded
      adjust-open = "best-fit";
      # Show text loader when a document is loading
      render-loading = true;
      # Enable SyncTex
      synctex = true;

      recolor-keephue = "false";
      zoom-step = 10;

      pages-per-row = "1";

      # TODO: Try this options later
      # scroll-page-aware = "true";
      # scroll-full-overlap = "0.01";
      # scroll-step = "100";
      # smooth-scroll = true;
      # guioptions = "none";
    };
    mappings = {
      ";" = "focus_inputbar \":\"";
      "<C-[>" = "abort";
      "<C-c>" = "abort";
      "<F11>" = "toggle_fullscreen";
      "<C-l>" = "reload";
      "R" = "rotate rotate-ccw";
      "<PageUp>" = "navigate previous";
      "<PageDown>" = "navigate next";
      "<A-1>" = "set \"pages-per-row 1\"";
      "<A-2>" = "set \"pages-per-row 2\"";
      "<C-1>" = "set \"first-page-column 1\"";
      "<C-2>" = "set \"first-page-column 2\"";

      # setting recolor-keep true will keep any color your pdf has.
      # if it is false, it'll just be black and white
      "<A-w>" = "set recolor \"true\"";
      "<C-w>" = "set recolor-keephue \"false\"";
      "<C-e>" = "set recolor-reverse-video \"true\"";
      "[normal] q" = "zoom out";
      "[normal] w" = "zoom in";
      "[normal] e" = "adjust_window best-fit";
      ",," = "nohlsearch";
    };
    extraConfig = ''
      unmap q
      unmap d
      unmap <C-q>
    '';
  };
}
