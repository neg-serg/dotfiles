{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    asciinema-agg # asciinema files to gif
    asciinema # record terminal
    chafa # terminal graphics
    kitty # fastest terminal emulator so far
    kitty-img # print images inline in kitty
  ];
}
