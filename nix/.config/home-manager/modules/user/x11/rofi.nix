{pkgs, ...}:
with {
  rofi-games = pkgs.callPackage ../../../packages/rofi-games {};
}; {
  home.packages = with pkgs; [
    (rofi.override {
      plugins = [
        rofi-blezz
        rofi-file-browser
        rofi-games
      ];
    }) # modern dmenu alternative
    rofi-pass # pass integration for pass
  ];
}
