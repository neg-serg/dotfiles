{
  lib,
  config,
  ...
}: let
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
  mkSymlink = path: recursive: {
    source = l "${dots}/${path}";
    inherit recursive;
  };
in {
  xdg = {
    configFile = {
      # The remaining entries here are those that are not yet managed
      # directly by Home Manager modules. See modules under ./modules for
      # migrated apps (tridactyl, home-manager, dircolors, f-sy-h, zsh, quickshell).
    };
    dataFile."hack-art" = mkSymlink "hack-art/.local/share/hack-art" true;
    dataFile."fantasy-art" = mkSymlink "fantasy-art/.local/share/fantasy-art" true;
  };

  home.file = {
    "bin" = mkSymlink "bin" false;
    ".ugrep" = mkSymlink "shell/.ugrep" true;
    ".zshenv" = mkSymlink "shell/.zshenv" true;
    "${config.xdg.configHome}/nixpkgs/config.nix".text = let
      # Render current allowlist into a Nix list literal in the written config
      allowedList = lib.concatStringsSep " " (map (s: "\"${s}\"") config.features.allowUnfree.allowed);
    in ''
      {
        # Only allow specific unfree packages by name (synced with Home Manager)
        allowUnfreePredicate = pkg: let
          name = (pkg.pname or (builtins.parseDrvName (pkg.name or "")).name);
          allowed = [ ${allowedList} ];
        in builtins.elem name allowed;
      }
    '';
  };
}
