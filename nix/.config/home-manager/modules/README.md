# Modules Overview

This directory contains Home Manager modules grouped by domain. Feature flags live in `features.nix` and gate most imports/config via `config.features.*`.

- Top-level files
  - `default.nix` — aggregates subdirectories into the HM module tree.
  - `features.nix` — declares `features.*` options and profile defaults (full/lite).
  - `lib/neg.nix` — project helpers (`mkBool`, `mkEnabledList`, `mkDotfilesSymlink`, `systemdUser.*`, etc.).

- Subdirectories (map)
  - `cli/` — command‑line tools, shells, and per‑program configs (fzf, tmux, zsh, direnv, etc.).
  - `db/` — database clients and related tooling.
  - `dev/` — development stacks, language toolchains, cachix, and security/hacking helpers.
  - `distros/` — distribution‑specific adjustments and compatibility shims.
  - `flatpak/` — Flatpak configuration and overrides.
  - `hardware/` — hardware‑adjacent configuration and services.
  - `lib/` — shared library helpers for modules (no direct user options).
  - `main/` — core/desktop setup glue and high‑level composition.
  - `media/` — audio/video/images stacks (e.g., MPD, mpdris2, audio apps/tools).
  - `misc/` — small QoL tweaks and assorted utilities.
  - `secrets/` — sops‑nix integration and modules that read secrets.
  - `text/` — text‑related tools/configuration.
  - `user/` — user applications and systemd user services (mail, torrents, shells, desktop daemons).

- Options & docs
  - Feature options are centralized in `features.nix` under `options.features.*`.
  - A curated overview of options lives in the repo root `OPTIONS.md`.
  - Generated references:
    - Markdown: package `features-options-md` (see `nix build .#features-options-md`).
    - JSON: package `features-options-json`.

- Conventions
  - Prefer `config.lib.neg.mkBool` for boolean options with defaults.
  - Factor package lists into `groups = { ... }` and flatten via `config.lib.neg.mkEnabledList`.
  - For systemd user units, use `config.lib.neg.systemdUser.mkUnitFromPresets` with presets instead of hard‑coding targets; extend with `after`/`wants`/`partOf`/`wantedBy` only when needed.

