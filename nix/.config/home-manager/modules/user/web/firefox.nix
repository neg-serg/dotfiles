{
  lib,
  pkgs,
  config,
  fa ? null,
  ...
}:
with lib;
mkIf (config.features.web.enable && config.features.web.firefox.enable) (let
  common = config.lib.neg.web.mozillaCommon;
in {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts = common.nativeMessagingHosts;
    profiles.${common.profileId} = {
      isDefault = true;
      extensions = { packages = common.addons.common; };
      settings = common.settings;
      extraConfig = common.extraConfig;
      userChrome = common.userChrome;
    };
    policies = common.policies;
  };
})

