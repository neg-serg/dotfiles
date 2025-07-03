{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  programs.distrobox = { # tool try various distros in cli
    enable = true;
  };
  home.packages = with pkgs; [
    ventoy-full # create bootable usb
  ];
}
