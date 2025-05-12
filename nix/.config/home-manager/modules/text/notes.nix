{pkgs, ...}: {
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.05"
  ];
  home.packages = with pkgs; [
    obsidian # notes
    zk # notes database
  ];
}
