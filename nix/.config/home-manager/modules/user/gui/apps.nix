{pkgs, inputs, ...}: {
  programs.walllust.enable = true;
  home.packages = with pkgs; [
    autocutsel # tool to sync x11 buffers
    clipboard-jh # platform independent clipboard manager, test it more later
    cliphist # wayland stuff for clipboard
    espanso # systemwide expander for keyboard
    haskellPackages.greenclip # yet another clipboard manager
    inputs.bzmenu.packages.${pkgs.system}.default # bluetooth support menu
    matugen # modern theme generator like pywal
  ];
}
