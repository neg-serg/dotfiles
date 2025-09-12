{ config, ... }: {
  # Guard: don't write through an unexpected symlink at ~/.config/inputrc
  home.activation.fixInputrcSymlink =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/inputrc";

  # Provide readline inputrc via XDG config (managed by HM)
  xdg.configFile."inputrc".text = builtins.readFile ./inputrc;
}
