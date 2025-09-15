Overlay pattern and helpers

Overview
- Entry: packages/overlay.nix
  - Loads overlays from packages/overlays/{functions,tools,media,dev}.nix
  - Merges their attrsets and exposes a combined namespace under pkgs.neg.
- Structure is intentional and should be kept as:
  - functions.nix — shared helpers under pkgs.neg.functions
  - tools.nix — CLI/desktop helpers under pkgs.neg.*
  - media.nix — audio/video tools under pkgs.neg.*
  - dev.nix — development/toolchain tweaks and scoped overrides

Helpers (pkgs.neg.functions)
- withOverrideAttrs drv f
  - Shortcut for drv.overrideAttrs f.
- overridePyScope f
  - Shorthand for python3Packages.overrideScope f.
- overrideScopeFor name f
  - Generic overrideScope for a top‑level package set by name.
  - Returns an attrset you can merge into the overlay output.
  - Example: _final.neg.functions.overrideScopeFor "python3Packages" (self: super: { … })
- overrideRustCrates drv hash
  - Sets cargoHash/cargoSha256 for buildRustPackage derivations.
- overrideGoModule drv hash
  - Sets vendorHash for buildGoModule derivations.

Usage examples
1) Override a Python package (preferred generic form)
   # packages/overlays/dev.nix
   _final: prev: {
     # other overrides...
   } // (_final.neg.functions.overrideScopeFor "python3Packages" (self: super: {
     ncclient = super.ncclient.overrideAttrs (_: {
       src = prev.fetchFromGitHub {
         owner = "ncclient"; repo = "ncclient"; rev = "v0.7.0";
         hash = "sha256-…";
       };
     });
   }))

2) Override a Python package (explicit helper)
   python3Packages = _final.neg.functions.overridePyScope (self: super: {
     foo = super.foo.overrideAttrs (_: { /* … */ });
   });

3) Override a Rust crate vendor hash
   myTool = _final.neg.functions.overrideRustCrates prev.myTool "sha256-…";

4) Override a Go module vendor hash
   myGo = _final.neg.functions.overrideGoModule prev.myGo "sha256-…";

Conventions
- Keep domain‑specific packages in tools.nix / media.nix / dev.nix.
- Put only reusable helpers into functions.nix.
- When overriding scoped sets (e.g., python3Packages), prefer overrideScopeFor and merge its result with //.
- Expose custom packages under pkgs.neg to avoid name clashes with upstream.

Validation tips
- nix flake check -L (project root) to ensure overlays evaluate.
- nix repl or nix eval can be used to inspect pkgs.neg.* derivations.

