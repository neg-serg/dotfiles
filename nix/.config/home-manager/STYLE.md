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

- XDG file helpers
  - Prefer the pure helpers from `modules/lib/xdg-helpers.nix` (import locally):
    - Config (text/link): `mkXdgText`, `mkXdgSource`
    - Data (text/link): `mkXdgDataText`, `mkXdgDataSource`
    - Cache (text/link): `mkXdgCacheText`, `mkXdgCacheSource`
    - They ensure parent directories are real dirs (not symlinks), remove any
      existing target (symlink, regular file, or directory), then write/link
      the file. This prevents activation failures when a directory exists where
      a file/link is expected.
  - Examples:
    - Config text: `(xdg.mkXdgText "nyxt/init.lisp" "... Lisp ...")`
    - Config source: `(xdg.mkXdgSource "swayimg" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/media/images/swayimg/conf" true))`
    - Data keep: `(xdg.mkXdgDataText "ansible/roles/.keep" "")`
    - Cache keep: `(xdg.mkXdgCacheText "ansible/facts/.keep" "")`
  - Import tip (robust for docs eval): 
    - From `modules/dev/...` or `modules/media/...`: `let xdg = import ../../lib/xdg-helpers.nix { inherit lib; };`
    - From `modules/user/mail/...`: `let xdg = import ../../../lib/xdg-helpers.nix { inherit lib; };`

- Merging attrsets
  - Prefer `lib.mkMerge [ a b ... ]` over top-level `//` for combining module fragments.
  - Keep each logical piece in its own attrset within `mkMerge` (e.g., package set, xdg helpers, systemd units).

- Runtime directories (first-run safety)
  - Ensure required runtime/state directories exist before services start or files are written.
    - After write: `home.activation.ensureDirs = config.lib.neg.mkEnsureDirsAfterWrite ["$XDG_STATE_HOME/zsh"];`
    - Real config dir: `home.activation.fixFoo = config.lib.neg.mkEnsureRealDir "${config.xdg.configHome}/foo";`
    - Maildir trees: `config.lib.neg.mkEnsureMaildirs "$HOME/.local/mail/gmail" ["INBOX" ...]`
  - Use these in addition to xdg helpers when apps require extra runtime dirs (sockets, logs, caches) outside XDG config files.

- Out-of-store dotfile links
  - For live-editable configs stored in this repo, prefer: `config.lib.neg.mkDotfilesSymlink "path/in/repo" <recursive?>`.
  - Combine with `xdg.mkXdgSource` to get guards + correct placement under XDG.

- Imports (xdg helpers) — convention
  - Use a local binding near the top of a module:
    - `let xdg = import ../../lib/xdg-helpers.nix { inherit lib; }; in lib.mkMerge [ ... ]`
  - Choose `../../` depth according to the module path.
