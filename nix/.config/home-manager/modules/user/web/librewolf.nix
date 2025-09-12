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
  in {
    programs.firefox = {
      enable = true;
      package = pkgs.librewolf;
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
  })
