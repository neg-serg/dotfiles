# Home Manager Features Overview

This document maps the main `features.*` options used by this Home Manager setup, their defaults, and how profiles affect them. It also notes where the libretro allowlist lives and how to toggle `retroarchFull`.

## Profiles

- `features.profile`: `"full" | "lite"` (default: `"full"`)
  - Profile influences defaults via `modules/default.nix`.
  - You can still override any option after the profile is set.

## Web Stack (`modules/user/web`)

- `features.web.enable` (default: true in full, false in lite)
- `features.web.tools.enable` (aria2, yt‑dlp, misc tools)
  - Default: true in full, false in lite
- `features.web.floorp.enable` (Floorp browser)
  - Default: true in full, false in lite
- `features.web.yandex.enable` (Yandex Browser)
  - Default: true in full, false in lite
 - `features.web.prefs.fastfox.enable` (FastFox‑like Mozilla prefs)
   - Default: true in full, false in lite
   - Summary: increases parallelism, enables site isolation (Fission), lazy tab restore, forces WebRender, disables inline PDF.
   - Caveats: higher memory usage, possible AMO/RFP interaction, inline PDF disabled.

Notes
- Yandex Browser is passed in via `extraSpecialArgs` as `yandexBrowser` (system‑scoped package set). See `flake.nix` and usage in `modules/user/web/browsing.nix`.
- Floorp profile and prefs live in `modules/user/web/floorp.nix`.

## Audio Stack (`modules/media/audio`)

- `features.media.audio.core.enable` (PipeWire routing tools)
  - Default: true in full, false in lite
- `features.media.audio.apps.enable` (players, tagging, analysis tools)
  - Default: true in full, false in lite
- `features.media.audio.creation.enable` (DAW, synths)
  - Default: true in full, false in lite
- `features.media.audio.mpd.enable` (mpd, mpdris2, clients)
  - Default: true in full, false in lite

## Emulators / RetroArch (`modules/user/fun/emulators.nix`)

- `features.emulators.retroarch.full` (use `retroarchFull` with extended cores)
  - Default: true in full, false in lite (and false by default outside profiles)
  - When enabled, extra unfree libretro cores are auto‑allowlisted (see below).

## Unfree Policy

The central unfree policy and presets live in:
- `modules/misc/unfree.nix` (wires `nixpkgs.config.allowUnfreePredicate`)
- `modules/misc/unfree-presets.nix` (presets)
  - Preset `desktop` currently includes: `abuse`, `ocenaudio`, `reaper`, `vcv-rack`, `vital`, `roomeqwizard`, `stegsolve`, `volatility3`, `cursor`, `claude-code`, `yandex-browser-stable`, `lmstudio`, `code-cursor-fhs`.

Libretro allowlist (gated by RetroArch mode) lives in:
- `modules/misc/unfree-libretro.nix`
  - Adds common libretro cores to `features.allowUnfree.extra` only when `features.emulators.retroarch.full = true`.

You can always extend with your own names via:
- `features.allowUnfree.extra = [ "pkgName1" "pkgName2" ];`
- Or override entirely via `features.allowUnfree.allowed`.

## Package Exclusions

- `features.excludePkgs = [ "pkgName" ... ]`
  - Globally exclude packages (by `pname`) from curated module lists that adopt this filter (e.g., pentest/sniffing).
  - Useful to avoid building/adding problematic packages without modifying module files.

## Extra Arguments (flake extraSpecialArgs)

These are passed from `flake.nix` into modules for convenience (camelCase):
- `yandexBrowser` — system package set from the Yandex Browser flake input. Used in `modules/user/web/browsing.nix`.
- `iosevkaNeg` — system package set from the custom Iosevka flake input. Used in `modules/user/theme/default.nix`.

## Ready‑Made Configurations

- Full: `.#homeConfigurations.neg.activationPackage`
- Lite: `.#homeConfigurations.neg-lite.activationPackage`

Switch examples:
- `home-manager switch --flake .#neg` (full)
- `home-manager switch --flake .#neg-lite` (lite)

## Developer Notes

- Commit subjects are enforced to start with `[scope]` via a local hook in `.githooks/commit-msg`.
  - Enable it with: `git config core.hooksPath .githooks` or `just hooks-enable`

## IaC (Terraform / OpenTofu)

- `features.dev.pkgs.iac` — include Infrastructure‑as‑Code CLI (default: true in full profile)
- `features.dev.iac.backend` — choose backend: `"terraform" | "tofu"` (default: `"terraform"`)
  - When `terraform` is selected, the unfree predicate auto‑allowlists it.
  - Packages are added via `modules/dev/pkgs/default.nix`.
