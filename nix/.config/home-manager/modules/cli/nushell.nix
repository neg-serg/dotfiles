{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  {
    # Ensure Nushell is available
    home.packages = config.lib.neg.pkgsList [pkgs.nushell];
  }
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "nushell" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/cli/nushell-conf" true))
  # Provide Nushell module search path via NU_LIB_DIRS, pointing to the nupm modules in the store
  # and the user's local modules directory for overrides.
  {
    home.sessionVariables.NU_LIB_DIRS = lib.concatStringsSep ":" [
      # flake-provided Nushell modules (includes nupm)
      "${inputs.nupm}/modules"
      # user-local modules remain discoverable
      "${config.xdg.configHome}/nushell/modules"
    ];
  }
]
