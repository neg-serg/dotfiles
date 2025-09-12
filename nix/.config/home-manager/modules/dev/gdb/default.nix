{
  lib,
  config,
  pkgs,
  ...
}: let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
in {
  # Install gdb and manage its config under XDG
  home.packages = config.lib.neg.filterByExclude [pkgs.gdb];
}
// (xdg.mkXdgText "gdb/gdbinit" (builtins.readFile ./gdbinit))
