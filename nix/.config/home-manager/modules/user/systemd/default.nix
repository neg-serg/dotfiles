{...}: {
  systemd.user.startServices = true;
  imports = [
    ./openrgb.nix
    ./shot-optimizer.nix
    ./pic-dirs.nix
    ./pyprland.nix
    ./quickshell-service.nix
  ];
}
