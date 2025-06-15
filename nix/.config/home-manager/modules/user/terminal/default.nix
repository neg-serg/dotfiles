{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    asciinema # record terminal
    asciinema-agg # asciinema files to gif
    chafa # terminal graphics
    kitty # fastest terminal emulator so far
    kitty-img # print images inline in kitty
  ];
}
