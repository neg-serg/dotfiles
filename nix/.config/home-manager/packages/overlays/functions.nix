_final: prev: {
  # Shared helper functions under pkgs.neg.functions to DRY up overlay patterns
  neg = (prev.neg or {}) // {
    functions = {
      # Override the Python package scope with a function (self: super: { ... })
      # Usage in an overlay:
      #   python3Packages = pkgs.neg.functions.overridePyScope (self: super: {
      #     foo = super.foo.overrideAttrs (_: { ... });
      #   });
      overridePyScope = f: prev.python3Packages.overrideScope f;

      # Small helper to override attrs of a derivation
      # withOverrideAttrs drv f = drv.overrideAttrs f
      withOverrideAttrs = drv: f: drv.overrideAttrs f;
    };
  };
}

