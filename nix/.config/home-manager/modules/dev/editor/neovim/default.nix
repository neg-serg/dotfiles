{
  config,
  pkgs,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
}; {
  home.packages = with pkgs; [
    bash-language-server # bash lsp
    neovim # neovim from master
    neovim-remote # nvr for neovim
    nil # nixos language server
    pylyzer # python type checker
    pyright # python lsp
    ruff # python linter
    rust-analyzer # rust lsp
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      clangd_extensions-nvim # llvm-based engine
      nvim-treesitter # ts support
    ];
    extraLuaConfig = ''
      -- put parsers in a writable dir and ensure it is early on rtp
      local parser_dir = vim.fn.stdpath("data") .. "/treesitter"
      vim.fn.mkdir(parser_dir, "p")
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter.install").compilers = { "cc", "clang", "gcc" }
      require("nvim-treesitter.parsers").get_parser_configs().vim = require("nvim-treesitter.parsers").get_parser_configs().vim
      -- make sure Neovim sees user-built parsers first
      vim.opt.runtimepath:prepend(parser_dir)
      vim.g.ts_install_dir = parser_dir
    '';
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
