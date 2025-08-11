{ pkgs, ... }:
let
  nsxiv-neg = pkgs.callPackage ../../../packages/nsxiv {};
  # Wrapper that starts swayimg and jumps to the first image via IPC.
  swayimg-first = pkgs.writeShellScriptBin "swayimg-first" ''
    set -euo pipefail
    # Unique socket path for this instance
    uid="$(id -u)"
    rt="$XDG_RUNTIME_DIR"; [ -n "$rt" ] || rt="/run/user/$uid"
    sock="$rt/swayimg-$PPID-$$-$RANDOM.sock"
    # Start swayimg with IPC enabled
    "${pkgs.swayimg}/bin/swayimg" --ipc="$sock" "$@" &
    pid=$!
    # Wait until the socket appears or process exits (max ~3s)
    i=0
    while :; do
      if ! kill -0 "$pid" 2>/dev/null; then break; fi
      [ -S "$sock" ] && break
      i=$((i+1))
      [ "$i" -ge 120 ] && break
      sleep 0.025
    done
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

    # Forward exit code
    wait "$pid"
    rc=$?
    # Best-effort cleanup
    [ -S "$sock" ] && rm -f "$sock" || true
    exit $rc
  '';
in
{
  home.packages = with pkgs; [
    advancecomp # AdvanceCOMP PNG Compression Utility
    exiftool # extract media metadata
    exiv2 # metadata manipulation
    gimp # image editor
    graphviz # graphics
    jpegoptim # jpeg optimization
    lutgen # fast lut generator
    mediainfo # another tool to extract media info
    nsxiv-neg # my favorite image viewer
    optipng # optimize png
    pastel # cli color analyze/convert/manipulation
    pngquant # convert png from RGBA to 8 bit with alpha-channel
    qrencode # qr encoding
    rawtherapee # raw format support
    scour # svg optimizer
    swayimg-first # image viewer for Wayland display servers (start from the first file in list)
    viu # console image viewer
    zbar # bar code reader
  ];
  home.file.".local/bin/swayimg".source = "${swayimg-first}/bin/swayimg-first";
}
