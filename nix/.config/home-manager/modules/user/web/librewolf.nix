{
  lib,
  pkgs,
  config,
  fa ? null,
  ...
}:
with lib;
  mkIf (config.features.web.enable && config.features.web.librewolf.enable) (let
    common = import ./mozilla-common-lib.nix {inherit lib pkgs config fa;};
  in common.mkBrowser {
    name = "firefox";
    package = pkgs.librewolf;
    profileId = common.profileId;
  })
