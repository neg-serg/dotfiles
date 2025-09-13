{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    yubikey-agent # ssh agent for yk
    yubikey-manager # yubikey manager cli
    yubikey-personalization # ykinfo
  ];
}
