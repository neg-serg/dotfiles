{ ... }:
{
  # Write ncpamixer config file under XDG
  xdg.configFile."ncpamixer.conf".text = builtins.readFile ./ncpamixer.conf;
}

