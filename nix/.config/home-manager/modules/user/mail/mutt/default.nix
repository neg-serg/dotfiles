{
  lib,
  config,
  ...
}:
let
  xdg = import ../../../lib/xdg-helpers.nix { inherit lib; };
in with lib;
  mkIf config.features.mail.enable (
    lib.mkMerge [
      (xdg.mkXdgSource "mutt" { source = ./conf; })
    ]
  )
