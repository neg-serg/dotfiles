{pkgs, ...}: {
  home.packages = with pkgs; [
    code-cursor-fhs # AI-powered code editor built on vscode
    lapce # lightning-fast and Powerful Code Editor written in Rust
    lmstudio # LM Studio is an easy to use desktop app for experimenting with local and open-source Large Language Models
    windsurf # Agentic IDE powered by AI Flow paradigm
  ];
  programs.claude-code.enable = true;
  imports = [
    ./neovim
  ];
}
