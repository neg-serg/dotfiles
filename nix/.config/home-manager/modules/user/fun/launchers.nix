{
  pkgs,
  config,
  ...
}: {
  programs.lutris = {
    enable = true;
    winePackages = [
      pkgs.wineWow64Packages.full # full 32/64-bit Wine
    ];
  };
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    proton-caller # launch Proton games via proton-caller
    protonplus # Wine/Proton manager
    protontricks # Winetricks wrapper for Proton prefixes
    protonup # install/update Proton-GE builds
    vkbasalt # Vulkan post-processing layer
    vkbasalt-cli # CLI for vkBasalt
  ]);
}
