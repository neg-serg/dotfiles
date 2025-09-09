{ ... }:
{
  # Provide readline inputrc via XDG config (no symlink to dotfiles)
  xdg.configFile."inputrc".text = builtins.readFile ./inputrc;
}

