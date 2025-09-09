{
  description = "Home Manager configuration of neg";
  # Global Nix configuration for this flake (affects local and CI when respected)
  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
    # Note: nixConfig cannot import files here (requires literal lists)
    # Keep in sync with caches/substituters.nix and caches/trusted-public-keys.nix
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://cache.garnix.io"
      # Additional popular caches
      "https://numtide.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://hercules-ci.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://nix-gaming.cachix.org"
      # Personal cache
      "https://neg-serg.cachix.org"
    ];
    extra-trusted-public-keys = [
      # nix-community
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # Hyprland
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      # Garnix
      "cache.garnix.io-1:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      # numtide
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      # nixpkgs-wayland
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      # hercules-ci
      "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
      # cuda-maintainers
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      # nix-gaming
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      # personal cache
      "neg-serg.cachix.org-1:MZ+xYOrDj1Uhq8GTJAg//KrS4fAPpnIvaWU/w3Qz/wo="
    ];
  };
  inputs = {
    bzmenu = {
      url = "github:e-tho/bzmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {url = "github:ipetkov/crane";};
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CamelCase alias for convenience in code
    homeManagerInput.follows = "home-manager";
    # Pin hy3 to a commit compatible with Hyprland v0.50.1 (GitHub archive available)
    hy3 = {
      # Pin to the last commit before hy3 switched to the new render API (CHyprColor)
      # to stay compatible with Hyprland v0.50.1 which expects a float alpha
      url = "github:outfoxxed/hy3?rev=1fdc0a291f8c23b22d27d6dabb466d018757243c"; # 2025-08-03^ commit
      # Ensure hy3 uses the same Hyprland input we pin below
      inputs.hyprland.follows = "hyprland";
    };
    # Pin Hyprland to a stable release to reduce API churn with hy3
    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.50.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    iosevka-neg = {
      url = "git+ssh://git@github.com/neg-serg/iosevka-neg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CamelCase alias for convenience in code
    iosevkaNegInput.follows = "iosevka-neg";
    iwmenu = {
      url = "github:e-tho/iwmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs = {url = "github:nixos/nixpkgs";};
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rsmetrx = {
      url = "github:neg-serg/rsmetrx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CamelCase alias for convenience in code
    sopsNixInput.follows = "sops-nix";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CamelCase alias for convenience in code
    stylixInput.follows = "stylix";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CamelCase alias for convenience in code
    yandexBrowserInput.follows = "yandex-browser";
  };

  outputs = inputs @ {
    self,
    chaotic,
    homeManagerInput,
    hy3,
    iosevkaNegInput,
    nixpkgs,
    nur,
    sopsNixInput,
    stylixInput,
    yandexBrowserInput,
    ...
  }: let
    inherit (nixpkgs) lib;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    # Nilla raw-loader compatibility: add a synthetic type to each input
    # Safe no-op for regular flake usage; enables Nilla to accept raw inputs.
    nillaInputs = builtins.mapAttrs (_: input: input // {type = "derivation";}) inputs;

    # Build per-system attributes in one place
    perSystem = lib.genAttrs systems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            nur.overlays.default
            (import ./packages/overlay.nix)
          ]; # inject NUR and local packages overlay under pkgs.neg.*
        };
        iosevkaNeg = iosevkaNegInput.packages.${system};
        yandexBrowser = yandexBrowserInput.packages.${system};
        nurPkgs = nur.packages.${system};
        fa = pkgs.nur.repos.rycee.firefox-addons;

        # Common toolsets for devShells to avoid duplication
        devNixTools = with pkgs; [
          alejandra # Nix formatter
          age # modern encryption tool (for sops)
          deadnix # find dead Nix code
          git-absorb # autosquash fixups into commits
          gitoxide # fast Rust Git tools
          just # task runner
          nil # Nix language server
          sops # secrets management
          statix # Nix linter
          treefmt # formatter orchestrator
        ];
        rustBaseTools = with pkgs; [
          cargo # Rust build tool
          rustc # Rust compiler
        ];
        rustExtraTools = with pkgs; [
          hyperfine # CLI benchmarking
          kitty # terminal (for graphics/testing)
          wl-clipboard # Wayland clipboard helpers
        ];
      in {
        inherit pkgs iosevkaNeg yandexBrowser nurPkgs fa;

        devShells = {
          default = pkgs.mkShell {packages = devNixTools;};
          # Consolidated from shell/flake.nix
          rust = pkgs.mkShell {
            packages = rustBaseTools ++ rustExtraTools;
            RUST_BACKTRACE = "1";
          };
          # Consolidated from fhs/flake.nix
          fhs =
            (pkgs.buildFHSEnv {
              name = "fhs-env";
              targetPkgs = pkgs: with pkgs; [zsh];
            })
              .env;
        };

        packages = {
          default = pkgs.zsh;
          hy3Plugin = hy3.packages.${system}.hy3;
          # Publish options docs as a package for convenience
          options-md = pkgs.writeText "OPTIONS.md" (
            let
              evalCfg = mods:
                homeManagerInput.lib.homeManagerConfiguration {
                  inherit pkgs;
                  extraSpecialArgs = {
                    inputs = nillaInputs;
                    inherit hy3;
                    inherit iosevkaNeg;
                    inherit yandexBrowser;
                    inherit fa;
                  };
                  modules = mods;
                };
              negMods = [./home.nix stylixInput.homeModules.stylix chaotic.homeManagerModules.default sopsNixInput.homeManagerModules.sops];
              liteMods = [(_: {features.profile = "lite";}) ./home.nix stylixInput.homeModules.stylix chaotic.homeManagerModules.default sopsNixInput.homeManagerModules.sops];
              fNeg = (evalCfg negMods).config.features;
              fLite = (evalCfg liteMods).config.features;
              toFlat = set: prefix:
                lib.foldl' (
                  acc: name: let
                    cur = lib.optionalString (prefix != "") (prefix + ".") + name;
                    v = set.${name};
                  in
                    acc
                    // (
                      if builtins.isAttrs v
                      then toFlat v cur
                      else if builtins.isBool v
                      then {${cur} = v;}
                      else {}
                    )
                ) {} (builtins.attrNames set);
              flatNeg = toFlat fNeg "features";
              flatLite = toFlat fLite "features";
              keys = lib.unique ((builtins.attrNames flatNeg) ++ (builtins.attrNames flatLite));
              rows = lib.concatStringsSep "\n" (map (
                  k: let
                    a = flatNeg.${k} or null;
                    b = flatLite.${k} or null;
                  in
                    if a != b
                    then "| ${k} | ${toString a} | ${toString b} |"
                    else ""
                )
                keys);
              deltas = ''
                ## Full vs Lite (feature deltas)

                | Option | neg (full) | neg-lite |
                |---|---|---|
                ${lib.concatStringsSep "\n" (lib.filter (x: x != "") (lib.splitString "\n" rows))}
              '';
            in
              (builtins.readFile ./OPTIONS.md)
              + "\n\n"
              + deltas
          );
          # Auto-generated docs for features.* options (Markdown + JSON)
          features-options-md = pkgs.writeText "features-options.md" (
            let
              eval = lib.evalModules {modules = [./modules/features.nix];};
              opts = eval.options;
              toList = optSet: prefix:
                lib.concatLists (
                  lib.mapAttrsToList (
                    name: v: let
                      cur = lib.optionalString (prefix != "") (prefix + ".") + name;
                    in
                      if (v ? _type) && (v._type == "option")
                      then [
                        {
                          path = cur;
                          desc = v.description or "";
                          type =
                            if (v ? type) && (v.type ? name)
                            then v.type.name
                            else (v.type.description or "unknown");
                          def =
                            v.defaultText or (
                              if v ? default
                              then builtins.toJSON v.default
                              else ""
                            );
                        }
                      ]
                      else if builtins.isAttrs v
                      then toList v cur
                      else []
                  )
                  optSet
                );
              items = toList opts "";
              esc = s: lib.replaceStrings ["\n" "|"] [" " "\\|"] (toString s);
              rows = lib.concatStringsSep "\n" (
                map (o: "| ${o.path} | " + esc o.type + " | " + esc o.def + " | " + esc o.desc + " |") items
              );
            in ''
              # Features Options (auto-generated)

              | Option | Type | Default | Description |
              |---|---|---|---|
              ${rows}
            ''
          );

          features-options-json = pkgs.writeText "features-options.json" (
            let
              eval = lib.evalModules {modules = [./modules/features.nix];};
              opts = eval.options;
              toList = optSet: prefix:
                lib.concatLists (
                  lib.mapAttrsToList (
                    name: v: let
                      cur = lib.optionalString (prefix != "") (prefix + ".") + name;
                    in
                      if (v ? _type) && (v._type == "option")
                      then [
                        {
                          path = cur;
                          description = v.description or "";
                          type =
                            if (v ? type) && (v.type ? name)
                            then v.type.name
                            else (v.type.description or "unknown");
                          default = v.default or null;
                          defaultText = v.defaultText or null;
                        }
                      ]
                      else if builtins.isAttrs v
                      then toList v cur
                      else []
                  )
                  optSet
                );
              items = toList opts "";
            in
              builtins.toJSON items
          );
        };

        # Formatter: treefmt wrapper pinned to repo config
        formatter = pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = [
            pkgs.treefmt # tree-wide formatter orchestrator
            pkgs.alejandra # Nix formatter
            pkgs.statix # Nix linter
            pkgs.deadnix # find dead Nix code
          ];
          text = ''
            set -euo pipefail
            exec treefmt -c ${./treefmt.toml} "$@"
          '';
        };

        # Checks: fail if formatting or linters would change files
        checks = {
          treefmt =
            pkgs.runCommand "treefmt-check" {
              nativeBuildInputs = [
                pkgs.treefmt # orchestrate formatters
                pkgs.alejandra # format Nix code
                pkgs.statix # lint Nix expressions
                pkgs.deadnix # detect unused let bindings/files
              ];
              src = ./.; # make repo contents available inside the build sandbox
            } ''
              set -euo pipefail
              # Work on a writable copy of the repo
              cp -r "$src" ./src
              chmod -R u+w ./src
              cd ./src
              # Ensure cache dir is writable for treefmt/formatters
              export XDG_CACHE_HOME="$PWD/.cache"
              mkdir -p "$XDG_CACHE_HOME"
              # 1) Strict Nix formatting check (alejandra only)
              cat > ./.treefmt-check.toml <<'EOF'
              [global]
              excludes = ["flake.lock", ".git/*", "secrets/crypted/*"]
              [formatter.nix]
              command = "alejandra"
              options = ["-q"]
              includes = ["*.nix"]
              EOF
              treefmt --config-file ./.treefmt-check.toml --fail-on-change .

              # 2) Lint checks: statix (no writes)
              statix check -- .

              # 3) Dead code check: deadnix (no writes, fail on findings)
              deadnix --fail .
              touch "$out"
            '';
          # Build the options documentation as part of checks
          options-md = pkgs.runCommand "options-md" {} ''
            cp ${self.packages.${system}.options-md} "$out"
          '';
          features-options-md = pkgs.runCommand "features-options-md" {} ''
            cp ${self.packages.${system}.features-options-md} "$out"
          '';
          features-options-json = pkgs.runCommand "features-options-json" {} ''
            cp ${self.packages.${system}.features-options-json} "$out"
          '';
        };
      }
    );

    # Choose default system for user HM config
    defaultSystem = "x86_64-linux";
  in {
    devShells = lib.genAttrs systems (s: perSystem.${s}.devShells);
    packages = lib.genAttrs systems (s: perSystem.${s}.packages);
    formatter = lib.genAttrs systems (s: perSystem.${s}.formatter);
    checks = lib.genAttrs systems (
      s:
        perSystem.${s}.checks
        // lib.optionalAttrs (s == defaultSystem) {
          # Run treefmt in check mode to ensure no changes would be made
          hm = self.homeConfigurations."neg".activationPackage;
          hm-lite = self.homeConfigurations."neg-lite".activationPackage;
          # Fast eval matrix for RetroArch toggles (no heavy builds)
          hm-eval-neg-retro-on = let
            hmCfg = homeManagerInput.lib.homeManagerConfiguration {
              inherit (perSystem.${s}) pkgs;
              extraSpecialArgs = {
                inputs = nillaInputs;
                inherit hy3;
                inherit (perSystem.${s}) iosevkaNeg;
                inherit (perSystem.${s}) yandexBrowser;
                inherit (perSystem.${s}) fa;
              };
              modules = [
                ./home.nix
                stylixInput.homeModules.stylix
                chaotic.homeManagerModules.default
                sopsNixInput.homeManagerModules.sops
                (_: {features.emulators.retroarch.full = true;})
              ];
            };
          in
            perSystem.${s}.pkgs.writeText "hm-eval-neg-retro-on.json" (builtins.toJSON hmCfg.config.features);
          hm-eval-neg-retro-off = let
            hmCfg = homeManagerInput.lib.homeManagerConfiguration {
              inherit (perSystem.${s}) pkgs;
              extraSpecialArgs = {
                inputs = nillaInputs;
                inherit hy3;
                inherit (perSystem.${s}) iosevkaNeg;
                inherit (perSystem.${s}) yandexBrowser;
                inherit (perSystem.${s}) fa;
              };
              modules = [
                ./home.nix
                stylixInput.homeModules.stylix
                chaotic.homeManagerModules.default
                sopsNixInput.homeManagerModules.sops
                (_: {features.emulators.retroarch.full = false;})
              ];
            };
          in
            perSystem.${s}.pkgs.writeText "hm-eval-neg-retro-off.json" (builtins.toJSON hmCfg.config.features);
          hm-eval-lite-retro-on = let
            hmCfg = homeManagerInput.lib.homeManagerConfiguration {
              inherit (perSystem.${s}) pkgs;
              extraSpecialArgs = {
                inputs = nillaInputs;
                inherit hy3;
                inherit (perSystem.${s}) iosevkaNeg;
                inherit (perSystem.${s}) yandexBrowser;
                inherit (perSystem.${s}) fa;
              };
              modules = [
                (_: {features.profile = "lite";})
                ./home.nix
                stylixInput.homeModules.stylix
                chaotic.homeManagerModules.default
                sopsNixInput.homeManagerModules.sops
                (_: {features.emulators.retroarch.full = true;})
              ];
            };
          in
            perSystem.${s}.pkgs.writeText "hm-eval-lite-retro-on.json" (builtins.toJSON hmCfg.config.features);
          hm-eval-lite-retro-off = let
            hmCfg = homeManagerInput.lib.homeManagerConfiguration {
              inherit (perSystem.${s}) pkgs;
              extraSpecialArgs = {
                inputs = nillaInputs;
                inherit hy3;
                inherit (perSystem.${s}) iosevkaNeg;
                inherit (perSystem.${s}) yandexBrowser;
                inherit (perSystem.${s}) fa;
              };
              modules = [
                (_: {features.profile = "lite";})
                ./home.nix
                stylixInput.homeModules.stylix
                chaotic.homeManagerModules.default
                sopsNixInput.homeManagerModules.sops
                (_: {features.emulators.retroarch.full = false;})
              ];
            };
          in
            perSystem.${s}.pkgs.writeText "hm-eval-lite-retro-off.json" (builtins.toJSON hmCfg.config.features);
        }
    );

    homeConfigurations."neg" = homeManagerInput.lib.homeManagerConfiguration {
      inherit (perSystem.${defaultSystem}) pkgs;
      extraSpecialArgs = {
        # Pass inputs mapped for Nilla raw-loader (issue #14 workaround)
        inputs = nillaInputs;
        inherit hy3;
        inherit (perSystem.${defaultSystem}) iosevkaNeg;
        inherit (perSystem.${defaultSystem}) yandexBrowser;
        inherit (perSystem.${defaultSystem}) fa;
      };
      modules = [
        ./home.nix
        stylixInput.homeModules.stylix
        chaotic.homeManagerModules.default
        sopsNixInput.homeManagerModules.sops
      ];
    };

    homeConfigurations."neg-lite" = homeManagerInput.lib.homeManagerConfiguration {
      inherit (perSystem.${defaultSystem}) pkgs;
      extraSpecialArgs = {
        inputs = nillaInputs;
        inherit hy3;
        inherit (perSystem.${defaultSystem}) iosevkaNeg;
        inherit (perSystem.${defaultSystem}) yandexBrowser;
        inherit (perSystem.${defaultSystem}) fa;
      };
      modules = [
        (_: {features.profile = "lite";})
        ./home.nix
        stylixInput.homeModules.stylix
        chaotic.homeManagerModules.default
        sopsNixInput.homeManagerModules.sops
      ];
    };
  };
}
