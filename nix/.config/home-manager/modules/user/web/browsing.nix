{pkgs, stable, yandex-browser, ...}: {
  imports = [
    ./firefox.nix
    # ./floorp.nix
  ];
  home.packages = with pkgs; [
    yandex-browser.packages.x86_64-linux.yandex-browser-stable # google chrome-based yandex fork
    passff-host # host app for the WebExtension PassFF
    stable.tor-browser # browse web via tor
  ];
}
