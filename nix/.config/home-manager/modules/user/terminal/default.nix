{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList [
    pkgs.asciinema-agg # asciinema files to gif
    pkgs.asciinema # record terminal
    pkgs.chafa # terminal graphics
    pkgs.kitty # fastest terminal emulator so far
    pkgs.kitty-img # print images inline in kitty
  ];
}
