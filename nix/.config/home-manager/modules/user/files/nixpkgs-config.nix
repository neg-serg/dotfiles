{
  lib,
  config,
  ...
}: {
  home.file."${config.xdg.configHome}/nixpkgs/config.nix".text = let
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
}
