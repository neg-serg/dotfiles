{config, pkgs, ...}: {
  nix = {
    enable = true;
    package = pkgs.nix;
    settings = {
      use-xdg-base-directories = true;
      build-users-group = "nixbld";
      max-jobs = "auto";
      extra-nix-path = "nixpkgs=flake:nixpkgs";
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
}
