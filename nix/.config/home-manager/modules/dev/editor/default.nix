{
  lib,
  pkgs,
  config,
  ...
}:
with lib; {
  imports = [./neovim];
  config =
    (mkIf config.features.dev.enable {
      # Group editor tools and AI tools; flatten via mkEnabledList
      home.packages = with pkgs;
        config.lib.neg.pkgsList (
          let
            groups = {
              core = [
                code-cursor-fhs # AI-powered code editor built on VS Code
                lapce # fast code editor in Rust
              ];
              ai = [ lmstudio ]; # desktop app for local/open LLMs
            };
            flags = {
              core = true;
              ai = (config.features.dev.ai.enable or false);
            };
          in config.lib.neg.mkEnabledList flags groups
        );
    })
    // (mkIf (config.features.dev.ai.enable or false) {
      programs.claude-code.enable = true;
    });
}
