{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.dev.enable {
    home.packages = config.lib.neg.pkgsList [
      pkgs.adbtuifm # TUI-based file manager for ADB
      pkgs.android-tools # Android platform tools (adb, fastboot)
      pkgs.jmtpfs # mount MTP devices
      pkgs.scrcpy # control Android device from PC
    ];
  }
