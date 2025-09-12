{
  lib,
  config,
  pkgs,
  ...
}: let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
  # Wrapper: start swayimg, export SWAYIMG_IPC, jump to first image via IPC.
  swayimg-first = pkgs.writeShellScriptBin "swayimg-first" ''
    set -euo pipefail
    uid="$(id -u)" # Unique socket path for this instance
    rt="$XDG_RUNTIME_DIR"; [ -n "$rt" ] || rt="/run/user/$uid"
    sock="$rt/swayimg-$PPID-$$-$RANDOM.sock"
    # Export socket path for child exec actions to use
    export SWAYIMG_IPC="$sock"
    # Start swayimg with IPC enabled
    "${pkgs.swayimg}/bin/swayimg" --ipc="$sock" "$@" &
    pid=$!
    i=0
    while :; do
      if ! kill -0 "$pid" 2>/dev/null; then break; fi
      [ -S "$sock" ] && break
      i=$((i+1))
      [ "$i" -ge 40 ] && break
      sleep 0.025
    done # Wait until the socket appears or process exits (max ~1s)
    # Send on-start action(s) if socket is ready
    if [ -S "$sock" ]; then
      action="$(printenv SWAYIMG_ONSTART_ACTION 2>/dev/null || true)"
      [ -n "$action" ] || action="first_file"
      # Send each action on its own line; keep spaces intact
      printf '%s' "$action" \
          | tr ';' '\n' \
          | sed '/^[[:space:]]*$/d' \
          | "${pkgs.socat}/bin/socat" - "UNIX-CONNECT:$sock" >/dev/null 2>&1 || true
    fi
    wait "$pid" # Forward exit code
    rc=$?
    [ -S "$sock" ] && rm -f "$sock" || true # Best-effort cleanup
    exit $rc
  '';
in let
  groups = with pkgs; {
    metadata = [
      exiftool # extract media metadata
      exiv2 # metadata manipulation
      mediainfo # extract media info
    ];
    editors = [
      gimp # image editor
      rawtherapee # RAW editor
      graphviz # graph visualization
    ];
    optimizers = [
      jpegoptim # jpeg optimization
      optipng # optimize png
      pngquant # downsample RGBA to 8-bit with alpha
      advancecomp # ADVANCE COMP PNG compression utility
      scour # svg optimizer
    ];
    color = [
      pastel # CLI color manipulation
      lutgen # fast LUT generator
    ];
    qr = [
      qrencode # qr encoding
      zbar # qr/barcode reader
    ];
    viewers = [
      swayimg # image viewer (Wayland)
      swayimg-first # wrapper: start from the first file
      viu # console image viewer
    ];
  };
  flags = builtins.listToAttrs (map (n: {
    name = n;
    value = true;
  }) (builtins.attrNames groups));
in lib.mkMerge [
  {
  home.packages = config.lib.neg.filterByExclude (config.lib.neg.mkEnabledList flags groups);
  home.file.".local/bin/swayimg".source = "${swayimg-first}/bin/swayimg-first";

  # Guard: ensure we don't write through an unexpected symlink or file at ~/.local/bin/swayimg
  # Collapse to a single step that removes any pre-existing file/dir/symlink.
  home.activation.prepareUserPaths = lib.hm.dag.entryBefore ["linkGeneration"] ''
    set -eu
    tgt="${config.home.homeDirectory}/.local/bin/swayimg"
    if [ -e "$tgt" ] || [ -L "$tgt" ]; then
      rm -rf "$tgt"
    fi
  '';

  # Live-editable Swayimg config via helper (guards parent dir and target)
  }
  (xdg.mkXdgSource "swayimg" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/media/images/swayimg/conf" true))
]
