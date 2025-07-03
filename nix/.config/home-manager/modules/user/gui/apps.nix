{pkgs, inputs, ...}: {
  programs.walllust.enable = true;
  home.packages = with pkgs; [
    cliphist # wayland stuff for clipboard
    espanso # systemwide expander for keyboard
    inputs.bzmenu.packages.${pkgs.system}.default # bluetooth support menu
    matugen # modern theme generator like pywal
  ];
}
