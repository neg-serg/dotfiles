{
  config,
  pkgs,
  lib,
  fa ? null,
  ...
}:
lib.mkIf (config.features.web.enable && config.features.web.floorp.enable) (let
  common = import ./mozilla-common-lib.nix {inherit lib pkgs config fa;};
in {
  programs.floorp = {
    enable = true;
    package = pkgs.floorp-bin;
    nativeMessagingHosts = common.nativeMessagingHosts;
    profiles.${common.profileId} = {
      isDefault = true;
      extensions = {packages = common.addons.common;};
      settings = common.settings;
      extraConfig = common.extraConfig;
      userChrome = common.userChrome;
    };
    policies = common.policies;
  };
  home.sessionVariables = {
    MOZ_DBUS_REMOTE = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
})
