_final: prev: let
  call = prev.callPackage;
in {
  neg = rec {
    # CLI/util packages
    a2ln = call ../a2ln {};
    bt_migrate = call ../bt-migrate {};
    "bt-migrate" = bt_migrate;
    cxxmatrix = call ../cxxmatrix {};
    comma = call ../comma {};

    # Rofi plugins / desktop helpers
    rofi_games = call ../rofi-games {};
    "rofi-games" = rofi_games;
  };
}
