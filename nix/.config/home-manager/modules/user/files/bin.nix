{
  lib,
  config,
  ...
}: {
  home.file."bin" = config.lib.neg.mkDotfilesSymlink "bin" false;
}
