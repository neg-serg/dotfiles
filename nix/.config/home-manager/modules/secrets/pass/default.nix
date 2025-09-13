{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    tomb # file encryption in linux
    keepass # password manager with strong cryptography
    pass-git-helper # git credential helper interfacing with pass
    # password manager via gpg
    (pass.withExtensions (ext:
      with ext; [
        # pass-audit # extension for auditing your password repository
        pass-import # tool to import data from existing password managers
        pass-otp # one time passwords integration
        pass-tomb # encrypt all password tree inside a tomb
        pass-update # easy flow to update passwords
      ]))
  ];
}
