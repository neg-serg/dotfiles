{lib, ...}:
with lib; {
  imports = [
    ./apps.nix
    ./beets.nix
    ./ncpamixer.nix
    ./rmpc.nix
    ./core.nix
    ./creation.nix
    ./mpd
  ];
}
