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
    bitmagnet # dht crawler
    pkgs.neg.bt_migrate # torrent migrator
    rustmission # new transmission client
  ];

  # One-shot copy: merge any .resume files from backup into main resume dir (no overwrite)
  home.activation.mergeTransmissionResume = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -eu
    src="${confDirBak}/resume"
    dst="${confDirNew}/resume"
    if [ -d "$src" ] && [ -d "$dst" ]; then
      for f in "$src"/*.resume; do
        [ -e "$f" ] || continue
        base="$(basename "$f")"
        if [ ! -e "$dst/$base" ]; then
          cp -n "$f" "$dst/$base"
        fi
      done
    fi
  '';

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
