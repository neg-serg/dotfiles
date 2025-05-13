{pkgs, ...}: {
  home.packages = with pkgs; [
    inputplug # xinput event monitor
    slop # rectangle selection
    xss-lock # x locker
  ];
}
