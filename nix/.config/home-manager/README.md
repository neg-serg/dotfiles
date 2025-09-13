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

