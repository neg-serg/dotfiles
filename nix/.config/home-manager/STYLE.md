# Coding Style (Nix / Home Manager)

- with pkgs usage
  - Localize `with pkgs;` right next to the list or group where it’s used.
    - Good: `home.packages = with pkgs; [ foo bar ];`
    - Good: `groups = with pkgs; { a = [foo]; b = [bar]; };`
    - Avoid module-wide `with pkgs;` or leaking it across unrelated scopes.
- Line width
  - Target ~100 characters. Keep end-of-line comments short. If a comment won’t fit, move it above.
- Comments
  - Prefer one-line, recognizable terms (e.g., “DAW”, “modular synth”).
  - For long explanations, put them on the line(s) above the item.
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

