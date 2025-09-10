_final: prev: let
  importOv = path: import path _final prev;
  tools = importOv ./overlays/tools.nix;
  media = importOv ./overlays/media.nix;
  dev = importOv ./overlays/dev.nix;
in {
  neg = (tools.neg or {}) // (media.neg or {}) // (dev.neg or {});
}
