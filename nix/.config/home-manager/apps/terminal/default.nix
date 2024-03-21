{ pkgs, ... }: {
  home.packages = with pkgs; [
      asciinema # record terminal
      chafa # terminal graphics
      kitty # fastest terminal emulator so far
      kitty-img # print images inline in kitty
      termplay # play video in terminal
  ];
}
