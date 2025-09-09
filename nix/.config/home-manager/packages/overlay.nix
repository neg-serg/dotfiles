_final: prev: let
  call = prev.callPackage;
in {
  neg = rec {
    # CLI/util packages
    a2ln = call ./a2ln {};
    bt_migrate = call ./bt-migrate {};
    "bt-migrate" = bt_migrate;
    cxxmatrix = call ./cxxmatrix {};
    comma = call ./comma {};
    mkvcleaner = call ./mkvcleaner {};
    rmpc = call ./rmpc {};

    # Rofi plugins
    rofi_games = call ./rofi-games {};
    "rofi-games" = rofi_games;

    # Yabridgemgr helpers (plumbing + plugins)
    yabridgemgr = rec {
      build_prefix = call ./yabridgemgr/plumbing/build_prefix.nix {};
      mount_prefix = call ./yabridgemgr/plumbing/mount_prefix.nix {wineprefix = build_prefix;};
      umount_prefix = call ./yabridgemgr/plumbing/umount_prefix.nix {};
      plugins = rec {
        voxengo_span = call ./yabridgemgr/plugins/voxengo_span.nix {};
        "voxengo-span" = voxengo_span;
        piz_midichordanalyzer = call ./yabridgemgr/plugins/piz_midichordanalyzer.nix {};
        valhalla_supermassive = call ./yabridgemgr/plugins/valhalla_supermassive.nix {};
      };
    };
  };
}
