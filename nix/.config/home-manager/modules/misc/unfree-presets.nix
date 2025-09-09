let
  audio = import ./unfree/categories/audio.nix;
  editors = import ./unfree/categories/editors.nix;
  ai = import ./unfree/categories/ai-tools.nix;
  browsers = import ./unfree/categories/browsers.nix;
  forensicsStego = import ./unfree/categories/forensics-stego.nix;
  forensicsAnalysis = import ./unfree/categories/forensics-analysis.nix;
  misc = import ./unfree/categories/misc.nix;
  forensics = forensicsStego ++ forensicsAnalysis;
in {
  # Desktop-oriented unfree packages (composed from categories)
  desktop = audio ++ editors ++ ai ++ browsers ++ forensics ++ misc;

  # Headless/server preset: no unfree packages allowed
  headless = [ ];
}
