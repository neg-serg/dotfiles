{
  lib,
  pkgs,
  ...
}: {
  programs.fzf = {
    enable = true;
    defaultCommand = "${lib.getBin pkgs.fd}/bin/fd --type=f --hidden --exclude=.git";
    defaultOptions = builtins.filter (x: builtins.typeOf x == "string") [
      # Key bindings & quick actions
      "--bind='alt-p:toggle-preview,alt-a:select-all,alt-s:toggle-sort'"
      "--bind='alt-d:change-prompt(Directories ❯ )+reload(fd . -t d)'"
      "--bind='alt-f:change-prompt(Files ❯ )+reload(fd . -t f)'"
      "--bind='ctrl-j:execute(~/bin/v {+})+abort'"
      "--bind='ctrl-space:select-all'"
      "--bind='ctrl-t:accept'"
      "--bind='ctrl-v:execute(~/bin/v {+})'"
      "--bind='ctrl-y:execute-silent(echo {+} | wl-copy)'"
      "--bind='tab:execute(handlr open {+})+abort'"

      # UI/UX polish
      "--ansi"
      # Keep prompt on top
      "--layout=reverse"
      "--cycle"
      "--border=sharp"
      "--margin=0"
      "--padding=0"
      "--footer='[Alt-f] Files  [Alt-d] Dirs  [Alt-p] Preview  [Alt-s] Sort  [Tab] Open'"
      # Header color: use terminal's white (kitty theme)
      "--color=header:white"
      # Make footer color match header; underline requires separate spec in fzf 0.65+
      "--color=footer:underline"
      "--color=footer:white"

      # Search behavior: exact by default; quote for subsequence
      "--exact"

      # Sizing: compact by default but more breathable
      "--height=16"
      "--min-height=14"
      # Show match info on the bottom status line
      "--info=default"
      "--multi"
      "--no-mouse"

      # Prompt & symbols (Nerd Font friendly)
      "--prompt=❯  "
      "--pointer=▶"
      "--marker=✓"
      "--with-nth=1.."

      # Note: Preview config moved to widget-specific opts (history/file)
      # to avoid heavy quoting in FZF_DEFAULT_OPTS.
    ];

    # FZF_CTRL_R_OPTS
    historyWidgetOptions = [
      "--sort"
      "--exact"
      "--border=sharp --margin=0 --padding=0"
      "--footer='[Enter] Paste  [Ctrl-y] Yank  [?] Preview'"
      "--preview 'echo {}'"
      "--preview-window down:5:hidden,wrap --bind '?:toggle-preview'"
    ];

    # FZF_CTRL_T_OPTS
    fileWidgetOptions = [
      "--border=sharp --margin=0 --padding=0 --preview 'if [ -d \"{}\" ]; then (eza --tree --icons=auto -L 2 --color=always \"{}\" 2>/dev/null || tree -C -L 2 \"{}\" 2>/dev/null); else (bat --style=plain --color=always --line-range :200 \"{}\" 2>/dev/null || highlight -O ansi -l \"{}\" 2>/dev/null || head -200 \"{}\" 2>/dev/null || file -b \"{}\" 2>/dev/null); fi' --preview-window=right,60%,border-left,wrap"
    ];

    # Restore previous custom theme colors
    colors = {
      "preview-bg" = "-1";
      "gutter" = "-1";
      "bg" = lib.mkForce "#000000";
      "bg+" = lib.mkForce "#000000";
      "fg" = lib.mkForce "#4f5d78";
      "fg+" = lib.mkForce "#8DA6B2";
      "hl" = lib.mkForce "#546c8a";
      "hl+" = lib.mkForce "#005faf";
      # Slightly lighter bluish border & separator (keeps hue)
      "border" = lib.mkForce "#0b2536";
      "list-border" = lib.mkForce "#0b2536";
      "input-border" = lib.mkForce "#0b2536";
      "preview-border" = lib.mkForce "#0b2536";
      "header-border" = lib.mkForce "#0b2536";
      "footer-border" = lib.mkForce "#0b2536";
      "separator" = lib.mkForce "#0b2536";
      # header color set via defaultOptions to include underline
      "info" = lib.mkForce "#3f5876";
      "pointer" = lib.mkForce "#005faf";
      "marker" = lib.mkForce "#04141C";
      "prompt" = lib.mkForce "#005faf";
      "spinner" = lib.mkForce "#3f5876";
      "preview-fg" = lib.mkForce "#4f5d78";
    };

    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
