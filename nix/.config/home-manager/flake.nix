{
  description = "Home Manager configuration of neg";
  inputs = {
    ags = { url = "github:aylur/ags"; };
    bzmenu = { url = "github:e-tho/bzmenu"; };
    chaotic = { url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; };
    crane = { url = "github:ipetkov/crane"; };
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    hy3 = { url = "github:outfoxxed/hy3"; inputs.hyprland.follows = "hyprland"; };
    hyprland = { url = "github:hyprwm/Hyprland"; };
    hyprpanel = { url = "github:Jas-SinghFSU/HyprPanel"; };
    iosevka-neg = { url = "git+ssh://git@github.com/neg-serg/iosevka-neg"; inputs.nixpkgs.follows = "nixpkgs"; };
    iwmenu = { url = "github:e-tho/iwmenu"; };
    matugen = { url = "github:/InioX/Matugen"; };
    nixpkgs = { url = "github:nixos/nixpkgs"; };
    nvfetcher = { url = "github:berberman/nvfetcher"; inputs.nixpkgs.follows = "nixpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix"; };
    stylix = { url = "github:danth/stylix"; inputs.nixpkgs.follows = "nixpkgs"; };
    yandex-browser = { url = "github:miuirussia/yandex-browser.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs @ {
    ags,
    bzmenu,
    chaotic,
    home-manager,
    hy3, 
    hyprland,
    iosevka-neg,
    matugen,
    nixpkgs,
    nvfetcher,
    sops-nix,
    stylix,
    yandex-browser,
    ...
  }:
    with rec {
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ inputs.hyprpanel.overlay ];
      };
      iosevkaneg = iosevka-neg.packages.${system};
      yandex-browser = yandex-browser.packages.${system};
      bzmenu = bzmenu.packages.${system};
    }; {
      packages.${system}.default = nixpkgs.legacyPackages.${system}.zsh;
      homeConfigurations."neg" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit hy3;
          inherit inputs;
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
