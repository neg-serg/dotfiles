{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.dev.enable {
    home.packages = config.lib.neg.filterByExclude (with pkgs; [
      adbtuifm # TUI-based file manager for ADB
      android-tools # Android platform tools (adb, fastboot)
      jmtpfs # mount MTP devices
      scrcpy # control Android device from PC
    ]);
  }
