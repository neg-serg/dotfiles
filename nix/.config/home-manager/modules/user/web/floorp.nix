{
  config,
  pkgs,
  lib,
  fa ? null,
  ...
}:
lib.mkIf (config.features.web.enable && config.features.web.floorp.enable) (let
  common = import ./mozilla-common-lib.nix {inherit lib pkgs config fa;};
in (common.mkBrowser {
  name = "floorp";
  package = pkgs.floorp-bin;
  profileId = common.profileId;
}) // {
  home.sessionVariables = {
    MOZ_DBUS_REMOTE = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
})
