{
  pkgs,
  lib,
  config,
  yandexBrowser ? null,
  ...
}:
with lib; {
  imports = [
    ./defaults.nix
    ./floorp.nix
    ./firefox.nix
    ./librewolf.nix
    ./nyxt.nix
  ];

  config = mkMerge [
    {
      assertions = [
        {
          assertion = (! (config.features.web.enable && config.features.web.yandex.enable)) || (yandexBrowser != null);
          message = "Yandex Browser requested but 'yandexBrowser' extraSpecialArg not provided in flake.nix.";
        }
      ];
    }
    (mkIf config.features.web.enable {
      # Collect package groups and flatten via mkEnabledList to reduce scattered optionals
      home.packages = with pkgs;
        config.lib.neg.pkgsList (
          let
            groups = {
              core = [ passff-host ];
              yandex = lib.optionals (yandexBrowser != null) [ yandexBrowser.yandex-browser-stable ];
            };
            flags = {
              core = true;
              yandex = (yandexBrowser != null) && (config.features.web.yandex.enable or false);
            };
          in config.lib.neg.mkEnabledList flags groups
        );
    })
  ];
}
