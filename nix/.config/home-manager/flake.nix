{
  description = "Home Manager configuration of neg";
  inputs = {
    bzmenu = { url = "github:e-tho/bzmenu"; };
    chaotic = { url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; };
    crane = { url = "github:ipetkov/crane"; };
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    hy3 = { url = "github:outfoxxed/hy3"; inputs.hyprland.follows = "hyprland"; };
    hyprland = { url = "github:hyprwm/Hyprland"; };
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
    nixCats = { url = "github:BirdeeHub/nixCats-nvim"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs @ {
    bzmenu,
    chaotic,
    home-manager,
    hy3,
    hyprland,
    iosevka-neg,
    nixCats,
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
          nixCats.homeModule
        ];
      };
      lazyPlugins = {
        start = with pkgs.vimPlugins; [
          lazy-nvim
          rainbow-delimiters-nvim
          neg-nvim
          nvim-treesitter
          shirotelin
          LuaSnip
          noice-nvim
          nvim-lspconfig
          blink-cmp
          neogit
          gitsigns-nvim
          vim-flog
          diffview-nvim
          nvim-dap
          fastaction-nvim
          LeetBuddy-nvim
          nvim-highlight-colors
          lazydev-nvim
          trouble-nvim
          fidget-nvim
          vim-gnupg
          vimtex
          nvim-lint
          Comment-nvim
          officer-nvim
          other-nvim
          conform-nvim
          treesj
          vim-matchup
          trim-nvim
          flash-nvim
          vim-easy-align
          nvim-surround
          suda-vim
          hop-nvim
          vim-NotableFt
          mkdir-nvim
          yazi-nvim
          oil-nvim
          vim-fetch
          nginx-vim
          qmk-nvim
          kdl-vim
          vim-tridactyl
          cellular-automaton-nvim
          neocord
          kitty-scrollback-nvim
          # langmapper-nvim
          harpoon
          leap-nvim
          vim-asterisk
          vim-ref
          heirline-nvim
          vim-startuptime
          grug-far-nvim
          render-markdown-nvim
          nvim-rip-substitute
          nvim-various-textobjs
          zen-mode-nvim
          vim-markdown-toc
          orgmode
          vim-markdown
          telekasten-nvim
          vim-diagon
          toggleterm-nvim
          telescope-nvim
          diagram-nvim
          image-nvim
        ];
      };
    };
}
