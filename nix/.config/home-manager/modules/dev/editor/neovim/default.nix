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
    bash-language-server # Bash LSP
    neovim # Neovim editor
    neovim-remote # nvr (remote control for Neovim)
    nil # Nix language server
    pylyzer # Python type checker
    pyright # Python LSP
    ruff # Python linter
    rust-analyzer # Rust LSP
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
    extraLuaPackages = [luajitPackages.magick];
    extraPackages = [pkgs.imagemagick];
  };
  xdg.configFile = {
    # █▓▒░ nvim ─────────────────────────────────────────────────────────────────────────
    "nvim" = {
      source = l "${dots}/nvim/.config/nvim";
      recursive = true;
    };
  };
}
