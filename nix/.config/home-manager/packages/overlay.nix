_final: prev: let
  importOv = path: import path _final prev;
  functions = importOv ./overlays/functions.nix;
  tools = importOv ./overlays/tools.nix;
  media = importOv ./overlays/media.nix;
  dev = importOv ./overlays/dev.nix;
in
  # Merge all top-level overrides from overlays (functions/tools/media/dev), and also
  # provide a combined pkgs.neg namespace aggregating their custom packages and helpers.
  (functions // tools // media // dev) // {
    neg = (functions.neg or {}) // (tools.neg or {}) // (media.neg or {}) // (dev.neg or {});
  }
