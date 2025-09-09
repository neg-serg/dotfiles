{lib, ...}:
with lib; {
  imports = [
    ./aria.nix
    ./browsing.nix
    ./misc.nix
    ./yt-dlp # download from youtube and another sources
  ];
}
