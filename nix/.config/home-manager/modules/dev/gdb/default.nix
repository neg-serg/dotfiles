{ pkgs, ... }:
{
  # Install gdb and manage its config under XDG
  home.packages = [ pkgs.gdb ];

  # Write the gdbinit contents directly (no path/source symlink)
  xdg.configFile."gdb/gdbinit".text = builtins.readFile ../../../../../../gdb/.config/gdb/gdbinit;
}
