{ pkgs, lib, config, xdg, ... }:
lib.mkMerge [
  {
    home.packages = config.lib.neg.pkgsList [
      pkgs.fastfetch # modern, fast system fetch
      pkgs.onefetch # repository summary in terminal
    ];
  }
  # Link static configuration directory (config.jsonc + skull) from repo
  (xdg.mkXdgSource "fastfetch" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/cli/fastfetch/conf";
    recursive = true;
  })
]
