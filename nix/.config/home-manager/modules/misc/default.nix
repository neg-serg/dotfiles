{pkgs, ...}: {
  home.packages = with pkgs; [
    blesh # bluetooth shell
    pwgen-secure # generate passwords
  ];
}
