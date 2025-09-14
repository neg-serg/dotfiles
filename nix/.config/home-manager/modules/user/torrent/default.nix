{
  pkgs,
  lib,
  config,
  ...
}:
with {
  transmission = pkgs.transmission_4;
}; let
  confDirNew = "${config.xdg.configHome}/transmission-daemon";
  confDirOld = "${config.xdg.configHome}/transmission";
  confDirBak = "${config.xdg.configHome}/transmission-daemon.bak";
in {
  # Ensure runtime subdirectories exist even if the config dir is a symlink
  # to an external location. This avoids "resume: No such file or directory"
  # on first start after activation.
  home.activation.ensureTransmissionDirs =
    config.lib.neg.mkEnsureDirsAfterWrite [
      "${confDirNew}/resume"
      "${confDirNew}/torrents"
      "${confDirNew}/blocklists"
      # Also ensure legacy path exists if the wrapper selects it
      "${confDirOld}/resume"
      "${confDirOld}/torrents"
      "${confDirOld}/blocklists"
    ];
  home.packages = with pkgs; config.lib.neg.pkgsList [
    transmission # provides transmission-remote for repair script
    bitmagnet # dht crawler
    pkgs.neg.bt_migrate # torrent migrator
    rustmission # new transmission client
  ];

  # One-shot copy: merge any .resume files from backup into main resume dir (no overwrite)
  home.activation.mergeTransmissionState = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -eu
    # Merge resumes from backup and legacy
    for src in "${confDirBak}/resume" "${confDirOld}/resume"; do
      dst="${confDirNew}/resume"
      if [ -d "$src" ] && [ -d "$dst" ]; then
        shopt -s nullglob
        for f in "$src"/*.resume; do
          base="$(basename "$f")"
          [ -e "$dst/$base" ] || cp -n "$f" "$dst/$base"
        done
        shopt -u nullglob
      fi
    done
    # Merge torrents from backup and legacy
    for src in "${confDirBak}/torrents" "${confDirOld}/torrents"; do
      dst="${confDirNew}/torrents"
      if [ -d "$src" ] && [ -d "$dst" ]; then
        shopt -s nullglob
        for f in "$src"/*.torrent; do
          base="$(basename "$f")"
          [ -e "$dst/$base" ] || cp -n "$f" "$dst/$base"
        done
        shopt -u nullglob
      fi
    done
  '';

  # Helper: add magnets for resumes missing matching .torrent; prefers config dir with resumes
  home.file.".local/bin/transmission-repair-magnets" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      c1="${confDirNew}"; c2="${confDirOld}"
      choose_dir() {
        if [ -d "$c1/resume" ] && compgen -G "$c1/resume/*.resume" >/dev/null 2>&1; then echo "$c1"; return; fi
        if [ -d "$c2/resume" ] && compgen -G "$c2/resume/*.resume" >/dev/null 2>&1; then echo "$c2"; return; fi
        echo "$c1"
      }
      gdir=$(choose_dir)
      resdir="$gdir/resume"; tordir="$gdir/torrents"
      echo "Using Transmission config dir: $gdir" 1>&2
      added=0; skipped=0
      shopt -s nullglob
      for f in "$resdir"/*.resume; do
        h="$(basename "$f" .resume)"
        if [ -e "$tordir/$h.torrent" ]; then
          ((skipped++))
          continue
        fi
        magnet="magnet:?xt=urn:btih:$h"
        echo "Adding magnet for $h" 1>&2
        "${transmission}/bin/transmission-remote" -a "$magnet" || {
          echo "Failed to add magnet for $h" 1>&2
          continue
        }
        ((added++))
      done
      shopt -u nullglob
      echo "Done. Added: $added, present: $skipped" 1>&2
    '';
  };

  # Wrapper selects existing config dir that contains resume files, preferring the new path
  home.file.".local/bin/transmission-daemon-wrapper" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      c1="${confDirNew}"
      c2="${confDirOld}"
      choose_dir() {
        if [ -d "$c1/resume" ] && compgen -G "$c1/resume/*.resume" >/dev/null 2>&1; then echo "$c1"; return; fi
        if [ -d "$c2/resume" ] && compgen -G "$c2/resume/*.resume" >/dev/null 2>&1; then echo "$c2"; return; fi
        if [ -d "$c1" ]; then echo "$c1"; return; fi
        if [ -d "$c2" ]; then echo "$c2"; return; fi
        echo "$c1"
      }
      gdir=$(choose_dir)
      exec "${transmission}/bin/transmission-daemon" -g "$gdir" -f --log-error
    '';
  };

  systemd.user.services.transmission-daemon = lib.recursiveUpdate {
    Unit = {
      Description = "transmission service";
      ConditionPathExists = "${transmission}/bin/transmission-daemon";
    };
    Service = {
      Type = "simple";
      ExecStart = "${config.home.homeDirectory}/.local/bin/transmission-daemon-wrapper";
      Restart = "on-failure";
      RestartSec = "30";
      StartLimitBurst = "8";
      ExecReload = "${pkgs.util-linux}/bin/kill -s HUP $MAINPID";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["net" "defaultWanted"];});
}
