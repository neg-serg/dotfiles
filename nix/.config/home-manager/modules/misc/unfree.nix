{
  lib,
  config,
  ...
}:
with lib; let
  presets = import ./unfree-presets.nix;
  cfg = config.features.allowUnfree or {};
in {
  options.features.allowUnfree = {
    preset = mkOption {
      type = types.enum (builtins.attrNames presets);
      default = "desktop";
      description = "Preset allowlist for unfree packages.";
    };
    extra = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra unfree package names to allow (in addition to preset).";
    };
    allowed = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Final allowlist of unfree package names (overrides preset if explicitly set).";
    };
  };

  config = {
    # If user didn't explicitly set .allowed, derive from preset + extra
    features.allowUnfree.allowed = mkDefault (presets.${cfg.preset or "desktop"} ++ (cfg.extra or []));

    nixpkgs.config.allowUnfreePredicate = pkg: let
      name = pkg.pname or (builtins.parseDrvName (pkg.name or "")).name;
    in
      builtins.elem name config.features.allowUnfree.allowed;
  };
}
