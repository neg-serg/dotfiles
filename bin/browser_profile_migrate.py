#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Bidirectional Firefox <-> Floorp profile migration for Linux.

Key behavior changes (read this):
- DEFAULT: write INTO destination's existing *default* profile directory.
  *No new profile IDs are created unless you pass --new-profile.*
- Flat vs "Profiles/": auto-detected from destination profiles.ini (Floorp is flat).
- Case-preserving INI handling (canonical keys: Name, IsRelative, Path, Default).
- Robust read of legacy mixed/lower-case keys.
- Installs: installs.ini is updated; if missing, a minimal one is created so the browser opens the migrated profile.
- NEW: INI writer uses no spaces around '=' (key=value) + validation that enforces this.

Features
--------
- Migrate both ways with --from/--to (firefox|floorp).
- Honors IsRelative in profiles.ini (0/1) for PATH writes.
- Validates presence of key files (places.sqlite, logins.json, key4.db).
  * Default: warns if missing, continues.
  * With --strict: aborts if any are missing.
- Timestamped backup of destination profiles.ini and installs.ini (if exist).
- Process check with/without `pgrep` (refuse to run if source/dest app is running).
- Optional fast copy via rsync (--rsync, --rsync-args "...").
- Skips lock files; deletes compatibility.ini in destination (forces re-detection).
- Can create a brand-new destination profile with --new-profile (and set it default).

Usage examples
--------------
# Firefox -> Floorp (copy into Floorp's *existing default* profile; rsync fast copy)
./browser_profile_migrate.py --from firefox --to floorp --rsync

# Floorp -> Firefox (strict validation; overwrite existing default profile)
./browser_profile_migrate.py --from floorp --to firefox --strict

# Firefox -> Floorp (create a NEW dest profile and set it default)
./browser_profile_migrate.py --from firefox --to floorp --new-profile

# Force proceed if backups already exist, show rsync progress, custom args
./browser_profile_migrate.py --from firefox --to floorp --force --rsync --rsync-args "--info=progress2"

