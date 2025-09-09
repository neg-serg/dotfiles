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
      home.packages = with pkgs;
        [
          nyxt # common lisp browser
          passff-host # host app for the WebExtension PassFF
        ]
        ++ (optionals (yandexBrowser != null && config.features.web.yandex.enable) [
          yandexBrowser.yandex-browser-stable # Yandex Browser (Chromium)
        ]);
    })
  ];
}
