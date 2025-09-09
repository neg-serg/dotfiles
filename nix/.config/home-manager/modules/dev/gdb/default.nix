{ pkgs, ... }:
{
  # Install gdb and manage its config under XDG
  home.packages = [ pkgs.gdb ];

  # Provide gdbinit from the repository instead of a dotfiles symlink
  xdg.configFile."gdb/gdbinit".source = ../../../../../../gdb/.config/gdb/gdbinit;
}

