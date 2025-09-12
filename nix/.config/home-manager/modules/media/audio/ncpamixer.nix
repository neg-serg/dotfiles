{ config, ... }: {
  # Guard: avoid writing through an unexpected symlink
  home.activation.fixNcpamixerConfSymlink =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/ncpamixer.conf";

  # Write ncpamixer config file under XDG
  xdg.configFile."ncpamixer.conf".text = builtins.readFile ./ncpamixer.conf;
}
