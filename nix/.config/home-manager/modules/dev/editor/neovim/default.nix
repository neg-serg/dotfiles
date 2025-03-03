{
  master,
  config,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
}; {
  home.packages = with master; [
    bash-language-server # bash lsp
    neovim # neovim from master
    neovim-remote # nvr for neovim
    nil # nixos language server
    pylyzer # python type checker
    pyright # python lsp
    ruff-lsp # python lsp
    ruff # python linter
    rust-analyzer # rust lsp
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      clangd_extensions-nvim # llvm-based engine
      nvim-treesitter.withAllGrammars # ts support
    ];
    extraLuaPackages = [ luajitPackages.magick ];
    extraPackages = [ pkgs.imagemagick ];
  };
  xdg.configFile = {
    # █▓▒░ nvim ─────────────────────────────────────────────────────────────────────────
    "nvim" = {
      source = l "${dots}/nvim/.config/nvim";
      recursive = true;
    };
  };
}
