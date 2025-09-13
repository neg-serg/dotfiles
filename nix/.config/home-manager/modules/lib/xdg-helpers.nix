{ ... }:
{
  mkXdgText = relPath: text: {
    # Aggregated XDG fixups handle parent/target state; just declare the file.
    xdg.configFile."${relPath}".text = text;
  };

  mkXdgSource = relPath: attrs: {
    xdg.configFile."${relPath}" = attrs;
  };

  # Declare an XDG data file with automatic guards
  # Ensures $XDG_DATA_HOME (or ~/.local/share) parent dir exists as a real dir,
  # removes any symlink/regular file at the target path, then writes text.
  mkXdgDataText = relPath: text: {
    xdg.dataFile."${relPath}".text = text;
  };

  # Declare an XDG cache file with automatic guards
  # Ensures $XDG_CACHE_HOME (or ~/.cache) parent dir exists as a real dir,
  # removes any symlink/regular file at the target path, then writes text.
  mkXdgCacheText = relPath: text: {
    xdg.cacheFile."${relPath}".text = text;
  };

  # Same as mkXdgSource but for XDG data files (link-only or attr-based)
  mkXdgDataSource = relPath: attrs: {
    xdg.dataFile."${relPath}" = attrs;
  };

  # Same as mkXdgSource but for XDG cache files (link-only or attr-based)
  mkXdgCacheSource = relPath: attrs: {
    xdg.cacheFile."${relPath}" = attrs;
  };
}
