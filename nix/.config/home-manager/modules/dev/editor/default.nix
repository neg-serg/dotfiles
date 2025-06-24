{pkgs, ...}: {
  home.packages = with pkgs; [
    code-cursor-fhs # AI-powered code editor built on vscode
    zed # to try new editor with the native llm support
  ];
  imports = [
    ./neovim
    ./helix
  ];
}
