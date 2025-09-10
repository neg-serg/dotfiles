{ lib, config, pkgs, ... }:
{
  home.packages = with pkgs; [
    blesh # bluetooth shell
    pwgen # generate passwords
  ];
}

