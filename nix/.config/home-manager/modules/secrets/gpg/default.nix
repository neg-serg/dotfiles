{ pkgs, lib, config, ... }:
with {
  pinentryRofi = pkgs.writeShellApplication {
    name = "pinentry-rofi-with-env";
    text = ''
      PATH="$PATH:${pkgs.coreutils}/bin:${pkgs.rofi}/bin"
      "${pkgs.pinentry-rofi}/bin/pinentry-rofi" "$@"
    '';
  };
};
with lib;
mkIf config.features.gpg.enable {
  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      disable-ccid = true;
      pcsc-shared = true;
      reader-port = "Yubico Yubi";
    };
  };
  services.gpg-agent = {
    defaultCacheTtl = 60480000;
    enableExtraSocket = true;
    enableScDaemon = true;
    enableSshSupport = false;
    enableZshIntegration = true;
    enable = true;
    extraConfig = ''pinentry-program ${pinentryRofi}/bin/pinentry-rofi-with-env '';
    verbose = true;
  };
}
