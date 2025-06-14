{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    adbtuifm # TUI-based file manager for the Android Debug Bridge,
    android-tools # android debug stuff
    jmtpfs # mount mtp devices
    scrcpy # rule android device via pc
  ];
}
