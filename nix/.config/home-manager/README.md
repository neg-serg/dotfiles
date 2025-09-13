# Home Manager Configuration

This repository contains the Home Manager setup (flakes) for the user environment. It includes modular configuration for GUI (Hyprland), CLI tools, media, mail, secrets, and more.

- Agent guide (how to work in this repo): see AGENTS.md
- Coding/style rules for Nix modules: see STYLE.md
- Feature flags and options: modules/features.nix (with hy3/Hyprland compatibility assert)

Quick tasks (requires `just`):
- Format: `just fmt`
- Checks: `just check`
- Lint only: `just lint`
- Switch HM: `just hm-neg` or `just hm-lite`

Notes:
- Hyprland auto-reload is disabled; reload manually via hotkey.
- Quickshell Settings.json is ignored and must not be committed.

## Getting Started

- Prerequisites
  - Nix with flakes enabled (`nix --version` should work; set `experimental-features = nix-command flakes`).
  - Home Manager available (via flakes).
  - Optional: `just` for the convenience commands below.

- Clone and switch
  - Clone to your dotfiles path (assumed `~/.dotfiles`):
    - `git clone git@github.com:neg-serg/nixos-home.git ~/.dotfiles`
  - Switch to the main profile:
    - `home-manager switch --flake ~/.dotfiles/nix/.config/home-manager#neg`
  - Minimal “lite” profile:
    - `home-manager switch --flake ~/.dotfiles/nix/.config/home-manager#neg-lite`

- Profiles and features
  - Profiles are defined via `features.profile` (`full` by default, `lite` for headless/minimal).
  - Toggle stacks in `home.nix` under `features.*` (e.g., `features.gui.enable`, `features.mail.vdirsyncer.enable`).
  - GPG stack is controlled by `features.gpg.enable`.

- Secrets (sops-nix)
  - Secrets are managed under `secrets/` with sops-nix, referenced from `home.nix` and modules.
  - Ensure your `age` key is available, then decrypt on activation. See `secrets/` and `.sops.yaml`.

## Common Commands

- Format: `just fmt`
- Checks: `just check`
- Lint only: `just lint`
- Switch HM: `just hm-neg` or `just hm-lite`

## Tips

- Hyprland reload is manual only (hotkey in `modules/user/gui/hypr/conf/bindings.conf`).
- Systemd user services use presets via `lib.neg.systemdUser.mkUnitFromPresets`.
- See AGENTS.md for helper APIs and conventions; STYLE.md for code style and commit messages.
