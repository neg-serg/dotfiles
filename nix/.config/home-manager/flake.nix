{
  description = "Home Manager configuration of neg";
  # Global Nix configuration for this flake (affects local and CI when respected)
  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
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
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    };

  outputs = inputs @ {
    self,
    bzmenu,
    chaotic,
    home-manager,
    hy3,
    hyprland,
    iosevka-neg,
    nixpkgs,
    nur,
    nvfetcher,
    quickshell,
    rsmetrx,
    sops-nix,
    stylix,
    yandex-browser,
    ...
  }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Nilla raw-loader compatibility: add a synthetic type to each input
      # Safe no-op for regular flake usage; enables Nilla to accept raw inputs.
      nillaInputs = builtins.mapAttrs (_: input: input // {type = "derivation";}) inputs;

      # Build per-system attributes in one place
      perSystem = lib.genAttrs systems (
        system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                nur.overlays.default
                (import ./packages/overlay.nix)
              ]; # inject NUR and local packages overlay under pkgs.neg.*
            };
            iosevkaneg = iosevka-neg.packages.${system};
            yandexBrowser = yandex-browser.packages.${system};
            _bzmenu = bzmenu.packages.${system};
          in {
            inherit pkgs iosevkaneg yandexBrowser;

            devShells = {
              default = pkgs.mkShell {
                packages = with pkgs; [
                  alejandra
                  age
                  deadnix
                  git-absorb
                  gitoxide
                  just
                  nil
                  sops
                  statix
                  treefmt
                ];
              };
              # Consolidated from shell/flake.nix
              rust = pkgs.mkShell {
                packages = with pkgs; [
                  cargo
                  rustc
                  hyperfine
                  kitty
                  wl-clipboard
                ];
                RUST_BACKTRACE = "1";
              };
              # Consolidated from fhs/flake.nix
              fhs = (pkgs.buildFHSEnv {
                name = "fhs-env";
                targetPkgs = pkgs: with pkgs; [zsh];
              })
              .env;
            };

            packages = {
              default = pkgs.zsh;
              hy3Plugin = hy3.packages.${system}.hy3;
            };

            formatter = pkgs.writeShellApplication {
              name = "fmt";
              runtimeInputs = [pkgs.alejandra];
              text = ''
                set -euo pipefail
                alejandra -q .
              '';
            };

            checks = {
              fmt-alejandra = pkgs.runCommand "fmt-alejandra" {nativeBuildInputs = [pkgs.alejandra];} ''
                alejandra -q --check .
                touch $out
              '';
              lint-deadnix = pkgs.runCommand "lint-deadnix" {nativeBuildInputs = [pkgs.deadnix];} ''
                deadnix --fail .
                touch $out
              '';
              lint-statix = pkgs.runCommand "lint-statix" {nativeBuildInputs = [pkgs.statix];} ''
                statix check .
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
          // lib.optionalAttrs (s == defaultSystem) {
            hm = self.homeConfigurations."neg".activationPackage;
          }
      );

      homeConfigurations."neg" = home-manager.lib.homeManagerConfiguration {
        pkgs = perSystem.${defaultSystem}.pkgs;
        extraSpecialArgs = {
          # Pass inputs mapped for Nilla raw-loader (issue #14 workaround)
          inputs = nillaInputs;
          inherit hy3;
          iosevkaneg = perSystem.${defaultSystem}.iosevkaneg;
          yandex-browser = perSystem.${defaultSystem}.yandexBrowser;
        };
        modules = [
          ./home.nix
          stylix.homeModules.stylix
          chaotic.homeManagerModules.default
          sops-nix.homeManagerModules.sops
        ];
      };
    };
}
