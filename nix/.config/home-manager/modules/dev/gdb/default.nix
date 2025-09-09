{ pkgs, lib, config, ... }:
{
  # Install gdb and manage its config under XDG
  home.packages = [ pkgs.gdb ];

  # Write the gdbinit contents directly from a file embedded in this module
  xdg.configFile."gdb/gdbinit" = {
    text = builtins.readFile ./gdbinit;
    force = true;
  };

  # Ensure ~/.config/gdb is a real directory (remove stale/broken symlink from older generations)
  home.activation.fixGdbConfigDir =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      GDB_DIR="${config.xdg.configHome}/gdb"
      if [ -L "$GDB_DIR" ]; then
        rm -f "$GDB_DIR"
      fi
      mkdir -p "$GDB_DIR"
    '';
}
