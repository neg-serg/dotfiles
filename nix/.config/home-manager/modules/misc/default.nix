{ pkgs, ... }: {
  imports = [
    ./unfree.nix
    ./unfree-libretro.nix
    ./unfree-auto.nix
  ];
  home.packages = with pkgs; [
    blesh # bluetooth shell
    pwgen # generate passwords
  ];
}
