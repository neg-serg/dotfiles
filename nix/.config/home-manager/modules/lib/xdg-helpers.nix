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

  # Declare an XDG data file with automatic guards
  # Ensures $XDG_DATA_HOME (or ~/.local/share) parent dir exists as a real dir,
  # removes any symlink/regular file at the target path, then writes text.
  mkXdgDataText = relPath: text: let
    keyParent = "fixXdgDataParent_" + sanitize relPath;
    keyFile = "fixXdgDataFile_" + sanitize relPath;
  in {
    home.activation."${keyParent}" = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      data_home="$XDG_DATA_HOME"
      if [ -z "$data_home" ]; then data_home="$HOME/.local/share"; fi
      tgt="$data_home/${relPath}"
      parent_dir="$(dirname "$tgt")"
      if [ -L "$parent_dir" ]; then rm -f "$parent_dir"; fi
      mkdir -p "$parent_dir"
    '';
    home.activation."${keyFile}" = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      data_home="$XDG_DATA_HOME"
      if [ -z "$data_home" ]; then data_home="$HOME/.local/share"; fi
      tgt="$data_home/${relPath}"
      if [ -L "$tgt" ]; then rm -f "$tgt"; fi
      if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then rm -f "$tgt"; fi
    '';
    xdg.dataFile."${relPath}".text = text;
  };

  # Declare an XDG cache file with automatic guards
  # Ensures $XDG_CACHE_HOME (or ~/.cache) parent dir exists as a real dir,
  # removes any symlink/regular file at the target path, then writes text.
  mkXdgCacheText = relPath: text: let
    keyParent = "fixXdgCacheParent_" + sanitize relPath;
    keyFile = "fixXdgCacheFile_" + sanitize relPath;
  in {
    home.activation."${keyParent}" = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      cache_home="$XDG_CACHE_HOME"
      if [ -z "$cache_home" ]; then cache_home="$HOME/.cache"; fi
      tgt="$cache_home/${relPath}"
      parent_dir="$(dirname "$tgt")"
      if [ -L "$parent_dir" ]; then rm -f "$parent_dir"; fi
      mkdir -p "$parent_dir"
    '';
    home.activation."${keyFile}" = lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      cache_home="$XDG_CACHE_HOME"
      if [ -z "$cache_home" ]; then cache_home="$HOME/.cache"; fi
      tgt="$cache_home/${relPath}"
      if [ -L "$tgt" ]; then rm -f "$tgt"; fi
      if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then rm -f "$tgt"; fi
    '';
    xdg.cacheFile."${relPath}".text = text;
  };
}
