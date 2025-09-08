{ lib, ... }:
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
  };
}

