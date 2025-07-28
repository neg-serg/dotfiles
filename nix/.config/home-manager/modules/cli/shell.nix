{
  pkgs,
  ...
}: {
  programs.carapace.enable = true; # cross-shell completion
  programs.oh-my-posh.enable = true;
  programs.oh-my-posh.useTheme = "atomic";
  programs.nix-your-shell = {
    enable = true;
  };
}
