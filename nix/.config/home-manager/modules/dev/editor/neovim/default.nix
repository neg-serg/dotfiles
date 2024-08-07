{
  pkgs,
  config,
  stable,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
}; {
  home.packages = with pkgs; [
    neovim # neovim from master
    neovim-remote # nvr for neovim
    bash-language-server # bash lsp
    pyright # python lsp
    pylyzer # python type checker
    ruff-lsp # python lsp
    ruff # python linter
    rust-analyzer # rust lsp
    stable.nil # nixos language server
  ];
  programs.neovim.plugins = with pkgs.vimPlugins; [
    clangd_extensions-nvim # llvm-based engine
    nvim-treesitter.withAllGrammars # ts support
  ];
  xdg.configFile = {
    # █▓▒░ nvim ─────────────────────────────────────────────────────────────────────────
    "nvim" = {
      source = l "${dots}/nvim/.config/nvim";
      recursive = true;
    };
  };
}
