{pkgs, ...}: {
  home.packages = with pkgs; [
    code-cursor-fhs # AI-powered code editor built on vscode
    lmstudio # LM Studio is an easy to use desktop app for experimenting with local and open-source Large Language Models
  ];
  programs.claude-code.enable = true;
  imports = [
    ./neovim
  ];
}
