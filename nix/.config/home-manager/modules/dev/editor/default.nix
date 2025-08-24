{pkgs, ...}: {
  home.packages = with pkgs; [
    code-cursor-fhs # AI-powered code editor built on vscode
    lmstudio # LM Studio is an easy to use desktop app for experimenting with local and open-source Large Language Models
    zed-editor # to try new editor with the native llm support
  ];
  imports = [
    ./neovim
    ./helix
  ];
}
