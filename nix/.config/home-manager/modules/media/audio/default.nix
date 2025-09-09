{lib, ...}:
with lib; {
  imports = [
    ./apps.nix
    ./beets.nix
    ./ncpamixer.nix
    ./core.nix
    ./creation.nix
    ./mpd
  ];
}
