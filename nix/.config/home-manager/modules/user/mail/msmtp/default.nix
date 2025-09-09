{
  lib,
  config,
  ...
}:
with lib;
  mkIf config.features.mail.enable {
    programs.msmtp.enable = true;
    accounts.email.accounts."gmail".msmtp.enable = true;
  }
