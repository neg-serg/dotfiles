{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    distrobox # try various distros in cli
    ventoy-full # create bootable usb
  ];
}
