{pkgs, config, ...}: {
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    yubikey-agent # ssh agent for yk
    yubikey-manager # yubikey manager cli
    yubikey-personalization # ykinfo
  ]);
}
