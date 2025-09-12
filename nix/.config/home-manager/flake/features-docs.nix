{lib}: let
  toList = optSet: prefix:
    lib.concatLists (
      lib.mapAttrsToList (
        name: v: let
          cur = lib.optionalString (prefix != "") (prefix + ".") + name;
        in
          if (v ? _type) && (v._type == "option")
          then [
            {
              path = cur;
              description = v.description or "";
              desc = v.description or "";
              type =
                if (v ? type) && (v.type ? name)
                then v.type.name
                else (v.type.description or "unknown");
              default = v.default or null;
              defaultText = v.defaultText or null;
              def =
                v.defaultText or (
                  if v ? default
                  then builtins.toJSON v.default
                  else ""
                );
            }
          ]
          else if builtins.isAttrs v
          then toList v cur
          else []
      )
      optSet
    );
in rec {
  # Evaluate modules/features.nix options and return flat items list
  getFeatureOptionsItems = featuresModule: let
    eval = lib.evalModules {
      modules = [
        ({lib, ...}: {
          config.lib.neg.mkBool = desc: default: (lib.mkEnableOption desc) // {inherit default;};
        })
        featuresModule
        ({lib, ...}: {
          options.assertions = lib.mkOption {
            type = lib.types.anything;
            visible = false;
            description = "internal";
          };
        })
      ];
      check = false;
    };
    opts = eval.options;
    items = toList opts "";
  in
    lib.filter (o: !(lib.hasPrefix "assertions" o.path)) items;

  renderFeaturesOptionsMd = items: let
    esc = s: lib.replaceStrings ["\n" "|"] [" " "\\|"] (toString s);
    rows = lib.concatStringsSep "\n" (map (o: "| ${o.path} | " + esc o.type + " | " + esc o.def + " | " + esc o.desc + " |") items);
  in ''
    # Features Options (auto-generated)

    | Option | Type | Default | Description |
    |---|---|---|---|
    ${rows}
  '';

  renderFeaturesOptionsJson = items: builtins.toJSON items;

  renderDeltasMd = {
    flatNeg,
    flatLite,
  }: let
    keys = lib.unique ((builtins.attrNames flatNeg) ++ (builtins.attrNames flatLite));
    rows = lib.concatStringsSep "\n" (
      map (
        k: let
          a = flatNeg.${k} or null;
          b = flatLite.${k} or null;
        in
          if a != b
          then "| ${k} | ${toString a} | ${toString b} |"
          else ""
      )
      keys
    );
    body = lib.concatStringsSep "\n" (lib.filter (x: x != "") (lib.splitString "\n" rows));
  in ''
    ## Full vs Lite (feature deltas)

    | Option | neg (full) | neg-lite |
    |---|---|---|
    ${body}
  '';
}
