{pkgs, ...}: {
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.05"
  ];
  home.packages = with pkgs; [
    zk # notes database
  ];
}
