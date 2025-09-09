{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) optionals;
  groups = with pkgs; rec {
    formatters = [
      shfmt # shell script formatter
      black # Python formatter
      stylua # Lua code formatter
    ];
    analyzers = [
      flawfinder # examine C/C++ code for security flaws
      ruff # Python linter
      shellcheck # shell linter
      mypy # optional static typing checker for Python
    ];
    codecount = [
      cloc # count lines of code
      scc # fast, parallel code counter
      tokei # blazingly fast code counter
    ];
    radicle = [
      radicle-node # Radicle server/node
      radicle-explorer # Web frontend for Radicle
    ];
    runtime = [
      nodejs_24 # Node.js runtime (npm/yarn tooling)
    ];
    misc = [
      deheader # remove unneeded C/C++ includes
      terraform # IaC CLI (HashiCorp Terraform)
      terraform-ls # Terraform language server for editors
    ];

    # Infrastructure-as-Code toolchain
    iac = [
      terraform      # main Terraform CLI
      terraform-ls   # language server for editor integrations
      terragrunt     # wrapper for DRY Terraform configs
      tflint         # Terraform linter
    ];
  };
in
  lib.mkIf config.features.dev.enable {
    home.packages =
      (optionals config.features.dev.pkgs.formatters groups.formatters)
      ++ (optionals config.features.dev.pkgs.analyzers groups.analyzers)
      ++ (optionals config.features.dev.pkgs.codecount groups.codecount)
      ++ (optionals config.features.dev.pkgs.iac groups.iac)
      ++ (optionals config.features.dev.pkgs.radicle groups.radicle)
      ++ (optionals config.features.dev.pkgs.runtime groups.runtime)
      ++ (optionals config.features.dev.pkgs.misc groups.misc);
  }
