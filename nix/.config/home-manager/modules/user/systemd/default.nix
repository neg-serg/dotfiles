{...}: {
  imports = [
    ./openrgb.nix
    ./shot-optimizer.nix
    ./pic-dirs.nix
    ./pyprland.nix
    ./quickshell-service.nix
  ];
  systemd.user.startServices = true;
}
