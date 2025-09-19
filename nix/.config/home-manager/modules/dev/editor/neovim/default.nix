{
  config,
  pkgs,
  ...
}: {
  home.packages = config.lib.neg.pkgsList [
    pkgs.bash-language-server # Bash LSP
    pkgs.neovim # Neovim editor
    pkgs.neovim-remote # nvr (remote control for Neovim)
    pkgs.nil # Nix language server
    pkgs.pylyzer # Python type checker
    pkgs.pyright # Python LSP
    pkgs.ruff # Python linter
    pkgs.rust-analyzer # Rust LSP
  ];
  programs.neovim = {
    plugins = [
      pkgs.vimPlugins.clangd_extensions-nvim # llvm-based engine
      pkgs.vimPlugins.nvim-treesitter # ts support
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
    extraLuaPackages = [ pkgs.luajitPackages.magick ];
    extraPackages = [pkgs.imagemagick];
  };
  xdg.configFile = {
    # █▓▒░ nvim ─────────────────────────────────────────────────────────────────────────
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nvim/.config/nvim";
      recursive = true;
    };
  };
}
