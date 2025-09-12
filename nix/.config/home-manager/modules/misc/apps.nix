{ lib, config, pkgs, ... }:
{
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    blesh # bluetooth shell
    pwgen # generate passwords
  ]);
}
