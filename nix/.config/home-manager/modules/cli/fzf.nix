{
  lib,
  pkgs,
  ...
}: {
  programs.fzf = {
    enable = true;
    defaultCommand = "${lib.getBin pkgs.fd}/bin/fd --type=f --hidden --exclude=.git";
    defaultOptions = [
      "--bind=alt-p:toggle-preview,alt-a:select-all"
      "--bind 'alt-d:change-prompt(Directories> )+reload(fd . -t d)'"
      "--bind 'alt-f:change-prompt(Files> )+reload(fd . -t f)'"
      "--bind 'ctrl-j:execute(~/bin/v '{+}')+abort'"
      "--bind 'ctrl-space:select-all'"
      "--bind 'ctrl-t:accept'"
      "--bind 'ctrl-v:execute(~/bin/v '{+}')'"
      "--bind 'ctrl-y:execute-silent(echo '{+}' | xclip -i)'"
      "--bind 'tab:execute(handlr open '{+}')+abort'"

      "--ansi"
      "--border=none"
      "--exact" # Substring matching by default, `'`-quote for subsequence matching.
      "--height=6"
      "--info=hidden"
      "--layout=reverse"
      "--min-height=6"
      "--multi"
      "--no-mouse"
      "--prompt='❯> ' --pointer='•' --marker='✓'"
      "--with-nth=1.."
    ];

    # FZF_CTRL_R_OPTS
    historyWidgetOptions = [
      "--sort"
      "--exact"
      "--preview 'echo {}'"
      "--preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    ];

    # FZF_CTRL_T_OPTS
    fileWidgetOptions = [
      "--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
    ];

    colors = {
      "preview-bg" = "-1";
      "gutter" = "-1";
      "bg" = lib.mkForce "#000000";
      "bg+" = lib.mkForce "#000000";
      "fg" = lib.mkForce "#4f5d78";
      "fg+" = lib.mkForce "#8DA6B2";
      "hl" = lib.mkForce "#546c8a";
      "hl+" = lib.mkForce "#005faf";
      "header" = lib.mkForce "#4779B3";
      "info" = lib.mkForce "#3f5876";
      "pointer" = lib.mkForce "#005faf";
      "marker" = lib.mkForce "#04141C";
      "prompt" = lib.mkForce "#005faf";
      "spinner" = lib.mkForce "#3f5876";
      "border" = lib.mkForce "#04141C";
      "preview-fg" = lib.mkForce "#4f5d78";
    };

    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
