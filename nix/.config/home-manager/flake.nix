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
    # Nushell package manager (non-flake repo) to avoid vendoring sources
    nupm = {
      url = "github:nushell/nupm";
      flake = false;
    };
    nixpkgs = {url = "github:nixos/nixpkgs";};
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
    docs = import ./flake/features-docs.nix {inherit lib;};
    # Prefer evaluating only one system by default to speed up local eval.
    # You can override the systems list for CI or cross builds by setting
    # HM_SYSTEMS to a comma-separated list (e.g., "x86_64-linux,aarch64-linux").
    defaultSystem = "x86_64-linux";
    systems = let
      fromEnv = builtins.getEnv "HM_SYSTEMS";
      raw = if fromEnv == "" then [] else (lib.splitString "," fromEnv);
      cleaned = lib.unique (lib.filter (s: s != "") raw);
    in if cleaned == [] then [ defaultSystem ] else cleaned;

    # Pass only minimal inputs required by HM modules (hyprland for asserts, nupm for Nushell).
    # Nilla raw-loader compatibility: add a synthetic type to each selected input.
    hmInputs = let
      selected = {
        inherit (inputs) hyprland;
        inherit (inputs) nupm;
      };
    in builtins.mapAttrs (_: input: input // { type = "derivation"; }) selected;

    # Common Home Manager building blocks
    hmBaseModules = {
      profile ? null,
      extra ? [],
    }: let
      base = [
        ./home.nix
        stylixInput.homeModules.stylix
        chaotic.homeManagerModules.default
        sopsNixInput.homeManagerModules.sops
      ];
      profMod = lib.optional (profile == "lite") (_: {features.profile = "lite";});
    in
      profMod ++ base ++ extra;

    mkHMArgs = system: {
      # Pass inputs mapped for Nilla raw-loader and common extras
      inputs = hmInputs;
      inherit hy3;
      inherit (perSystem.${system}) iosevkaNeg;
      # Provide lazy providers to avoid evaluating inputs unless features enable them
      # Firefox addons via NUR
      faProvider = (pkgs: (pkgs.extend nur.overlays.default).nur.repos.rycee.firefox-addons);
      # Lazy Yandex Browser provider
      yandexBrowserProvider = (pkgs: yandexBrowserInput.packages.${pkgs.system});
      # GUI helpers
      qsProvider = (pkgs: inputs.quickshell.packages.${pkgs.system}.default);
      iwmenuProvider = (pkgs: inputs.iwmenu.packages.${pkgs.system}.default);
      bzmenuProvider = (pkgs: inputs.bzmenu.packages.${pkgs.system}.default);
      rsmetrxProvider = (pkgs: inputs.rsmetrx.packages.${pkgs.system}.default);
      # Provide xdg helpers directly to avoid _module.args fallback recursion
      xdg = import ./modules/lib/xdg-helpers.nix { inherit lib; pkgs = perSystem.${system}.pkgs; };
    };

    # Build per-system attributes in one place
    perSystem = lib.genAttrs systems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import ./packages/overlay.nix)
          ]; # local packages overlay under pkgs.neg.* (no global NUR overlay)
          config = {
            allowAliases = false;
          };
        };
        iosevkaNeg = iosevkaNegInput.packages.${system};
        # NUR is accessed lazily via faProvider in mkHMArgs only when needed.

        # Common toolsets for devShells to avoid duplication
        devNixTools = [
          pkgs.alejandra # Nix formatter
          pkgs.age # modern encryption tool (for sops)
          pkgs.deadnix # find dead Nix code
          pkgs.git-absorb # autosquash fixups into commits
          pkgs.gitoxide # fast Rust Git tools
          pkgs.just # task runner
          pkgs.nil # Nix language server
          pkgs.sops # secrets management
          pkgs.statix # Nix linter
          pkgs.treefmt # formatter orchestrator
        ];
        rustBaseTools = [
          pkgs.cargo # Rust build tool
          pkgs.rustc # Rust compiler
        ];
        rustExtraTools = [
          pkgs.hyperfine # CLI benchmarking
          pkgs.kitty # terminal (for graphics/testing)
          pkgs.wl-clipboard # Wayland clipboard helpers
        ];
      in {
        inherit pkgs iosevkaNeg;

        devShells = import ./flake/devshells.nix {
          inherit pkgs rustBaseTools rustExtraTools devNixTools;
        };

        packages =
          let
            extrasEnv = builtins.getEnv "HM_EXTRAS";
            extras = extrasEnv == "1" || extrasEnv == "true" || extrasEnv == "yes";
          in {
            default = pkgs.zsh;
          } // lib.optionalAttrs extras {
            hy3Plugin = hy3.packages.${system}.hy3;
          };

        # Formatter: treefmt wrapper pinned to repo config
        formatter = pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = [
            pkgs.treefmt # tree-wide formatter orchestrator
            pkgs.alejandra # Nix formatter
            pkgs.statix # Nix linter
            pkgs.deadnix # find dead Nix code
            pkgs.shfmt # shell formatter
            pkgs.shellcheck # shell linter
            pkgs.black # Python formatter
            pkgs.ruff # Python linter/fixer
          ];
          text = ''
            set -euo pipefail
            # Use project-local config to keep path inside tree root for treefmt
            exec treefmt -c treefmt.toml "$@"
          '';
        };

        # Checks: fail if formatting or linters would change files
        checks =
          (import ./flake/checks.nix {
            inherit pkgs self system;
          })
          // {
            caches-consistency = pkgs.runCommand "caches-consistency" {} ''
              set -eu
              root=${./.}
              subf="$root/caches/substituters.nix"
              keysf="$root/caches/trusted-public-keys.nix"
              # Ensure every entry listed in these files appears in flake.nix nixConfig
              fail=0
              sanitize() {
                sed -e 's/#.*$//' -e 's/[",]//g' -e 's/^\s*//' -e 's/\s*$//' \
                    -e '/^$/d' -e '/^\[/d' -e '/^\]/d'
              }
              while IFS= read -r s; do
                if ! grep -q -- "\"$s\"" "$root/flake.nix"; then
                  echo "Missing in flake.nix nixConfig.extra-substituters: $s" >&2
                  fail=1
                fi
              done < <(sanitize < "$subf")
              while IFS= read -r s; do
                if ! grep -q -- "\"$s\"" "$root/flake.nix"; then
                  echo "Missing in flake.nix nixConfig.extra-trusted-public-keys: $s" >&2
                  fail=1
                fi
              done < <(sanitize < "$keysf")
              [ $fail -eq 0 ]
              touch $out
            '';
          };
      }
    );

    # Use defaultSystem for user HM configs
  in {
    # Gate devShells/formatter under HM_EXTRAS; always keep defaultSystem for local dev.
    # This reduces multi-system eval noise in CI unless explicitly requested.
    devShells =
      let
        extrasEnv = builtins.getEnv "HM_EXTRAS";
        extras = extrasEnv == "1" || extrasEnv == "true" || extrasEnv == "yes";
        sysList = if extras then systems else [ defaultSystem ];
      in lib.genAttrs sysList (s: perSystem.${s}.devShells);
    packages = lib.genAttrs systems (s: perSystem.${s}.packages);
    formatter =
      let
        extrasEnv = builtins.getEnv "HM_EXTRAS";
        extras = extrasEnv == "1" || extrasEnv == "true" || extrasEnv == "yes";
        sysList = if extras then systems else [ defaultSystem ];
      in lib.genAttrs sysList (s: perSystem.${s}.formatter);
    # Docs outputs are gated by HM_DOCS env; heavy HM evals are skipped by default.
    docs = lib.genAttrs systems (
      s: let
        pkgs = perSystem.${s}.pkgs;
        docEnv = builtins.getEnv "HM_DOCS";
        docsEnabled = docEnv == "1" || docEnv == "true" || docEnv == "yes";
        featureOptionsItems = docs.getFeatureOptionsItems ./modules/features.nix;
      in
        if docsEnabled then {
          options-md = pkgs.writeText "OPTIONS.md" (
            let
              evalCfg = mods:
                homeManagerInput.lib.homeManagerConfiguration {
                  inherit (perSystem.${s}) pkgs;
                  extraSpecialArgs = mkHMArgs s;
                  modules = mods;
                };
              hmFeaturesFor = profile:
                (evalCfg (hmBaseModules {inherit profile;})).config.features;
              fNeg = hmFeaturesFor null;
              fLite = hmFeaturesFor "lite";
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
              deltas = docs.renderDeltasMd {inherit flatNeg flatLite;};
            in
              (builtins.readFile ./OPTIONS.md)
              + "\n\n"
              + deltas
          );
          features-options-md = pkgs.writeText "features-options.md" (docs.renderFeaturesOptionsMd featureOptionsItems);
          features-options-json = pkgs.writeText "features-options.json" (docs.renderFeaturesOptionsJson featureOptionsItems);
        } else {
          options-md = pkgs.writeText "OPTIONS.md" ''
            Docs generation is disabled.
            Set HM_DOCS=1 to enable heavy docs evaluation.
          '';
        }
    );
    checks = lib.genAttrs systems (
      s:
        let
          fullChecksEnv = builtins.getEnv "HM_CHECKS_FULL";
          fullChecks = fullChecksEnv == "1" || fullChecksEnv == "true" || fullChecksEnv == "yes";
          evalWith = profile: retroFlag: let
            hmCfg = homeManagerInput.lib.homeManagerConfiguration {
              inherit (perSystem.${s}) pkgs;
              extraSpecialArgs = mkHMArgs s;
              modules = hmBaseModules {
                inherit profile;
                extra = [(_: {features.emulators.retroarch.full = retroFlag;})];
              };
            };
          in
            perSystem.${s}.pkgs.writeText
            "hm-eval-${
              if profile == "lite"
              then "lite"
              else "neg"
            }-retro-${
              if retroFlag
              then "on"
              else "off"
            }.json"
            (builtins.toJSON hmCfg.config.features);
          # Fast-path eval: disable GUI and Web to focus on CLI/Dev
          evalNoGuiWith = profile: retroFlag: let
            hmCfg = homeManagerInput.lib.homeManagerConfiguration {
              inherit (perSystem.${s}) pkgs;
              extraSpecialArgs = mkHMArgs s;
              modules = hmBaseModules {
                inherit profile;
                extra = [
                  (_: {
                    features.gui.enable = false;
                    features.gui.qt.enable = false;
                    features.web.enable = false;
                    features.emulators.retroarch.full = retroFlag;
                  })
                ];
              };
            };
          in
            perSystem.${s}.pkgs.writeText
            "hm-eval-${
              if profile == "lite" then "lite" else "neg"
            }-nogui-retro-${
              if retroFlag then "on" else "off"
            }.json"
            (builtins.toJSON hmCfg.config.features);
          # Fast-path eval: disable only Web (keep GUI)
          evalNoWebWith = profile: retroFlag: let
            hmCfg = homeManagerInput.lib.homeManagerConfiguration {
              inherit (perSystem.${s}) pkgs;
              extraSpecialArgs = mkHMArgs s;
              modules = hmBaseModules {
                inherit profile;
                extra = [
                  (_: {
                    features.web.enable = false;
                    features.emulators.retroarch.full = retroFlag;
                  })
                ];
              };
            };
          in
            perSystem.${s}.pkgs.writeText
            "hm-eval-${
              if profile == "lite" then "lite" else "neg"
            }-noweb-retro-${
              if retroFlag then "on" else "off"
            }.json"
            (builtins.toJSON hmCfg.config.features);
          base = perSystem.${s}.checks;
          fast = {
            hm-eval-neg-retro-on = evalWith null true;
            hm-eval-neg-retro-off = evalWith null false;
            hm-eval-lite-retro-on = evalWith "lite" true;
            hm-eval-lite-retro-off = evalWith "lite" false;
            # No-GUI fast path (GUI + Web disabled)
            hm-eval-neg-nogui-retro-on = evalNoGuiWith null true;
            hm-eval-neg-nogui-retro-off = evalNoGuiWith null false;
            hm-eval-lite-nogui-retro-on = evalNoGuiWith "lite" true;
            hm-eval-lite-nogui-retro-off = evalNoGuiWith "lite" false;
            # No-Web fast path (Web disabled, GUI intact)
            hm-eval-neg-noweb-retro-on = evalNoWebWith null true;
            hm-eval-neg-noweb-retro-off = evalNoWebWith null false;
            hm-eval-lite-noweb-retro-on = evalNoWebWith "lite" true;
            hm-eval-lite-noweb-retro-off = evalNoWebWith "lite" false;
          };
          heavy = lib.optionalAttrs (s == defaultSystem) {
            hm = self.homeConfigurations."neg".activationPackage;
            hm-lite = self.homeConfigurations."neg-lite".activationPackage;
          };
        in
          base
          // fast
          // lib.optionalAttrs fullChecks heavy
    );

    homeConfigurations."neg" = homeManagerInput.lib.homeManagerConfiguration {
      inherit (perSystem.${defaultSystem}) pkgs;
      extraSpecialArgs = mkHMArgs defaultSystem;
      modules = hmBaseModules {};
    };

    homeConfigurations."neg-lite" = homeManagerInput.lib.homeManagerConfiguration {
      inherit (perSystem.${defaultSystem}) pkgs;
      extraSpecialArgs = mkHMArgs defaultSystem;
      modules = hmBaseModules {profile = "lite";};
    };
  };
}
