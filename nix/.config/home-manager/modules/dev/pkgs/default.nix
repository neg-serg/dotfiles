{
  lib,
  pkgs,
  config,
  ...
}: let
  groups = rec {
    formatters = [
      pkgs.shfmt # shell script formatter
      pkgs.black # Python formatter
      pkgs.stylua # Lua code formatter
    ];
    analyzers = [
      pkgs.flawfinder # examine C/C++ code for security flaws
      pkgs.ruff # Python linter
      pkgs.shellcheck # shell linter
      pkgs.mypy # optional static typing checker for Python
    ];
    codecount = [
      pkgs.cloc # count lines of code
      pkgs.scc # fast, parallel code counter
      pkgs.tokei # blazingly fast code counter
    ];
    radicle = [
      pkgs.radicle-node # Radicle server/node
      pkgs.radicle-explorer # Web frontend for Radicle
    ];
    runtime = [
      pkgs.nodejs_24 # Node.js runtime (npm/yarn tooling)
    ];
    misc = [
      pkgs.deheader # remove unneeded C/C++ includes
    ];

    # Haskell toolchain and related tools
    haskell =
      [
        pkgs.ghc
        pkgs.cabal-install
        pkgs.stack
        pkgs.haskell-language-server
        pkgs.hlint
        pkgs.ormolu
        pkgs.ghcid
      ]
      # Some Haskell tools may be unavailable on a given nixpkgs pin — include conditionally.
      ++ (lib.optionals (pkgs ? fourmolu) [ pkgs.fourmolu ])
      ++ (lib.optionals (pkgs ? hindent) [ pkgs.hindent ]);

    # IaC backend package (Terraform or OpenTofu) controlled by
    # features.dev.iac.backend (default: "terraform").
    iac = let
      backend = config.features.dev.iac.backend or "terraform";
      main =
        if backend == "tofu"
        then pkgs.opentofu
        else pkgs.terraform;
    in [main pkgs.ansible];
  };
in
  lib.mkIf config.features.dev.enable {
    home.packages =
      let
        flags = (config.features.dev.pkgs or {}) // {
          haskell = config.features.dev.haskell.enable or false;
        };
      in config.lib.neg.pkgsList (
        config.lib.neg.mkEnabledList flags groups
      );
  }
