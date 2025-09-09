{
  lib,
  config,
  ...
}: let
  audio = import ./unfree/categories/audio.nix;
  editors = import ./unfree/categories/editors.nix;
  ai = import ./unfree/categories/ai-tools.nix;
  browsers = import ./unfree/categories/browsers.nix;
  forensicsStego = import ./unfree/categories/forensics-stego.nix;
  forensicsAnalysis = import ./unfree/categories/forensics-analysis.nix;
  iac = import ./unfree/categories/iac.nix;
in {
  config = lib.mkMerge [
    # Audio: allow when audio apps or creation enabled
    (lib.mkIf (
        (config.features.media.audio.apps.enable or false)
        || (config.features.media.audio.creation.enable or false)
      ) {
        features.allowUnfree.extra = audio;
      })

    # Editors: allow when dev stack enabled
    (lib.mkIf (config.features.dev.enable or false) {
      features.allowUnfree.extra = editors;
    })

    # AI tools: allow when features.dev.ai.enable
    (lib.mkIf (config.features.dev.ai.enable or false) {
      features.allowUnfree.extra = ai;
    })

    # Browser: allow Yandex when enabled
    (lib.mkIf (config.features.web.yandex.enable or false) {
      features.allowUnfree.extra = browsers;
    })

    # Forensics per-feature granularity
    (lib.mkIf (config.features.dev.hack.forensics.stego or false) {
      features.allowUnfree.extra = forensicsStego;
    })
    (lib.mkIf (config.features.dev.hack.forensics.analysis or false) {
      features.allowUnfree.extra = forensicsAnalysis;
    })

    # IaC: allow Terraform only when selected backend is Terraform
    (lib.mkIf (
        (config.features.dev.pkgs.iac or false)
        && ((config.features.dev.iac.backend or "terraform") == "terraform")
      ) {
      features.allowUnfree.extra = iac;
    })
  ];
}
