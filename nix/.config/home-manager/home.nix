{ config, pkgs, inputs, ... }: {
  nix = {
    package = pkgs.nix;
    # Use the sops-managed GitHub netrc for authenticated fetches
    settings.netrc-file = config.sops.secrets."github-netrc".path;
  };
  imports = [
    ./secrets
    ./modules
  ];
  xdg.stateHome = "${config.home.homeDirectory}/.local/state";
  home = {
    homeDirectory = "/home/neg";
    stateVersion = "23.11"; # Please read the comment before changing.
    preferXdgDirectories = true;
    username = "neg";
  };
}
