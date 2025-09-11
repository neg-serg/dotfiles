_final: prev: {
  # Targeted fix: tigervnc build needs autoreconf during embedded xserver patching.
  tigervnc = prev.tigervnc.overrideAttrs (old: {
    nativeBuildInputs =
      (old.nativeBuildInputs or [])
      ++ [
        # Hook and required tools to ensure `autoreconf` exists in PATH
        prev.autoreconfHook
        prev.autoconf
        prev.automake
        prev.libtool
        prev.pkg-config
        prev.gettext
      ];
  });

  # Reserved for development/toolchain overlays
  neg = {};
}
