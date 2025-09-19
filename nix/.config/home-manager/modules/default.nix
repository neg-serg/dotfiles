{lib, pkgs, ...}:
with lib; {
  # Provide xdg helpers once; modules can use `xdg` from args
  _module.args.xdg = import ./lib/xdg-helpers.nix { inherit lib pkgs; };

  imports = [
    ./lib/neg.nix
    ./features.nix
    ./cli
    ./db
    ./dev
    ./distros
    ./flatpak
    ./hardware
    ./main
    ./media
    ./misc
    ./secrets
    ./text
    ./user
  ];
}
