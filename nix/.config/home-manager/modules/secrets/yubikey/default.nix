{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList [
    pkgs.yubikey-agent # ssh agent for yk
    pkgs.yubikey-manager # yubikey manager cli
    pkgs.yubikey-personalization # ykinfo
  ];
}
