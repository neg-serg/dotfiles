# Coding Style (Nix / Home Manager)

- with pkgs usage
  - Localize `with pkgs;` right next to the list or group where it’s used.
    - Good: `home.packages = with pkgs; [ foo bar ];`
    - Good: `groups = with pkgs; { a = [foo]; b = [bar]; };`
    - Avoid module-wide `with pkgs;` or leaking it across unrelated scopes.
- Line width (~100 chars)
  - Target ~100 characters per line. This keeps diffs readable.
  - Keep end-of-line comments short; if they don't fit, move them above the line.
  - Tip: set an editor ruler at 100 to help keep lines concise.
  - Example:
    - Good: `"reaper" # DAW`
    - Also good (longer note moved above):
      `# Compute DR14 (Pleasurize Music Foundation procedure)`
      `"dr14_tmeter"`
- Comments
  - Prefer concise, recognizable terms (e.g., "DAW", "modular synth").
  - Put long comments above the line they describe (not inline).
  - Avoid repeating obvious context (module name or path) in comments.
- Options
  - Declare feature options centrally (see `modules/features.nix`).
  - Gate per-area configuration via `mkIf` using `features.*` flags.
- Assertions
  - Provide actionable messages when extra inputs or packages are required by a flag.
- Naming
  - Use camelCase for extraSpecialArgs and internal aliases (e.g., `yandexBrowser`, `iosevkaNeg`).
- Structure
  - Factor large package lists into local `groups = { ... }` sets.
  - Use `config.lib.neg.mkEnabledList` to flatten groups based on flags.
    - Prefer over manual chains of `lib.optionals` for readability and consistency.
    - Pattern: `home.packages = config.lib.neg.mkEnabledList config.features.<area> groups;`
    - For nested scopes (e.g., Python withPackages) build `groups` first, then flatten.
  - For systemd user units, prefer `config.lib.neg.systemdUser.mkUnitFromPresets` to set `After`/`Wants`/`WantedBy`/`PartOf` via presets instead of hardcoding targets in each module. Extend with `after`/`wants`/`partOf`/`wantedBy` args only for truly extra dependencies.

- Systemd (user) sockets/paths
  - Apply the same presets helper to `systemd.user.sockets.*` and `systemd.user.paths.*`.
  - Sockets: tie activation to `sockets.target`; add `wantedBy = ["sockets.target"]` explicitly.
    - Example:
      `systemd.user.sockets.my-sock = lib.recursiveUpdate { Unit.Description = "My socket"; Socket.ListenStream = "%t/my.sock"; } (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["socketsTarget"]; wantedBy = ["sockets.target"]; });`
  - Paths: usually want `default.target` so the path unit is active in the session.
    - Example:
      `systemd.user.paths.my-path = lib.recursiveUpdate { Unit.Description = "Watch foo"; Path.PathChanged = "%h/.config/foo/config"; } (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["defaultWanted"]; });`

- Commit messages
  - Use bracketed scope: `[scope] subject` (English imperative, concise).
    - Examples: `[activation] add guards for xyz`, `[docs] update OPTIONS.md`.
    - Multi-scope allowed: `[gui/hypr][rules] normalize web classes`.
  - Exceptions allowed: `Merge ...`, `Revert ...`, `fixup!`, `squash!`, `WIP`.
  - A `commit-msg` hook enforces this locally (see modules/dev/git/default.nix).
