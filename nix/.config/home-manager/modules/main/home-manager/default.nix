{ lib, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  # Point ~/.config/home-manager to the repo root for convenience (hm switch --flake ~/.config/home-manager)
  repoRoot = "${config.lib.neg.dotfilesRoot}/nix/.config/home-manager";
in {
  programs = {
    home-manager.enable = true; # Let Home Manager install and manage itself.
  };

  # Remove stale ~/.config/home-manager symlink from older generations before linking
  home.activation.fixHomeManagerConfigDir =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      HMDIR="${config.xdg.configHome}/home-manager"
      if [ -L "$HMDIR" ]; then
        rm -f "$HMDIR"
      fi
    '';

  # Make the repo available at ~/.config/home-manager for convenience
  xdg.configFile."home-manager" = {
    source = l repoRoot;
    recursive = true;
  };
}
