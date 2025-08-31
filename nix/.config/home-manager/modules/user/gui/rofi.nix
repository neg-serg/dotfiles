{pkgs, ...}: {
  home.packages = with pkgs; [
    rofi-pass-wayland # pass interface for rofi-wayland
    (rofi-wayland.override {
      plugins = [
        rofi-file-browser
        pkgs.neg.rofi_games
      ];
    }) # modern dmenu alternative
  ];
}
