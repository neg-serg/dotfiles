{ config, pkgs, inputs, ... }: {
  nix.package = pkgs.nix;
  imports = [
    ./secrets
    ./modules
  ];
  xdg.stateHome = "${config.home.homeDirectory}/.local/state";
  home = {
    homeDirectory = "/home/neg";
    stateVersion = "23.11"; # Please read the comment before changing.
    preferXdgDirectories = true;
    username = "neg";
  };
  nixCats = {
    enable = true;
    luaPath = inputs.self + "/nvim/.config/nvim";
    packageDefinitions.merge = {
      nixCats = { pkgs, ... }: {
        categories = inputs.self.lazyPlugins;
      };
    };
  };
}
