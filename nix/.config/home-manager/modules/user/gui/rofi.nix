{pkgs, ...}:
with {
  rofi-games = pkgs.callPackage ../../../packages/rofi-games {};
}; {
  home.packages = with pkgs; [
    rofi-pass-wayland # pass interface for rofi-wayland
    (rofi-wayland.override {
      plugins = [
        rofi-file-browser
        rofi-games
      ];
    }) # modern dmenu alternative
  ];
}
