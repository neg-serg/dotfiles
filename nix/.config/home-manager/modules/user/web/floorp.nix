{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf (config.features.web.enable && config.features.web.floorp.enable) (let
  common = import ./mozilla-common-lib.nix { inherit lib pkgs config; };
in {
  programs.floorp = {
    enable = true;
    nativeMessagingHosts = common.nativeMessagingHosts;

    profiles.${common.profileId} = {
      isDefault = true;
      # Declarative extensions (NUR where available)
      extensions = { packages = common.addons.common; };

      # about:config prefs
      settings = common.settings;

      # Optional toggles
      extraConfig = common.extraConfig;

      userChrome = common.userChrome;
    };

    # Policies: force-install addons missing in NUR (AMO latest.xpi)
    policies = common.policies;
  };

  home.sessionVariables = {
    MOZ_DBUS_REMOTE = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
})
