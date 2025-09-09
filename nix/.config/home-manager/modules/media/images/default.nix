{ pkgs, lib, config, ... }: let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoSwayimgConf = "${config.lib.neg.dotfilesRoot}/nix/.config/home-manager/modules/media/images/swayimg/conf";
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
in {
  home.packages = with pkgs; [
    advancecomp # AdvanceCOMP PNG Compression Utility
    exiftool # extract media metadata
    exiv2 # metadata manipulation
    gimp # image editor
    graphviz # graphics
    jpegoptim # jpeg optimization
    lutgen # fast lut generator
    mediainfo # another tool to extract media info
    optipng # optimize png
    pastel # cli color analyze/convert/manipulation
    pngquant # convert png from RGBA to 8 bit with alpha-channel
    qrencode # qr encoding
    rawtherapee # raw format support
    scour # svg optimizer
    swayimg # image viewer (Wayland)
    swayimg-first # image viewer for Wayland display servers (start from the first file in list)
    viu # console image viewer
    zbar # bar code reader
  ];
  home.file.".local/bin/swayimg".source = "${swayimg-first}/bin/swayimg-first";

  # Live-editable Swayimg config: out-of-store symlink to repo copy
  # Remove stale symlink to old HM generations before linking
  home.activation.fixSwayimgConfig =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      SDIR="${config.xdg.configHome}/swayimg"
      if [ -L "$SDIR" ]; then
        rm -f "$SDIR"
      fi
    '';
  xdg.configFile."swayimg" = {
    source = l repoSwayimgConf;
    recursive = true;
  };
}
