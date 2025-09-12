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
    docs = import ./flake/features-docs.nix {inherit lib;};
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    # Nilla raw-loader compatibility: add a synthetic type to each input
    # Safe no-op for regular flake usage; enables Nilla to accept raw inputs.
    nillaInputs = builtins.mapAttrs (_: input: input // {type = "derivation";}) inputs;

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
      inputs = nillaInputs;
      inherit hy3;
      inherit (perSystem.${system}) iosevkaNeg;
      inherit (perSystem.${system}) yandexBrowser;
      inherit (perSystem.${system}) fa;
    };

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
        # Collect features.* options once and reuse for MD/JSON
        featureOptionsItems = docs.getFeatureOptionsItems ./modules/features.nix;

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

        devShells = import ./flake/devshells.nix {
          inherit pkgs rustBaseTools rustExtraTools devNixTools;
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
                  # Use local per-system extras; avoid recursion into perSystem
                  extraSpecialArgs = {
                    inputs = nillaInputs;
                    inherit hy3;
                    inherit iosevkaNeg;
                    inherit yandexBrowser;
                    inherit fa;
                  };
                  modules = mods;
                };
              # Shared helper: evaluate features for a given profile using hmBaseModules
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
              deltas = docs.renderDeltasMd {inherit flatNeg flatLite;};
            in
              (builtins.readFile ./OPTIONS.md)
              + "\n\n"
              + deltas
          );
          # Auto-generated docs for features.* options (from shared items)
          features-options-md = pkgs.writeText "features-options.md" (docs.renderFeaturesOptionsMd featureOptionsItems);

          features-options-json = pkgs.writeText "features-options.json" (docs.renderFeaturesOptionsJson featureOptionsItems);
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

    # Choose default system for user HM config
    defaultSystem = "x86_64-linux";
  in {
    devShells = lib.genAttrs systems (s: perSystem.${s}.devShells);
    packages = lib.genAttrs systems (s: perSystem.${s}.packages);
    formatter = lib.genAttrs systems (s: perSystem.${s}.formatter);
    checks = lib.genAttrs systems (
      s:
        perSystem.${s}.checks
        // lib.optionalAttrs (s == defaultSystem) (
          let
            # Factor out repeated HM eval for retroarch toggle
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
          in {
            # Run treefmt in check mode to ensure no changes would be made
            hm = self.homeConfigurations."neg".activationPackage;
            hm-lite = self.homeConfigurations."neg-lite".activationPackage;
            # Fast eval matrix for RetroArch toggles (no heavy builds)
            hm-eval-neg-retro-on = evalWith null true;
            hm-eval-neg-retro-off = evalWith null false;
            hm-eval-lite-retro-on = evalWith "lite" true;
            hm-eval-lite-retro-off = evalWith "lite" false;
          }
        )
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
