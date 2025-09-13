{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.dev.enable {
    home.packages = with pkgs; config.lib.neg.pkgsList [
      adbtuifm # TUI-based file manager for ADB
      android-tools # Android platform tools (adb, fastboot)
      jmtpfs # mount MTP devices
      scrcpy # control Android device from PC
    ];
  }
