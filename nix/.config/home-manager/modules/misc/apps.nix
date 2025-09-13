{
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    blesh # bluetooth shell
    pwgen # generate passwords
  ];
}
