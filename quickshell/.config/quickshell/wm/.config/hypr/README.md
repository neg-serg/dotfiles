# Hyprland integration for Quickshell

Files in this folder are intended to be sourced by your Hyprland config.

Recommended include in `~/.config/hypr/hyprland.conf`:

  source = ~/.config/hypr/conf.d/*.conf

This repo provides:

- `conf.d/quickshell.conf` — disables animations for Quickshell layer surfaces (namespace `quickshell`) and for a `class:^(quickshell)$` fallback.

After adding, run `hyprctl reload`.

