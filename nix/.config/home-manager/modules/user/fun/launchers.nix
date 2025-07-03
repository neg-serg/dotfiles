{pkgs, ...}: {
  home.packages = with pkgs; [
    lutris # It always struck me as wonky, but I'm including this game launcher for now. EDIT: Nope, still wonky AF. Bye.
    proton-caller # automates launching proton games
    protonup # automates updating GloriousEggroll's Proton-GE
    vkbasalt # Vulkan post processing layer to enhance the visual graphics of games
    vkbasalt-cli # cli for it
  ];
}
