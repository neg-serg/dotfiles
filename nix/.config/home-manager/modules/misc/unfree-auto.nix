{ lib, config, ... }:
let
  audio = import ./unfree/categories/audio.nix;
  editors = import ./unfree/categories/editors.nix;
  browsers = import ./unfree/categories/browsers.nix;
  forensics = import ./unfree/categories/forensics.nix;
in {
  config = lib.mkMerge [
    # Audio: allow when audio apps or creation enabled
    (lib.mkIf (
      (config.features.media.audio.apps.enable or false)
      || (config.features.media.audio.creation.enable or false)
    ) {
      features.allowUnfree.extra = audio;
    })

    # Editors/AI tools: allow when dev stack enabled
    (lib.mkIf (config.features.dev.enable or false) {
      features.allowUnfree.extra = editors;
    })

    # Browser: allow Yandex when enabled
    (lib.mkIf (config.features.web.yandex.enable or false) {
      features.allowUnfree.extra = browsers;
    })

    # Forensics: allow when any forensics group is enabled (simple OR)
    (lib.mkIf (
      (config.features.dev.hack.forensics.fs or false)
      || (config.features.dev.hack.forensics.stego or false)
      || (config.features.dev.hack.forensics.analysis or false)
      || (config.features.dev.hack.forensics.network or false)
    ) {
      features.allowUnfree.extra = forensics;
    })
  ];
}

