{
  pkgs,
  ...
}: {
  programs.carapace.enable = true; # cross-shell completion
  programs.nix-your-shell = {
    enable = true;
  };
}
