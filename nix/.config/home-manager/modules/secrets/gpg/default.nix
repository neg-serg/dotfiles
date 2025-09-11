{pkgs, ...}:
with {
  pinentryRofi = pkgs.writeShellApplication {
    name = "pinentry-rofi-with-env";
    text = ''
      PATH="$PATH:${pkgs.coreutils}/bin:${pkgs.rofi}/bin"
      "${pkgs.pinentry-rofi}/bin/pinentry-rofi" "$@"
    '';
  };
}; {
  programs.wayprompt = {
    enable = true;
    settings = {
      general = {
        font-regular = "Iosevka:size=14";
        pin-square-amount = 32;
      };
      colours = {
        background = "000000aa";
        foreground = "ffffffaa";
      };
    };
  };
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
