_final: prev: let
  importOv = path: import path _final prev;
  tools = importOv ./overlays/tools.nix;
  media = importOv ./overlays/media.nix;
  dev = importOv ./overlays/dev.nix;
in
  # Merge all top-level overrides from overlays (tools/media/dev), and also
  # provide a combined pkgs.neg namespace aggregating their custom packages.
  (tools // media // dev) // {
    neg = (tools.neg or {}) // (media.neg or {}) // (dev.neg or {});
  }
