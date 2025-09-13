{
  pkgs,
  lib,
  config,
  yandexBrowser ? null,
  ...
}:
with lib; {
  imports = [
    ./mozilla-common.nix
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
      home.packages = with pkgs; config.lib.neg.pkgsList (
        [ passff-host ]
        ++ (optionals (yandexBrowser != null && config.features.web.yandex.enable) [
          yandexBrowser.yandex-browser-stable # Yandex Browser (Chromium)
        ])
      );
    })
  ];
}
