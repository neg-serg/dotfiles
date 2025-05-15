{pkgs, ...}:
with {
  rofi-games = pkgs.callPackage ../../../packages/rofi-games {};
}; {
  home.packages = with pkgs; [
    (rofi-wayland.override {
      plugins = [
        rofi-file-browser
        rofi-games
      ];
    }) # modern dmenu alternative
    rofi-pass # pass integration for pass
  ];
}
