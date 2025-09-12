{
  lib,
  config,
  ...
}: let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
  # Render current allowlist into a Nix list literal in the written config
  allowedList = lib.concatStringsSep " " (map (s: "\"${s}\"") config.features.allowUnfree.allowed);
in
  xdg.mkXdgText "nixpkgs/config.nix" ''
    {
      # Only allow specific unfree packages by name (synced with Home Manager)
      allowUnfreePredicate = pkg: let
        name = (pkg.pname or (builtins.parseDrvName (pkg.name or "")).name);
        allowed = [ ${allowedList} ];
      in builtins.elem name allowed;
    }
  ''
