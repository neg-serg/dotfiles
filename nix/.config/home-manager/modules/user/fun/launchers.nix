{pkgs, ...}: {
  programs.lutris = {
    enable = true;
    winePackages = [
      pkgs.wineWow64Packages.full # full 32/64-bit Wine
    ];
  };
  home.packages = with pkgs; [
    proton-caller # automates launching proton games
    protonplus # simple Wine and Proton-based compatibility tools manager
    protontricks # simple wrapper for running Winetricks commands for Proton-enabled games
    protonup # automates updating GloriousEggroll's Proton-GE
    vkbasalt # vulkan post processing layer to enhance the visual graphics of games
    vkbasalt-cli # cli for it
  ];
}
