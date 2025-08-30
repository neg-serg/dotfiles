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
    yandex-browser.packages.x86_64-linux.yandex-browser-stable # google chrome-based yandex fork
  ];
}
