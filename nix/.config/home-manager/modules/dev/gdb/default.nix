{ lib, config, pkgs, ... }:
{
  # Install gdb and manage its config under XDG
  home.packages = config.lib.neg.filterByExclude [ pkgs.gdb ];

  # Write the gdbinit contents directly from a file embedded in this module
  xdg.configFile."gdb/gdbinit" = {
    text = builtins.readFile ./gdbinit;
    force = true;
  };

  # Ensure ~/.config/gdb is a real directory (remove stale/broken symlink from older generations)
  home.activation.fixGdbConfigDir =
    config.lib.neg.mkEnsureRealDir "${config.xdg.configHome}/gdb";
}
