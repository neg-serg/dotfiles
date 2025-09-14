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

      # --- Language-specific convenience helpers ---
      # Rust (buildRustPackage): override cargo hash (aka vendor hash)
      # Works with both cargoHash (new) and cargoSha256 (legacy)
      overrideRustCrates = drv: hash:
        drv.overrideAttrs (_: {
          cargoHash = hash;
          cargoSha256 = hash;
        });

      # Go (buildGoModule): override vendor hash
      overrideGoModule = drv: hash:
        drv.overrideAttrs (_: { vendorHash = hash; });
    };
  };
}
