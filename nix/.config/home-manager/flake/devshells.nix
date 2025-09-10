{ pkgs, rustBaseTools, rustExtraTools, devNixTools }:
{
  # Basic Nix/dev tools
  default = pkgs.mkShell { packages = devNixTools; };

  # Consolidated from shell/flake.nix
  rust = pkgs.mkShell {
    packages = rustBaseTools ++ rustExtraTools;
    RUST_BACKTRACE = "1";
  };

  # Consolidated from fhs/flake.nix
  fhs =
    (pkgs.buildFHSEnv {
      name = "fhs-env";
      targetPkgs = pkgs: with pkgs; [ zsh ];
    }).env;
}

