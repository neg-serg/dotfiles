{ config, pkgs, inputs, ... }: {
  nix = {
    package = pkgs.nix;
    # Per-user Nix settings
    settings = {
      # Trust flake-provided nixConfig (substituters, keys, features)
      accept-flake-config = true;
      # Use the sops-managed GitHub netrc for authenticated fetches
      netrc-file = config.sops.secrets."github-netrc".path;
    };
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

  # Auto-push built store paths to Cachix
  services.cachix.watchStore = {
    enable = true;
    cacheName = "neg-serg";
    authTokenFile = "/run/user/1000/secrets/cachix.env";
  };
}
