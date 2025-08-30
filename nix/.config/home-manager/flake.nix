{
  description = "Home Manager configuration of neg";
  inputs = {
    bzmenu = { url = "github:e-tho/bzmenu"; };
    chaotic = { url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; };
    crane = { url = "github:ipetkov/crane"; };
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    # Pin hy3 to a commit compatible with Hyprland v0.50.0 (GitHub archive available)
    hy3 = { url = "github:outfoxxed/hy3?rev=d61a2eb9b9f22c6e46edad3e8f5fbd3578961b11"; inputs.hyprland.follows = "hyprland"; };
    # Pin Hyprland to a stable release to reduce API churn with hy3
    hyprland = { url = "github:hyprwm/Hyprland?ref=v0.50.0"; };
    iosevka-neg = { url = "git+ssh://git@github.com/neg-serg/iosevka-neg"; inputs.nixpkgs.follows = "nixpkgs"; };
    iwmenu = { url = "github:e-tho/iwmenu"; };
    nixpkgs = { url = "github:nixos/nixpkgs"; };
    nvfetcher = { url = "github:berberman/nvfetcher"; inputs.nixpkgs.follows = "nixpkgs"; };
    quickshell = { url = "git+https://git.outfoxxed.me/outfoxxed/quickshell"; inputs.nixpkgs.follows = "nixpkgs"; };
    rsmetrx = { url = "github:neg-serg/rsmetrx"; inputs.nixpkgs.follows = "nixpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix"; };
    stylix = { url = "github:danth/stylix"; inputs.nixpkgs.follows = "nixpkgs"; };
    nur = { url = "github:nix-community/NUR"; };
    yandex-browser = { url = "github:miuirussia/yandex-browser.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs @ {
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
    };
}
