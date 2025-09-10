{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) optionals;
  core = ps:
    with ps; [
      colored # terminal colors utilities
      docopt # simple CLI argument parser
      numpy # numerical computing
      annoy # approximate nearest neighbors
      orjson # fast JSON parser/serializer
      psutil # process and system utilities
      requests # HTTP client
      tabulate # pretty tables for text/CLI
    ];
  tools = ps:
    with ps; [
      dbus-python # DBus bindings (needed for some scripts)
      fontforge # font tools (for monospacifier)
      pynvim # Python client for Neovim
    ];
  pyPackages = ps:
    let
      groups = {
        core = core ps;
        tools = tools ps;
      };
    in config.lib.neg.mkEnabledList config.features.dev.python groups;
in
  lib.mkIf config.features.dev.enable {
    nixpkgs = {
      config.packageOverrides = super: {
        python3-lto = super.python3.override {
          packageOverrides = _: _: {
            enableOptimizations = true;
            enableLTO = true;
            reproducibleBuild = false;
          };
        };
      };
    };
    home.packages = with pkgs; [
      pipx # isolated Python apps installer
      (python3-lto.withPackages pyPackages) # optimized Python with selected libs
    ];
  }
