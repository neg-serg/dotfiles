{ lib, config, ... }:
with lib;
let
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = config.lib.neg.dotfilesRoot;
in
  mkIf config.features.fun.enable {
    # Curated art collections under XDG data; live-edit via out-of-store symlinks
    xdg = {
      dataFile = {
        "hack-art" = {
          source = l "${dots}/hack-art/.local/share/hack-art";
          recursive = true;
        };
        "fantasy-art" = {
          source = l "${dots}/fantasy-art/.local/share/fantasy-art";
          recursive = true;
        };
      };
    };
  }
