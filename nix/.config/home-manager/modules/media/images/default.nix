{
  lib,
  config,
  pkgs,
  ...
}: let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
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
in {
  home.packages = config.lib.neg.filterByExclude (config.lib.neg.mkEnabledList flags groups);
  home.file.".local/bin/swayimg".source = "${swayimg-first}/bin/swayimg-first";

  # Guard: ensure we don't write through an unexpected symlink or file at ~/.local/bin/swayimg
  home.activation.fixSwayimgBinSymlink =
    config.lib.neg.mkRemoveIfSymlink "${config.home.homeDirectory}/.local/bin/swayimg";
  home.activation.fixSwayimgBinFile =
    config.lib.neg.mkEnsureAbsent "${config.home.homeDirectory}/.local/bin/swayimg";

  # Live-editable Swayimg config via helper (guards parent dir and target)
  # Keep bin guards above since that’s outside XDG
  # xdg.configFile for directory link
  # Importantly, use repo-relative path so it stays editable
  # and guard parent dir (swayimg)
  #
  # NOTE: use mkDotfilesSymlink with recursive to preserve directory
  # structure from repo under ~/.config/swayimg
  #
  # Equivalent to the prior xdg.configFile but with safe guards
  # implemented in the helper.
  #
  # We still keep the .local/bin adjustments as separate activation steps above.
  #
  # Apply helper:
  #   (xdg.mkXdgSource "swayimg" (config.lib.neg.mkDotfilesSymlink ... true))
  
  # Merge helper output
  # (we’re inside a single attrset here; append using recursiveUpdate style via //)
  # But simpler: directly include attribute produced by helper using lib.mkMerge outside.
} // (xdg.mkXdgSource "swayimg" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/media/images/swayimg/conf" true))
