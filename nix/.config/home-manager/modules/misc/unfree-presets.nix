let
  audio = import ./unfree/categories/audio.nix;
  editors = import ./unfree/categories/editors.nix;
  browsers = import ./unfree/categories/browsers.nix;
  forensics = import ./unfree/categories/forensics.nix;
  misc = import ./unfree/categories/misc.nix;
in {
  # Desktop-oriented unfree packages (composed from categories)
  desktop = audio ++ editors ++ browsers ++ forensics ++ misc;

  # Headless/server preset: no unfree packages allowed
  headless = [ ];
}
