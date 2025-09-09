{ lib, pkgs, config, ... }:
with lib; {
  imports = [ ./neovim ];
  config = mkIf config.features.dev.enable {
    home.packages = with pkgs;
      [
        code-cursor-fhs # AI-powered code editor built on VS Code
        lapce # fast code editor in Rust
      ]
      ++ (lib.optionals (config.features.dev.ai.enable or false) [
        lmstudio # desktop app for local/open LLMs
      ]);
    programs.claude-code.enable = true;
  };
}
