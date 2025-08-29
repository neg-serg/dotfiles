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
    nixCats = { url = "github:BirdeeHub/nixCats-nvim"; };
    neg-nvim = { url = "github:neg-serg/neg.nvim"; flake = false; };
    comment-nvim-src = { url = "github:numToStr/Comment.nvim"; flake = false; };
    leetbuddy-nvim-src = { url = "github:Dhanus3133/LeetBuddy.nvim"; flake = false; };
    luasnip-src = { url = "github:L3MON4D3/LuaSnip"; flake = false; };
    officer-nvim-src = { url = "github:pianocomposer321/officer.nvim"; flake = false; };
    shirotelin-src = { url = "github:yasukotelin/shirotelin"; flake = false; };
    vim-diagon-src = { url = "github:willchao612/vim-diagon"; flake = false; };
    vim-notableft-src = { url = "github:svermeulen/vim-NotableFt"; flake = false; };
    vim-ref-src = { url = "github:thinca/vim-ref"; flake = false; };
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
        overlays = [
          nur.overlays.default # inject NUR
          (final: prev: {
            vimPlugins = prev.vimPlugins // {
              neg-nvim = prev.vimUtils.buildVimPlugin {
                pname = "neg-nvim";
                version = "unstable";
                src = inputs.neg-nvim;
              };
              "Comment-nvim" = prev.vimUtils.buildVimPlugin {
                pname = "Comment.nvim";
                version = "unstable";
                src = inputs."comment-nvim-src";
              };
              "LeetBuddy-nvim" = prev.vimUtils.buildVimPlugin {
                pname = "LeetBuddy.nvim";
                version = "unstable";
                src = inputs."leetbuddy-nvim-src";
              };
              LuaSnip = prev.vimUtils.buildVimPlugin {
                pname = "LuaSnip";
                version = "unstable";
                src = inputs."luasnip-src";
              };
              "officer-nvim" = prev.vimUtils.buildVimPlugin {
                pname = "officer.nvim";
                version = "unstable";
                src = inputs."officer-nvim-src";
              };
              shirotelin = prev.vimUtils.buildVimPlugin {
                pname = "shirotelin";
                version = "unstable";
                src = inputs."shirotelin-src";
              };
              "vim-diagon" = prev.vimUtils.buildVimPlugin {
                pname = "vim-diagon";
                version = "unstable";
                src = inputs."vim-diagon-src";
              };
              "vim-NotableFt" = prev.vimUtils.buildVimPlugin {
                pname = "vim-NotableFt";
                version = "unstable";
                src = inputs."vim-notableft-src";
              };
              "vim-ref" = prev.vimUtils.buildVimPlugin {
                pname = "vim-ref";
                version = "unstable";
                src = inputs."vim-ref-src";
              };
            };
          })
        ];
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
      lib = {
        lazyPlugins = {
          start =
            let
              vp = pkgs.vimPlugins;
              l = pkgs.lib;
              plugin = name: l.optional (builtins.hasAttr name vp) (builtins.getAttr name vp);
            in
            builtins.concatLists [
              (plugin "lazy-nvim")
              (plugin "rainbow-delimiters-nvim")
              (plugin "neg-nvim")
              (plugin "nvim-treesitter")
              (plugin "shirotelin")
              (plugin "LuaSnip")
              (plugin "noice-nvim")
              (plugin "nvim-lspconfig")
              (plugin "blink-cmp")
              (plugin "neogit")
              (plugin "gitsigns-nvim")
              (plugin "vim-flog")
              (plugin "diffview-nvim")
              (plugin "nvim-dap")
              (plugin "fastaction-nvim")
              (plugin "LeetBuddy-nvim")
              (plugin "nvim-highlight-colors")
              (plugin "lazydev-nvim")
              (plugin "trouble-nvim")
              (plugin "fidget-nvim")
              (plugin "vim-gnupg")
              (plugin "vimtex")
              (plugin "nvim-lint")
              (plugin "Comment-nvim")
              (plugin "officer-nvim")
              (plugin "other-nvim")
              (plugin "conform-nvim")
              (plugin "treesj")
              (plugin "vim-matchup")
              (plugin "trim-nvim")
              (plugin "flash-nvim")
              (plugin "vim-easy-align")
              (plugin "nvim-surround")
              (plugin "vim-suda")
              (plugin "hop-nvim")
              (plugin "vim-NotableFt")
              (plugin "mkdir-nvim")
              (plugin "yazi-nvim")
              (plugin "oil-nvim")
              (plugin "vim-fetch")
              (plugin "nginx-vim")
              (plugin "qmk-nvim")
              (plugin "kdl-vim")
              (plugin "vim-tridactyl")
              (plugin "cellular-automaton-nvim")
              (plugin "neocord")
              (plugin "kitty-scrollback-nvim")
              # langmapper-nvim intentionally omitted
              (plugin "harpoon")
              (plugin "leap-nvim")
              (plugin "vim-asterisk")
              (plugin "vim-ref")
              (plugin "heirline-nvim")
              (plugin "vim-startuptime")
              (plugin "grug-far-nvim")
              (plugin "render-markdown-nvim")
              (plugin "nvim-rip-substitute")
              (plugin "nvim-various-textobjs")
              (plugin "zen-mode-nvim")
              (plugin "vim-markdown-toc")
              (plugin "orgmode")
              (plugin "vim-markdown")
              (plugin "telekasten-nvim")
              (plugin "vim-diagon")
              (plugin "toggleterm-nvim")
              (plugin "telescope-nvim")
              (plugin "diagram-nvim")
              (plugin "image-nvim")
            ];
        };
      };
    };
}
