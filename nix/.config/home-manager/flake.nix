{
  description = "Home Manager configuration of neg";
  # Global Nix configuration for this flake (affects local and CI when respected)
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
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
    ];
  };
  inputs = {
    bzmenu = { url = "github:e-tho/bzmenu"; inputs.nixpkgs.follows = "nixpkgs"; };
    chaotic = { url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; inputs.nixpkgs.follows = "nixpkgs"; };
    crane = { url = "github:ipetkov/crane"; inputs.nixpkgs.follows = "nixpkgs"; };
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    # Pin hy3 to a commit compatible with Hyprland v0.50.0 (GitHub archive available)
    hy3 = { url = "github:outfoxxed/hy3?rev=d61a2eb9b9f22c6e46edad3e8f5fbd3578961b11"; inputs.hyprland.follows = "hyprland"; };
    # Pin Hyprland to a stable release to reduce API churn with hy3
    hyprland = { url = "github:hyprwm/Hyprland?ref=v0.50.0"; inputs.nixpkgs.follows = "nixpkgs"; };
    iosevka-neg = { url = "git+ssh://git@github.com/neg-serg/iosevka-neg"; inputs.nixpkgs.follows = "nixpkgs"; };
    iwmenu = { url = "github:e-tho/iwmenu"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs = { url = "github:nixos/nixpkgs"; };
    nvfetcher = { url = "github:berberman/nvfetcher"; inputs.nixpkgs.follows = "nixpkgs"; };
    quickshell = { url = "git+https://git.outfoxxed.me/outfoxxed/quickshell"; inputs.nixpkgs.follows = "nixpkgs"; };
    rsmetrx = { url = "github:neg-serg/rsmetrx"; inputs.nixpkgs.follows = "nixpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    stylix = { url = "github:danth/stylix"; inputs.nixpkgs.follows = "nixpkgs"; };
    nur = { url = "github:nix-community/NUR"; inputs.nixpkgs.follows = "nixpkgs"; };
    yandex-browser = { url = "github:miuirussia/yandex-browser.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
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
    with rec {
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nur.overlays.default ]; # inject NUR
      };
      iosevkaneg = iosevka-neg.packages.${system};
      yandex-browser = yandex-browser.packages.${system};
      bzmenu = bzmenu.packages.${system};
    }; {
      devShells = {
        ${system} = {
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
        };
      };
      packages = {
        ${system} = {
          default = nixpkgs.legacyPackages.${system}.zsh;
          hy3Plugin = hy3.packages.${system}.hy3;
        };
      };
      homeConfigurations."neg" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          # Pass the entire inputs set to modules that reference it
          inputs = inputs;
          inherit hy3;
          inherit iosevkaneg;
          inherit yandex-browser;
        };
        modules = [
          ./home.nix
          stylix.homeModules.stylix
          chaotic.homeManagerModules.default
          sops-nix.homeManagerModules.sops
        ];
      };
      formatter = {
        ${system} = pkgs.alejandra;
      };
      checks = {
        ${system} = {
          fmt-alejandra = pkgs.runCommand "fmt-alejandra" { nativeBuildInputs = [ pkgs.alejandra ]; } ''
            alejandra -q --check .
            touch $out
          '';
          lint-deadnix = pkgs.runCommand "lint-deadnix" { nativeBuildInputs = [ pkgs.deadnix ]; } ''
            deadnix --fail .
            touch $out
          '';
          lint-statix = pkgs.runCommand "lint-statix" { nativeBuildInputs = [ pkgs.statix ]; } ''
            statix check .
            touch $out
          '';
          hm = self.homeConfigurations."neg".activationPackage;
        };
      };
    };
}
