{pkgs, ...}: {
  home.packages = with pkgs; [
    autocutsel # tool to sync x11 buffers
    clipboard-jh # platform independent clipboard manager, test it more later
    cliphist # wayland stuff for clipboard
    espanso # systemwide expander for keyboard
    haskellPackages.greenclip # yet another clipboard manager
  ];
}
