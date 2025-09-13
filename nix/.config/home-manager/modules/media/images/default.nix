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
  # Package selection kept simple: apply global exclude filter only.
in lib.mkMerge [
  {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    # metadata
    exiftool exiv2 mediainfo
    # editors
    gimp rawtherapee graphviz
    # optimizers
    jpegoptim optipng pngquant advancecomp scour
    # color
    pastel lutgen
    # qr
    qrencode zbar
    # viewers
    swayimg swayimg-first viu
  ];
  home.file.".local/bin/swayimg".source = "${swayimg-first}/bin/swayimg-first";
  home.file.".local/bin/sxivnc".text = ''
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v nsxiv >/dev/null 2>&1; then
      exec nsxiv -n -c "$@"
    elif command -v sxiv >/dev/null 2>&1; then
      exec sxiv -n -c "$@"
    elif command -v swayimg >/dev/null 2>&1; then
      exec swayimg "$@"
    else
      echo "sxivnc: no nsxiv/sxiv/swayimg in PATH" >&2
      exit 127
    fi
  '';

  # Guard: ensure we don't write through an unexpected symlink or file at ~/.local/bin/swayimg
  # Collapse to a single step that removes any pre-existing file/dir/symlink.
  # Prepared via global prepareUserPaths action

  # Live-editable Swayimg config via helper (guards parent dir and target)
  }
  (xdg.mkXdgSource "swayimg" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/media/images/swayimg/conf" true))
]
