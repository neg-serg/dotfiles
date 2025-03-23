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
    executor.url = "github:neg-serg/executor";
    negwm.url = "github:neg-serg/negwm";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-oldstable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:nixos/nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    stylix.url = "github:danth/stylix";
    iosevka-neg = {
      url = "git+ssh://git@github.com/neg-serg/iosevka-neg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yandex-browser = { url = "github:miuirussia/yandex-browser.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    # nixos-generators = {
    #   url = "github:nix-community/nixos-generators";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nixpkgs-wayland = {
    #   url = "github:colemickens/nixpkgs-wayland";
    #   flake = false;
    # };
    # nvfetcher = {
    #   url = "github:berberman/nvfetcher";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # simple-osd-daemons.url = "github:balsoft/simple-osd-daemons";
  };

  outputs = inputs @ {
    nixpkgs,
    chaotic,
    executor,
    home-manager,
    negwm,
    nixpkgs-master,
    nixpkgs-oldstable,
    nixpkgs-stable,
    sops-nix,
    stylix,
    iosevka-neg,
    yandex-browser,
    # home-manager-shell,
    # nixos-generators,
    # nixpkgs-wayland,
    # nvfetcher,
    ...
  }:
    with rec {
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      executorPkg = executor.packages.${system};
      iosevkaneg = iosevka-neg.packages.${system};
      master = nixpkgs-master.legacyPackages.${system};
      negwmPkg = negwm.packages.${system};
      oldstable = nixpkgs-oldstable.legacyPackages.${system};
      stable = nixpkgs-stable.legacyPackages.${system};
      yandex-browser = yandex-browser.packages.${system};
    }; {
      packages.${system}.default = nixpkgs.legacyPackages.${system}.zsh;
      homeConfigurations."neg" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
          inherit oldstable;
          inherit master;
          inherit stable;
          inherit negwmPkg;
          inherit executorPkg;
          inherit iosevkaneg;
          inherit yandex-browser;
        };
        modules = [
          ./home.nix
          chaotic.homeManagerModules.default
          stylix.homeManagerModules.stylix
          sops-nix.homeManagerModules.sops
        ];
      };
    };
}
