{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    asciinema-agg # asciinema files to gif
    asciinema # record terminal
    chafa # terminal graphics
    kitty # fastest terminal emulator so far
    kitty-img # print images inline in kitty
  ]);
}
