{
  lib,
  config,
  ...
}:
with lib;
  mkIf config.features.mail {
    programs.msmtp.enable = true;
    accounts.email.accounts."gmail".msmtp.enable = true;
  }
