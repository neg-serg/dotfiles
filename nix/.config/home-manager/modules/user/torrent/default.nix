{
  pkgs,
  lib,
  config,
  ...
}:
with {
  transmission = pkgs.transmission_4;
}; let
  # Shared Python helpers for Transmission tools
  translib = pkgs.writeTextDir "translib/__init__.py" ''
    import os, json, hashlib

    def bdecode(data: bytes, i: int = 0):
        c = data[i:i+1]
        if not c:
            raise ValueError('eof')
        if c == b'i':
            j = data.index(b'e', i+1)
            return int(data[i+1:j]), j+1
        if c in (b'l', b'd'):
            isd = c == b'd'; i += 1; lst = []
            while data[i:i+1] != b'e':
                v, i = bdecode(data, i); lst.append(v)
            i += 1
            if isd:
                it = iter(lst)
                return {k: v for k, v in zip(it, it)}, i
            return lst, i
        if b'0' <= c <= b'9':
            j = data.index(b':', i)
            ln = int(data[i:j]); j += 1
            return data[j:j+ln], j+ln
        raise ValueError('bad')

    def bencode(x):
        if isinstance(x, int): return b'i%de' % x
        if isinstance(x, (bytes, bytearray)): return str(len(x)).encode()+b':'+bytes(x)
        if isinstance(x, str):
            xb = x.encode('utf-8'); return str(len(xb)).encode()+b':'+xb
        if isinstance(x, list): return b'l'+b"".join(bencode(v) for v in x)+b'e'
        if isinstance(x, dict):
            items = sorted(((k if isinstance(k,(bytes,bytearray)) else (k.encode('utf-8') if isinstance(k,str) else None), v) for k,v in x.items()), key=lambda kv: kv[0])
            return b'd'+b"".join(bencode(k)+bencode(v) for k,v in items)+b'e'
        raise TypeError

    def _decode_bytes(x):
        if isinstance(x, (bytes, bytearray)):
            try: return x.decode('utf-8')
            except Exception: return x.decode('latin-1','replace')
        if isinstance(x, dict):
            return { _decode_bytes(k): _decode_bytes(v) for k,v in x.items() }
        if isinstance(x, list):
            return [ _decode_bytes(v) for v in x ]
        return x

    def load_resume(path: str):
        raw = open(path, 'rb').read()
        fmt = 'unknown'; obj = None
        if raw[:1] in (b'{', b'['):
            try:
                obj = json.loads(raw.decode('utf-8', 'replace'))
                fmt = 'json'
            except Exception:
                obj = None
        if obj is None:
            try:
                obj, _ = bdecode(raw, 0)
                obj = _decode_bytes(obj)
                fmt = 'bencode'
            except Exception:
                obj = None; fmt = 'unknown'
        name = None; dest = None
        if isinstance(obj, dict):
            name = obj.get('name') or obj.get('torrentName') or obj.get('added-name')
            dest = obj.get('downloadDir') or obj.get('destination')
        return {'fmt': fmt, 'raw': obj, 'name': name, 'dest': dest}

    def load_torrent(path: str):
        raw = open(path, 'rb').read()
        try:
            obj, _ = bdecode(raw, 0)
        except Exception:
            return {'fmt': 'unknown', 'raw': None, 'infohash': None, 'name': None}
        info = None
        if isinstance(obj, dict):
            info = obj.get(b'info') or obj.get('info')
        ih = None
        if info is not None:
            try:
                ih = hashlib.sha1(bencode(info)).hexdigest()
            except Exception:
                ih = None
        name = None
        infod = obj.get(b'info') if isinstance(obj, dict) else None
        if isinstance(infod, dict):
            n = infod.get(b'name')
            if isinstance(n,(bytes,bytearray)):
                try: name = n.decode('utf-8')
                except: name = n.decode('latin-1','replace')
        return {'fmt':'bencode','raw': obj, 'infohash': ih, 'name': name}

    def infohash_from_file(path: str):
        raw = open(path,'rb').read()
        obj,_ = bdecode(raw,0)
        info = None
        if isinstance(obj, dict): info = obj.get(b'info') or obj.get('info')
        if info is None: return None
        return hashlib.sha1(bencode(info)).hexdigest()

    def choose_conf():
        env = os.environ.get('TRANSMISSION_DIR')
        if env and os.path.isdir(os.path.expanduser(env)):
            return os.path.expanduser(env)
        home=os.environ.get('HOME', "")
        for p in (
            os.path.join(home,'.config','transmission-daemon'),
            os.path.join(home,'.config','transmission'),
        ):
            if os.path.isdir(p): return p
        return os.path.join(home,'.config','transmission-daemon')

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
                resumes[h] = {'file': fn, 'path': os.path.join(resume_dir, fn), 'name': meta.get('name'), 'dest': meta.get('dest'), 'fmt': meta.get('fmt')}
        if os.path.isdir(torrents_dir):
            for fn in os.listdir(torrents_dir):
                if not fn.endswith('.torrent'): continue
                h = fn[:-8]
                meta = load_torrent(os.path.join(torrents_dir, fn))
                ih = meta.get('infohash')
                if not ih:
                    base = os.path.splitext(fn)[0]
                    if len(base) in (40, 32) and all(c in '0123456789abcdef' for c in base.lower()):
                        ih = base.lower()
                torrents[ih or h] = {'file': fn, 'path': os.path.join(torrents_dir, fn), 'name': meta.get('name'), 'fmt': meta.get('fmt')}
        return resumes, torrents

    def find_roots(argv):
        if argv:
            return [os.path.expanduser(a) for a in argv]
        roots = []
        home = os.environ.get('HOME', "")
        cand = [
            os.path.join(home, '.config', 'transmission-daemon'),
            os.path.join(home, '.config', 'transmission-daemon.bak'),
            os.path.join(home, '.config', 'transmission'),
        ]
        for r in cand:
            if os.path.isdir(r): roots.append(r)
        for r,dirs,files in os.walk(home):
            base = os.path.basename(r)
            if base in ('transmission','transmission-daemon'):
                roots.append(r)
        seen=set(); out=[]
        for r in roots:
            if r not in seen: seen.add(r); out.append(r)
        return out
  '';
  confDirNew = "${config.xdg.configHome}/transmission-daemon";
  confDirOld = "${config.xdg.configHome}/transmission";
  confDirBak = "${config.xdg.configHome}/transmission-daemon.bak";
  transRepair = pkgs.writeShellApplication {
    name = "transmission-repair-magnets";
    runtimeInputs = [ transmission pkgs.coreutils pkgs.findutils ];
    text = ''
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
        transmission-remote -a "$magnet" || {
          echo "Failed to add magnet for $h" 1>&2
          continue
        }
        ((added++))
      done
      shopt -u nullglob
      echo "Done. Added: $added, present: $skipped" 1>&2
    '';
  };
  transScan = pkgs.writeShellApplication {
    name = "transmission-scan";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      set -euo pipefail
      export PYTHONPATH="${translib}:$PYTHONPATH"
      exec python3 - <<'PY'
      import sys
      import translib as tl
      
      def main():
          roots = tl.find_roots(sys.argv[1:])
          if not roots:
              print('No candidate roots found', file=sys.stderr)
              return 1
          for root in roots:
              resumes, torrents = tl.scan_root(root)
              print(f"Root: {root}")
              print(f"  resumes: {len(resumes)} | torrents: {len(torrents)}")
              missing_t = sorted([h for h in resumes.keys() if h not in torrents])
              missing_r = sorted([h for h in torrents.keys() if h not in resumes])
              if missing_t:
                  print(f"  resumes without .torrent: {len(missing_t)}")
              if missing_r:
                  print(f"  torrents without .resume: {len(missing_r)}")
              show = list(resumes.items())[:5]
              for h, info in show:
                  nm = info.get('name') or '(unknown)'
                  ds = info.get('dest') or '(no dest)'
                  print(f"    {h[:12]}…  name={nm}  dest={ds}  fmt={info.get('fmt')}")
          return 0
      
      if __name__ == '__main__':
          sys.exit(main())
      PY
    '';
  };
  transIndex = pkgs.writeShellApplication {
    name = "transmission-index-torrents";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      set -euo pipefail
      export PYTHONPATH="${translib}:$PYTHONPATH"
      exec python3 - <<'PY'
      import os, sys, shutil
      import translib as tl
      
      def main():
          conf = tl.choose_conf()
          resdir = os.path.join(conf,'resume'); tordir = os.path.join(conf,'torrents')
          os.makedirs(tordir, exist_ok=True)
          resumes = set()
          if os.path.isdir(resdir):
              for fn in os.listdir(resdir):
                  if fn.endswith('.resume'):
                      resumes.add(fn[:-7])
          have_t = set()
          if os.path.isdir(tordir):
              for fn in os.listdir(tordir):
                  if fn.endswith('.torrent'):
                      have_t.add(fn[:-8])
          need = sorted([h for h in resumes if h not in have_t])
          if not need:
              print('No missing .torrent files for existing resumes')
              return 0
          roots = [os.path.expanduser(a) for a in sys.argv[1:]] or [os.environ.get('HOME','.')]
          index = {}
          for r in roots:
              for root, dirs, files in os.walk(r):
                  if os.path.abspath(root).startswith(os.path.abspath(conf)):
                      continue
                  for f in files:
                      if not f.endswith('.torrent'): continue
                      p = os.path.join(root,f)
                      try:
                          ih = tl.infohash_from_file(p)
                       except Exception:
                          continue
                      if ih and ih not in index:
                          index[ih] = p
          added = 0; missing = 0
          for h in need:
              src = index.get(h)
              if not src:
                  missing += 1
                  continue
              dst = os.path.join(tordir, f"{h}.torrent")
              if not os.path.exists(dst):
                  shutil.copy2(src, dst)
                  added += 1
          print(f"Added {added} .torrent files; {missing} still missing")
          return 0
      if __name__=='__main__':
          raise SystemExit(main())
      PY
    '';
  };
  transPrune = pkgs.writeShellApplication {
    name = "transmission-prune-missing";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      set -euo pipefail
      export PYTHONPATH="${translib}:$PYTHONPATH"
      exec python3 - <<'PY'
      import os, sys, time, shutil
      import translib as tl
      def bdecode(data: bytes, i: int = 0):
          c = data[i:i+1]
          if not c: raise ValueError('eof')
          if c == b'i':
              j = data.index(b'e', i+1)
              return int(data[i+1:j]), j+1
          if c in (b'l', b'd'):
              isd = c == b'd'; i += 1; lst = []
              while data[i:i+1] != b'e':
                  v, i = bdecode(data, i); lst.append(v)
              i += 1
              if isd:
                  it = iter(lst)
                  return {k: v for k,v in zip(it, it)}, i
              return lst, i
          if b'0' <= c <= b'9':
              j = data.index(b':', i)
              ln = int(data[i:j]); j += 1
              return data[j:j+ln], j+ln
          raise ValueError('bad')
      def main():
          commit = '--commit' in sys.argv
          conf = tl.choose_conf()
          resdir = os.path.join(conf,'resume'); tordir = os.path.join(conf,'torrents')
          ts = time.strftime('%Y%m%d-%H%M%S')
          backup = os.path.join(conf, f'pruned-{ts}')
          os.makedirs(backup, exist_ok=True)
          removed=0; kept=0
          for fn in os.listdir(resdir):
              if not fn.endswith('.resume'): continue
              h = fn[:-7]
              meta = tl.load_resume(os.path.join(resdir,fn))
              name = meta.get('name')
              dest = meta.get('dest')
              top = None
              if name and dest:
                  top = os.path.join(dest, name)
              elif dest:
                  top = dest
              present = bool(top and os.path.exists(top))
              if present:
                  kept += 1
                  continue
              src_r = os.path.join(resdir, fn)
              src_t = os.path.join(tordir, f'{h}.torrent')
              if commit:
                  os.makedirs(os.path.join(backup, 'resume'), exist_ok=True)
                  os.makedirs(os.path.join(backup, 'torrents'), exist_ok=True)
                  shutil.move(src_r, os.path.join(backup,'resume', fn))
                  if os.path.exists(src_t):
                      shutil.move(src_t, os.path.join(backup,'torrents', f'{h}.torrent'))
              removed += 1
              print(f"pruned {h[:12]}… name={name} dest={dest}")
          print(f"Kept: {kept}; Pruned: {removed}; Commit: {commit}")
          return 0
      if __name__=='__main__':
          raise SystemExit(main())
      PY
    '';
  };
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
  # Group torrent tools and scripts; flatten via mkEnabledList
  home.packages = with pkgs;
    config.lib.neg.pkgsList (
      let
        groups = {
          core = [
            transmission # provides transmission-remote for repair script
            bitmagnet # dht crawler
            pkgs.neg.bt_migrate # torrent migrator
            rustmission # new transmission client
          ];
          scripts = [ transRepair transScan transIndex transPrune ];
        };
        flags = { core = true; scripts = true; };
      in config.lib.neg.mkEnabledList flags groups
    );

  # One-shot copy: merge any .resume files from backup into main resume dir (no overwrite)
  home.activation.mergeTransmissionState = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -eu
    # Merge resumes from backup and legacy only (archive disabled to avoid stale restore)
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
    # Merge torrents from backup and legacy only
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

  # transmission-repair-magnets moved to writeShellApplication (in home.packages)

  # Audit existing data on disk and suggest a selective restore
  home.file.".local/bin/transmission-audit-data" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      import os, sys
      sys.path.insert(0, "${translib}")
      import translib as tl

      def main():
        conf = tl.choose_conf()
        resdir = os.path.join(conf,'resume')
        tordir = os.path.join(conf,'torrents')
        print(f'Config: {conf}')
        R={}; T={}
        if os.path.isdir(resdir):
          for fn in os.listdir(resdir):
            if not fn.endswith('.resume'): continue
            h=fn[:-7]
            r=tl.load_resume(os.path.join(resdir,fn))
            name = r.get('name')
            dest = r.get('dest')
            R[h]={'name':name,'dest':dest}
        if os.path.isdir(tordir):
          for fn in os.listdir(tordir):
            if not fn.endswith('.torrent'): continue
            meta=tl.load_torrent(os.path.join(tordir,fn))
            ih = meta.get('infohash')
            key = ih or os.path.splitext(fn)[0]
            T[key]={'name': meta.get('name'), 'file': fn}
        missing=[]; ok=[]
        for h,info in R.items():
          dest=info.get('dest')
          nm=info.get('name')
          if not dest:
            missing.append((h, 'no-dest', nm, dest)); continue
          top=None
          if h in T and T[h].get('name'):
            top = os.path.join(dest, T[h]['name'])
          elif nm:
            top = os.path.join(dest, nm)
          else:
            top = dest
          present = os.path.exists(top)
          (ok if present else missing).append((h, 'ok' if present else 'missing', nm, dest))
        print(f'Present on disk: {sum(1 for _,s,_,_ in ok if s=="ok")}')
        print(f'Missing on disk: {len(missing)}')
        if missing:
          for h,reason,nm,dest in missing[:20]:
            print(f'  miss {h[:12]}… name={nm} dest={dest} reason={reason}')
        return 0
      if __name__=='__main__':
        raise SystemExit(main())
    '';
  };
  # transmission-scan moved to writeShellApplication (in home.packages)

  # Indexer: scan given roots for .torrent files, compute infohash, and
  # copy into the config torrents dir for resumes missing a .torrent.
  # transmission-index-torrents moved to writeShellApplication (in home.packages)

  # transmission-prune-missing moved to writeShellApplication (in home.packages)

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
      exec "${transmission}/bin/transmission-daemon" -g "$gdir" -f --log-level=error
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
