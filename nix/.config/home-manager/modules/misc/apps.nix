{ config, pkgs, ... }: {
  home.packages = config.lib.neg.pkgsList [
    pkgs.blesh # bluetooth shell
    pkgs.pwgen # generate passwords
  ];
}
