{pkgs, ...}: {
  home.packages = with pkgs; [
    blesh # bluetooth shell
    imwheel # for mouse wheel scrolling
    pwgen # generate passwords
  ];
}
