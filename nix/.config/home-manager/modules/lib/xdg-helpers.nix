{ lib }:
let
  sanitize = s: lib.replaceStrings ["/" "." "-" " "] ["_" "_" "_" "_"] s;
in {
  mkXdgText = relPath: text: let
    keyParent = "fixXdgParent_" + sanitize relPath;
    keyFile = "fixXdgFile_" + sanitize relPath;
  in {
    home.activation."${keyParent}" = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      config_home="$XDG_CONFIG_HOME"
      if [ -z "$config_home" ]; then config_home="$HOME/.config"; fi
      cfg="$config_home/${relPath}"
      parent_dir="$(dirname "$cfg")"
      if [ -L "$parent_dir" ]; then rm -f "$parent_dir"; fi
      mkdir -p "$parent_dir"
    '';
    home.activation."${keyFile}" = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      config_home="$XDG_CONFIG_HOME"
      if [ -z "$config_home" ]; then config_home="$HOME/.config"; fi
      cfg="$config_home/${relPath}"
      if [ -L "$cfg" ]; then rm -f "$cfg"; fi
      if [ -e "$cfg" ] && [ ! -L "$cfg" ]; then rm -f "$cfg"; fi
    '';
    xdg.configFile."${relPath}".text = text;
  };

  mkXdgSource = relPath: attrs: let
    keyParent = "fixXdgParent_" + sanitize relPath;
    keyFile = "fixXdgFile_" + sanitize relPath;
  in {
    home.activation."${keyParent}" = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      config_home="$XDG_CONFIG_HOME"
      if [ -z "$config_home" ]; then config_home="$HOME/.config"; fi
      cfg="$config_home/${relPath}"
      parent_dir="$(dirname "$cfg")"
      if [ -L "$parent_dir" ]; then rm -f "$parent_dir"; fi
      mkdir -p "$parent_dir"
    '';
    home.activation."${keyFile}" = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      config_home="$XDG_CONFIG_HOME"
      if [ -z "$config_home" ]; then config_home="$HOME/.config"; fi
      cfg="$config_home/${relPath}"
      if [ -L "$cfg" ]; then rm -f "$cfg"; fi
      if [ -e "$cfg" ] && [ ! -L "$cfg" ]; then rm -f "$cfg"; fi
    '';
    xdg.configFile."${relPath}" = attrs;
  };
}

