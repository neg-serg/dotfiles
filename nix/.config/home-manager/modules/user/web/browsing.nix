{
  pkgs,
  yandex-browser,
  ...
}: {
  imports = [
    ./floorp.nix
  ];
  home.packages = with pkgs; [
    nyxt # common lisp browser
    passff-host # host app for the WebExtension PassFF
    yandex-browser.packages.${pkgs.system}.yandex-browser-stable # google chrome-based yandex fork
  ];
}
