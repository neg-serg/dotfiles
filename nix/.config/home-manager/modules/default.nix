{
  lib,
  config,
  ...
}:
with lib; {
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
