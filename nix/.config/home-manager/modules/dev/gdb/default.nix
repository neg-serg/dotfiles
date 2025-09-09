{ pkgs, ... }:
{
  # Install gdb and manage its config under XDG
  home.packages = [ pkgs.gdb ];

  # Write the gdbinit contents directly from a file embedded in this module
  xdg.configFile."gdb/gdbinit".text = builtins.readFile ./gdbinit;
}
