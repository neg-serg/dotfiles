{ lib, config, ... }:
{
  # Project-specific helpers under lib.neg
  config.lib.neg = {
    # mkEnabledList flags groups -> concatenated list of groups
    # flags: { a = true; b = false; }
    # groups: { a = [pkg1]; b = [pkg2]; }
    # => [pkg1]
    mkEnabledList = flags: groups:
      let
        names = builtins.attrNames groups;
      in lib.concatLists (
        builtins.map (n: lib.optionals (flags.${n} or false) (groups.${n} or [])) names
      );

    # Alias
    mkPackagesFromGroups = flags: groups: (config.lib.neg.mkEnabledList flags groups);

    # Emit a warning (non-fatal) when condition holds
    mkWarnIf = cond: msg: {
      warnings = lib.optional cond msg;
    };

    # Make an enable option with default value
    mkBool = desc: default:
      (lib.mkEnableOption desc) // { default = default; };

    # Browser addons helper: produce well-known addon lists given NUR addons set
    browserAddons = fa:
      let
        _ = fa; # anchor to avoid unused warning
      in {
        common = with fa; [
          augmented-steam
          cookie-quick-manager
          darkreader
          enhanced-github
          export-tabs-urls-and-titles
          lovely-forks
          search-by-image
          stylus
          tabliss
          to-google-translate
          tridactyl
        ];
      };
  };
}
