{
  pkgs,
  ...
}: {
  imports = [./dunst.nix];
  home.packages = with pkgs; [
    flameshot # interactive screenshot tool
    herbe # notification without daemon and dbus
    maim # screenshot tool for x11
    xdragon # drag and drop from console
  ];
}
