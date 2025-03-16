{pkgs, ...}: {
  nix = {
    package = pkgs.nix;
    settings = {
      use-xdg-base-directories = true;
      build-users-group = "nixbld";
      bash-prompt-prefix = "(nix:$name) ";
      max-jobs = "auto";
      extra-nix-path = "nixpkgs=flake:nixpkgs";
    };
  };
  imports = [
    ./secrets
    ./modules
  ];
  home = {
    homeDirectory = "/home/neg";
    stateVersion = "23.11"; # Please read the comment before changing.
    username = "neg";
  };
}
