{
  description = "Home Manager configuration of neg";
  inputs = {
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-shell = {
      url = "sourcehut:~dermetfan/home-manager-shell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    bzmenu.url = "github:e-tho/bzmenu";
    nixpkgs.url = "github:nixos/nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    iosevka-neg = {
      url = "git+ssh://git@github.com/neg-serg/iosevka-neg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yandex-browser = { url = "github:miuirussia/yandex-browser.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    nvfetcher = { url = "github:berberman/nvfetcher"; inputs.nixpkgs.follows = "nixpkgs"; };
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs @ {
    bzmenu,
    chaotic,
    home-manager,
    home-manager-shell,
    hyprland,
    iosevka-neg,
    nixpkgs,
    nvfetcher,
    sops-nix,
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
          inherit inputs;
          inherit iosevkaneg;
          inherit yandex-browser;
        };
        modules = [
          ./home.nix
          chaotic.homeManagerModules.default
          sops-nix.homeManagerModules.sops
        ];
      };
    };
}
