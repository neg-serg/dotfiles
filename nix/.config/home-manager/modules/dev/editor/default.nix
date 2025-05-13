{pkgs, ...}: {
  home.packages = with pkgs; [
      zed # to try new editor with the native llm support
  ];
  imports = [
    ./neovim
    ./helix
  ];
}
