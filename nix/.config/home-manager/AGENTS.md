# Agent Guide (Home Manager repo)

This repo is configured for Home Manager + flakes with a small set of helpers to keep modules consistent and activation quiet. This page shows what to use and how to validate changes.

## Helpers & Conventions

- Locations
  - Core helpers: `modules/lib/neg.nix`
  - XDG file helpers: `modules/lib/xdg-helpers.nix`
  - Features/options: `modules/features.nix`
- XDG helpers (preferred)
  - Config text/link: `xdg.mkXdgText`, `xdg.mkXdgSource`
  - Data text/link: `xdg.mkXdgDataText`, `xdg.mkXdgDataSource`
  - Cache text/link: `xdg.mkXdgCacheText`, `xdg.mkXdgCacheSource`
  - Use these instead of ad‑hoc shell to avoid symlink/dir conflicts at activation.
- Activation helpers (from `lib.neg`)
  - `mkEnsureRealDir path` / `mkEnsureRealDirsMany [..]` — ensure real dirs before linkGeneration
  - `mkEnsureAbsent path` / `mkEnsureAbsentMany [..]` — remove conflicting files/dirs pre‑link
  - `mkEnsureDirsAfterWrite [..]` — create runtime dirs after writeBoundary
  - `mkEnsureMaildirs base [boxes..]` — create Maildir trees after writeBoundary
  - Aggregated XDG fixups (new helpers):
    - `mkXdgFixParents { configs = attrNames config.xdg.configFile; datas = attrNames config.xdg.dataFile; caches = attrNames config.xdg.cacheFile; preserveConfigPatterns = [ "transmission-daemon/*" ]; }`
    - `mkXdgFixTargets { configs = …; datas = …; caches = …; }`
    - These are wired in `modules/user/xdg/default.nix` as `home.activation.xdgFixParents` and `home.activation.xdgFixTargets`.
  - Common user paths prepared via:
    - `ensureCommonDirs`, `cleanSwayimgWrapper`, `ensureGmailMaildirs`
- systemd (user) presets
  - Always use `config.lib.neg.systemdUser.mkUnitFromPresets { presets = [..]; }`
  - Typical presets:
    - Service in GUI session: `["graphical"]`
    - Wants network online: `["netOnline"]`
    - General user service: `["defaultWanted"]`
    - Timer: `["timers"]`
    - DBus socket ordering: `["dbusSocket"]`
  - Add extras only when needed: `after`, `wants`, `partOf`, `wantedBy`.

## Hyprland notes

- Autoreload is disabled to avoid inotify races during activation (`disable_autoreload = 1`).
- No activation‑time `hyprctl reload`; keep manual reload only (hotkey in `bindings.conf`).
- hy3/Hyprland pins have a compatibility assert in `features.nix`; update the matrix if bumping pins.

## Commit Messages

- Format: `[scope] subject` (English, imperative).
  - Examples: `[activation] reduce noise`, `[features] add flag`, `[gui/hypr] normalize rules`.
  - Multi‑scope allowed: `[xdg][activation] ...`
  - Allowed exceptions: `Merge ...`, `Revert ...`, `fixup!`, `squash!`, `WIP`.
- Keep changes focused and minimal; avoid drive‑by fixes unless requested.

## Quick Tasks

- Format: `just fmt` (wrapper around `nix fmt`)
- Checks: `just check` (flake checks, docs build)
- Lint only: `just lint` (statix, deadnix, shellcheck, ruff/black if present)
- Switch HM: `just hm-neg` (or `just hm-lite`)

## Guard rails

- Don’t reintroduce Hyprland auto‑reload or activation reload hooks.
- For files under `~/.config` prefer XDG helpers + `mkDotfilesSymlink` instead of manual shell.
- Use feature flags (`features.*`) with `mkIf`; parent flag off implies children default to off.
- Quickshell: `quickshell/.config/quickshell/Settings.json` is ignored; do not add it back.

## Validation

- Local eval: `nix flake check -L` (may build small docs/checks)
- Fast feature view (no build): build `checks.x86_64-linux.hm-eval-neg-retro-off` and inspect JSON
- HM switch (live): `home-manager switch --flake .#neg`

## When updating hy3/Hyprland

- Update pins in `flake.nix` and extend the matrix in `modules/features.nix`:
  - Add `{ hv = "<hyprland version>"; rev = "<hy3 commit>"; }` to `compatible`.
  - Keep Hyprland and hy3 in lock‑step to avoid API breaks.
