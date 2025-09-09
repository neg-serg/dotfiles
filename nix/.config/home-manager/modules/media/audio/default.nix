{lib, ...}:
with lib; {
  imports = [
    ./apps.nix
    ./beets.nix
    ./core.nix
    ./creation.nix
    ./mpd
  ];
}
