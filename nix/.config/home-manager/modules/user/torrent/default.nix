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
  confDirArchive = "${config.home.homeDirectory}/src/1st_level/@archive/dotfiles_backup/misc/.config/transmission-daemon";
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
    # Merge resumes from backup, legacy, and user archive
    for src in "${confDirBak}/resume" "${confDirOld}/resume" "${confDirArchive}/resume"; do
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
    # Merge torrents from backup, legacy, and user archive
    for src in "${confDirBak}/torrents" "${confDirOld}/torrents" "${confDirArchive}/torrents"; do
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

  # Scanner: search roots and inspect resume/torrent contents (JSON or bencode)
  home.file.".local/bin/transmission-scan" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      import os, sys, json, hashlib
      from typing import Tuple, Any

      def bdecode(data: bytes, i: int = 0) -> Tuple[Any, int]:
        c = data[i:i+1]
        if not c:
          raise ValueError('unexpected end')
        if c == b'i':
          j = data.index(b'e', i+1)
          val = int(data[i+1:j])
          return val, j+1
        if c == b'l' or c == b'd':
          is_dict = c == b'd'
          i += 1
          lst = []
          while data[i:i+1] != b'e':
            v, i = bdecode(data, i)
            lst.append(v)
          i += 1
          if is_dict:
            it = iter(lst)
            return {k.decode('utf-8','replace') if isinstance(k, (bytes,bytearray)) else k: v for k, v in zip(it, it)}, i
          return lst, i
        # bytes: <len>:<data>
        if b'0' <= c <= b'9':
          j = data.index(b':', i)
          ln = int(data[i:j])
          j += 1
          s = data[j:j+ln]
          return s, j+ln
        raise ValueError('bad token')

      def load_resume(path: str):
        with open(path, 'rb') as f:
          raw = f.read()
        # JSON first (Transmission 4), else bencode fallback
        first = raw[:1]
        if first in (b'{', b'['):
          try:
            obj = json.loads(raw.decode('utf-8', 'replace'))
            return {'fmt':'json','raw':obj}
          except Exception:
            pass
        try:
          obj, _ = bdecode(raw, 0)
          return {'fmt':'bencode','raw':obj}
        except Exception:
          return {'fmt':'unknown','raw':None}

      def load_torrent(path: str):
        with open(path, 'rb') as f:
          raw = f.read()
        try:
          obj, _ = bdecode(raw, 0)
        except Exception:
          return {'fmt':'unknown','raw':None}
        # No attempt to compute infohash from info dict to avoid re-encoding
        return {'fmt':'bencode','raw':obj}

      def scan_root(root: str):
        resume_dir = os.path.join(root, 'resume')
        torrents_dir = os.path.join(root, 'torrents')
        resumes = {}
        torrents = {}
        if os.path.isdir(resume_dir):
          for fn in os.listdir(resume_dir):
            if not fn.endswith('.resume'): continue
            h = fn[:-7]
            meta = load_resume(os.path.join(resume_dir, fn))
            name = None; dest = None
            r = meta.get('raw')
            if isinstance(r, dict):
              # json resume (v4)
              name = r.get('name') or r.get('torrentName') or r.get('added-name')
              dest = r.get('downloadDir') or r.get('destination')
            elif isinstance(r, (list,)):
              # unlikely shape; ignore
              pass
            resumes[h] = {'file': fn, 'path': os.path.join(resume_dir, fn), 'name': name, 'dest': dest, 'fmt': meta['fmt']}
        if os.path.isdir(torrents_dir):
          for fn in os.listdir(torrents_dir):
            if not fn.endswith('.torrent'): continue
            h = fn[:-8]
            meta = load_torrent(os.path.join(torrents_dir, fn))
            name = None
            t = meta.get('raw')
            if isinstance(t, dict):
              info = t.get('info')
              if isinstance(info, dict):
                n = info.get('name')
                if isinstance(n, (bytes, bytearray)):
                  try: name = n.decode('utf-8')
                  except: name = n.decode('latin-1', 'replace')
                elif isinstance(n, str):
                  name = n
            torrents[h] = {'file': fn, 'path': os.path.join(torrents_dir, fn), 'name': name, 'fmt': meta['fmt']}
        return resumes, torrents

      def find_roots(argv):
        if argv:
          return [os.path.expanduser(a) for a in argv]
        roots = []
        home = os.environ.get('HOME','')
        cand = [
          os.path.join(home, '.config', 'transmission-daemon'),
          os.path.join(home, '.config', 'transmission-daemon.bak'),
          os.path.join(home, '.config', 'transmission'),
        ]
        for r in cand:
          if os.path.isdir(r): roots.append(r)
        # fallback: scan under HOME for pattern
        for r,dirs,files in os.walk(home):
          base = os.path.basename(r)
          if base in ('transmission','transmission-daemon'):
            roots.append(r)
        # de-dup preserving order
        seen=set(); out=[]
        for r in roots:
          if r not in seen: seen.add(r); out.append(r)
        return out

      def main():
        roots = find_roots(sys.argv[1:])
        if not roots:
          print('No candidate roots found', file=sys.stderr)
          return 1
        for root in roots:
          resumes, torrents = scan_root(root)
          print(f"Root: {root}")
          print(f"  resumes: {len(resumes)} | torrents: {len(torrents)}")
          missing_t = sorted([h for h in resumes.keys() if h not in torrents])
          missing_r = sorted([h for h in torrents.keys() if h not in resumes])
          if missing_t:
            print(f"  resumes without .torrent: {len(missing_t)}")
          if missing_r:
            print(f"  torrents without .resume: {len(missing_r)}")
          # show a few examples
          show = list(resumes.items())[:5]
          for h, info in show:
            nm = info.get('name') or '(unknown)'
            ds = info.get('dest') or '(no dest)'
            print(f"    {h[:12]}…  name={nm}  dest={ds}  fmt={info.get('fmt')}")
        return 0

      if __name__ == '__main__':
        sys.exit(main())
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