Notes
-----
- Linux-only.
- Destination default profile is detected from profiles.ini ([ProfileX] with Default=1).
- If destination has no profiles.ini, a fresh one is created with a single default profile.
- If installs.ini is absent, we create a minimal file with [General] Version=2 and a synthetic [InstallMigrated].
"""

from __future__ import annotations
import argparse
import configparser
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import Optional, Tuple

APP_DIRS = {
    "firefox": Path.home() / ".mozilla" / "firefox",
    "floorp":  Path.home() / ".floorp",
}

KEY_FILES = ["places.sqlite", "logins.json", "key4.db"]

def die(msg: str, code: int = 1) -> None:
    print(msg, file=sys.stderr)
    sys.exit(code)

def info(msg: str) -> None:
    print(msg)

def warn(msg: str) -> None:
    print(f"WARNING: {msg}")

def backup_file(p: Path) -> Optional[Path]:
    if not p.exists():
        return None
    ts = time.strftime("%Y%m%d-%H%M%S")
    backup = p.with_suffix(p.suffix + f".bak-{ts}")
    shutil.copy2(p, backup)
    return backup

def app_running(process_hint: str) -> bool:
    # Try pgrep; fall back to /proc scan
    try:
        res = subprocess.run(["pgrep", "-fl", process_hint], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, check=False, text=True)
        if res.returncode == 0 and res.stdout.strip():
            return True
    except FileNotFoundError:
        pass
    # Fallback (very rough)
    proc = Path("/proc")
    for pid_dir in proc.iterdir():
        if not pid_dir.name.isdigit():
            continue
        try:
            cmdline = (pid_dir / "cmdline").read_text(errors="ignore")
            if process_hint in cmdline:
                return True
        except Exception:
            pass
    return False

def new_config() -> configparser.ConfigParser:
    cfg = configparser.ConfigParser(interpolation=None)
    cfg.optionxform = str  # preserve case
    return cfg

def read_ini(path: Path) -> configparser.ConfigParser:
    cfg = new_config()
    if path.exists():
        with path.open("r", encoding="utf-8") as f:
            cfg.read_file(f)
    return cfg

def get_val(section: configparser.SectionProxy, key: str, default: Optional[str] = None) -> Optional[str]:
    # Tolerant getter: try canonical and common lowercase
    if key in section:
        return section[key]
    lk = key.lower()
    for k in section.keys():
        if k.lower() == lk:
            return section[k]
    return default

def ensure_general(cfg: configparser.ConfigParser) -> None:
    if "General" not in cfg:
        cfg["General"] = {}
    # Keep Version=2; StartWithLastProfile=1 for convenience
    if "Version" not in cfg["General"]:
        cfg["General"]["Version"] = "2"
    if "StartWithLastProfile" not in cfg["General"]:
        cfg["General"]["StartWithLastProfile"] = "1"

def list_profiles(cfg: configparser.ConfigParser) -> list[Tuple[str, configparser.SectionProxy]]:
    res = []
    for s in cfg.sections():
        if re.fullmatch(r"Profile\d+", s):
            res.append((s, cfg[s]))
    return res

def find_default_profile(cfg: configparser.ConfigParser) -> Optional[Tuple[str, configparser.SectionProxy]]:
    candidates = list_profiles(cfg)
    for name, sec in candidates:
        if get_val(sec, "Default", "0") == "1":
            return (name, sec)
    if len(candidates) == 1:
        return candidates[0]
    return None

def detect_flat_structure(dest_app: str, cfg: configparser.ConfigParser) -> bool:
    """
    True  => Path like 'i1c516zh.default'  (flat, Floorp-style)
    False => Path like 'Profiles/abcd.default' (Firefox-style)
    Detection: examine existing Default profile path if present; else use app heuristic.
    """
    d = find_default_profile(cfg)
    if d:
        _, sec = d
        path = get_val(sec, "Path", "")
        return "/" not in path
    return dest_app == "floorp"

def gen_profile_id() -> str:
    # 8 lowercase letters/digits + .default
    import random, string
    base = "".join(random.choice(string.ascii_lowercase + string.digits) for _ in range(8))
    return f"{base}.default"

def profiles_ini_path(app: str) -> Path:
    return APP_DIRS[app] / "profiles.ini"

def installs_ini_path(app: str) -> Path:
    return APP_DIRS[app] / "installs.ini"

def resolve_profile_root(app: str, flat: bool) -> Path:
    """Return the directory under app dir where profiles live."""
    root = APP_DIRS[app]
    return root if flat else (root / "Profiles")

def profile_dir_from_path_str(app_dir: Path, path_str: str, is_relative: bool) -> Path:
    if is_relative:
        return (app_dir / path_str).resolve()
    return Path(path_str).expanduser().resolve()

def pick_source_default_profile(app: str) -> Tuple[Path, str]:
    """Return (absolute profile dir, profile_id_string_used_in_Path)."""
    app_dir = APP_DIRS[app]
    p_ini = profiles_ini_path(app)
    if not p_ini.exists():
        die(f"{app} profiles.ini not found at {p_ini}")
    cfg = read_ini(p_ini)
    d = find_default_profile(cfg)
    if not d:
        die(f"Cannot find default profile in {p_ini}")
    name, sec = d
    path_str = get_val(sec, "Path", "")
    if not path_str:
        die(f"{p_ini}: section [{name}] has no Path")
    is_rel = get_val(sec, "IsRelative", "1") in ("1", "true", "True")
    prof_dir = profile_dir_from_path_str(app_dir, path_str, is_rel)
    return prof_dir, path_str

def pick_dest_profile(app: str, create_new: bool, desired_id: Optional[str]) -> Tuple[Path, str, bool, bool]:
    """
    Returns: (absolute_profile_dir, path_string_for_ini, flat_structure, created_new)
    - If create_new is False: use existing Default profile; create fresh ini if none exists.
    - If create_new is True: create new profile id (or use desired_id).
    """
    app_dir = APP_DIRS[app]
    p_ini = profiles_ini_path(app)
    cfg = read_ini(p_ini)
    ensure_general(cfg)

    flat = detect_flat_structure(app, cfg)
    root = resolve_profile_root(app, flat)
    root.mkdir(parents=True, exist_ok=True)

    created_new = False
    path_str = ""
    prof_dir: Path

    if not create_new:
        d = find_default_profile(cfg)
        if d:
            _, sec = d
            path_str = get_val(sec, "Path", "")
            if not path_str:
                die(f"{p_ini}: default profile has empty Path")
            is_rel = get_val(sec, "IsRelative", "1") in ("1", "true", "True")
            prof_dir = profile_dir_from_path_str(app_dir, path_str, is_rel)
            prof_dir.mkdir(parents=True, exist_ok=True)
            return prof_dir, path_str, flat, False
        else:
            create_new = True  # no profiles at all

    # Create new profile
    created_new = True
    prof_id = desired_id or gen_profile_id()
    if flat:
        path_str = prof_id
        prof_dir = app_dir / path_str
    else:
        path_str = f"Profiles/{prof_id}"
        prof_dir = app_dir / path_str
    prof_dir.mkdir(parents=True, exist_ok=True)
    return prof_dir, path_str, flat, created_new

# -------- INI write & validation (no spaces around '=') --------

def validate_no_spaces_around_equals(path: Path) -> None:
    """
    Enforces 'key=value' (no spaces around '=') for non-section, non-comment lines.
    Aborts if any violation is found.
    """
    if not path.exists():
        return
    bad_lines: list[tuple[int, str]] = []
    with path.open("r", encoding="utf-8") as f:
        for ln, line in enumerate(f, start=1):
            s = line.rstrip("\n")
            if not s or s.lstrip().startswith(("#", ";")):
                continue
            if s.lstrip().startswith("[") and s.rstrip().endswith("]"):
                continue
            if "=" not in s:
                continue
            # Find first '=' and inspect adjacent chars
            i = s.find("=")
            left = s[:i]
            right = s[i+1:]
            # Left side: last char must not be whitespace
            if left and left[-1].isspace():
                bad_lines.append((ln, line.rstrip("\n")))
                continue
            # Right side: first char must not be whitespace
            if right and right[0].isspace():
                bad_lines.append((ln, line.rstrip("\n")))
                continue
    if bad_lines:
        snippet = "\n".join(f"{ln}: {txt}" for ln, txt in bad_lines[:10])
        more = "" if len(bad_lines) <= 10 else f"\n... and {len(bad_lines)-10} more"
        die(f"{path} contains spaces around '=' which is not allowed:\n{snippet}{more}")

def write_ini_strict(cfg: configparser.ConfigParser, path: Path) -> None:
    """
    Writes INI with 'key=value' (no spaces) and immediately validates.
    """
    # Backup before write
    backup = backup_file(path)
    if backup:
        info(f"Backed up {path} -> {backup}")
    with path.open("w", encoding="utf-8") as f:
        # Critical: no spaces around '='
        cfg.write(f, space_around_delimiters=False)
    # Validate formatting
    validate_no_spaces_around_equals(path)

# ---------------------------------------------------------------

def update_profiles_ini(app: str, path_str: str, make_default: bool, create_if_missing: bool) -> None:
    p_ini = profiles_ini_path(app)
    cfg = read_ini(p_ini)
    ensure_general(cfg)

    # Find an existing section pointing to this path, otherwise create a new [ProfileN]
    target_sec_name = None
    existing = list_profiles(cfg)
    for name, sec in existing:
        if get_val(sec, "Path", "") == path_str:
            target_sec_name = name
            break

    if target_sec_name is None:
        used = sorted([int(s[7:]) for s, _ in existing]) if existing else []
        next_idx = (used[-1] + 1) if used else 0
        target_sec_name = f"Profile{next_idx}"
        cfg[target_sec_name] = {}

    sec = cfg[target_sec_name]
    sec["Name"] = "default"
    sec["IsRelative"] = "1"
    sec["Path"] = path_str
    if make_default:
        sec["Default"] = "1"
        # Reset Default=0 for others
        for name, other in existing:
            if name != target_sec_name and "Default" in other:
                other["Default"] = "0"

    write_ini_strict(cfg, p_ini)
    info(f"Updated {app} profiles.ini")

def update_or_create_installs_ini(app: str, profile_path_str: str) -> None:
    i_ini = installs_ini_path(app)
    cfg = read_ini(i_ini)

    install_secs = [s for s in cfg.sections() if s.startswith("Install")]
    if not install_secs:
        ensure_general(cfg)
        sec_name = "InstallMigrated"
        cfg[sec_name] = {}
        cfg[sec_name]["Default"] = profile_path_str
        cfg[sec_name]["Locked"] = "1"
    else:
        for s in install_secs:
            cfg[s]["Default"] = profile_path_str
            if "Locked" not in cfg[s]:
                cfg[s]["Locked"] = "1"

    if not i_ini.exists():
        info("installs.ini not found; it will be created.")

    write_ini_strict(cfg, i_ini)
    info(f"Updated {app} installs.ini")

def copy_profile(src: Path, dst: Path, use_rsync: bool, rsync_args: str) -> None:
    # Clean destination but keep directory itself
    for p in dst.iterdir():
        if p.is_dir():
            shutil.rmtree(p)
        else:
            p.unlink(missing_ok=True)

    # Exclude lock files and compatibility.ini from copy
    if use_rsync:
        rsync_bin = shutil.which("rsync") or "/run/current-system/sw/bin/rsync"
        cmd = [rsync_bin, "-a"]
        if rsync_args:
            cmd.extend(rsync_args.split())
        cmd += ["--exclude", "*.lock", "--exclude", "parent.lock", "--exclude", "lock", "--exclude", "compatibility.ini"]
        cmd += [str(src) + "/", str(dst)]
        info(f"(rsync) {' '.join(cmd)}")
        subprocess.run(cmd, check=True)
    else:
        for root, dirs, files in os.walk(src):
            rel = Path(root).relative_to(src)
            target_dir = (dst / rel)
            target_dir.mkdir(parents=True, exist_ok=True)
            for d in dirs:
                (target_dir / d).mkdir(exist_ok=True)
            for f in files:
                if f.endswith(".lock") or f in ("parent.lock", "lock", "compatibility.ini"):
                    continue
                shutil.copy2(Path(root) / f, target_dir / f)

    # Ensure compatibility.ini absent
    (dst / "compatibility.ini").unlink(missing_ok=True)

def validate_key_files(dir_: Path, strict: bool) -> None:
    missing = [k for k in KEY_FILES if not (dir_ / k).exists()]
    if missing:
        msg = f"Key files missing in {dir_}: {', '.join(missing)}"
        if strict:
            die(msg)
        else:
            warn(msg + " (continuing)")

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Bidirectional Firefox <-> Floorp profile migration (Linux).")
    p.add_argument("--from", dest="src_app", choices=("firefox", "floorp"), required=True)
    p.add_argument("--to",   dest="dst_app", choices=("firefox", "floorp"), required=True)
    p.add_argument("--strict", action="store_true", help="Abort if key files are missing in source.")
    p.add_argument("--force",  action="store_true", help="Proceed even if apps are running (NOT recommended).")
    p.add_argument("--rsync",  action="store_true", help="Use rsync for faster copying.")
    p.add_argument("--rsync-args", default="--info=progress2", help="Extra rsync args (default: --info=progress2).")
    p.add_argument("--new-profile", action="store_true", help="Create a NEW destination profile and set it default.")
    p.add_argument("--new-id", default=None, help="When --new-profile, use this exact profile id (e.g., abcd1234.default).")
    return p.parse_args()

def main() -> None:
    args = parse_args()
    src_app = args.src_app
    dst_app = args.dst_app
    if src_app == dst_app:
        die("Source and destination app must differ.")

    # Safety: refuse to run if apps are running (unless --force)
    if not args.force:
        if app_running(src_app):
            die(f"{src_app} seems to be running; close it or use --force.")
        if app_running(dst_app):
            die(f"{dst_app} seems to be running; close it or use --force.")

    # Locate source default profile
    src_dir, _src_path_str = pick_source_default_profile(src_app)
    validate_key_files(src_dir, args.strict)

    # Determine destination profile (existing default by default)
    dst_dir, dst_path_str, _flat, created_new = pick_dest_profile(dst_app, args.new_profile, args.new_id)

    info(f"Source ({src_app}) profile: {src_dir}")
    info(f"Destination ({dst_app}) profile: {dst_dir}")

    # Copy
    copy_profile(src_dir, dst_dir, args.rsync, args.rsync_args or "")

    # Update INIs (strict writer + formatting validation)
    update_profiles_ini(dst_app, dst_path_str, make_default=True, create_if_missing=True)
    update_or_create_installs_ini(dst_app, dst_path_str)

    info("Done.")
    if created_new:
        info("(A new destination profile was created and set as default.)")
    else:
        info("(Migrated into the existing default destination profile.)")

if __name__ == "__main__":
    main()
