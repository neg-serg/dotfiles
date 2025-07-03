{
  pkgs,
  ...
}: {
  programs.carapace.enable = true; # cross-shell completion
  programs.nix-your-shell = {
    enable = true;
  };
  home.packages = with pkgs; [
    dash # faster sh
    nushell # alternative shell
    oils-for-unix # better bash
  ];
}
