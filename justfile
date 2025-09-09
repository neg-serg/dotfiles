_hm_justfile := "nix/.config/home-manager/justfile"
_hm_dir := "nix/.config/home-manager"
nvim_dir := "nvim/.config/nvim"

fmt:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} fmt

check:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} check

lint:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} lint

hm-neg:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} hm-neg

hm-lite:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} hm-lite

clean-caches:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} clean-caches

# Lint: ensure executables have shebang or recognizable extension
shebang-lint:
    bash -eu -o pipefail -c '
    fail=0
    while IFS= read -r -d "" f; do
      # Skip VCS and encrypted secrets
      case "$f" in */.git/*|*/secrets/crypted/*) continue;; esac
      first=$(head -n1 "$f" | tr -d "\r") || first=""
      # zsh completions must start with #compdef, allow those
      case "$first" in "#compdef"*) continue;; esac
      # Recognized by extension (identifies interpreter), or has shebang
      ext="${f##*.}"
      if [ "${first#\#!}" != "$first" ]; then
        continue
      fi
      case "$ext" in sh|bash|zsh|py|py3|nu|mjs) continue;; esac
      echo "Missing shebang and unknown extension: $f"
      fail=1
    done < <(find . -type f -perm -u=x -print0)
    if [ "$fail" -ne 0 ]; then
      echo "Shebang lint failed" >&2; exit 1; fi
    echo "Shebang lint OK"
    '

# Zsh syntax check (exclude git/secrets); checks *.zsh and zsh-shebang executables in bin/
zsh-syntax:
    bash -eu -o pipefail -c '
    fail=0
    # 1) All .zsh files under shell/.config/zsh
    if find shell/.config/zsh -type f -name "*.zsh" -print -quit 2>/dev/null | grep -q .; then
      while IFS= read -r -d "" f; do
        case "$f" in */.git/*|*/secrets/crypted/*) continue;; esac
        if ! zsh -n "$f"; then echo "zsh syntax error: $f" >&2; fail=1; fi
      done < <(find shell/.config/zsh -type f -name "*.zsh" -print0)
    fi
    # 2) Executables in bin/ with zsh shebang
    if [ -d bin ]; then
      while IFS= read -r -d "" f; do
        first=$(head -n1 "$f" | tr -d "\r") || first=""
        case "$first" in "#!"*zsh*)
          if ! zsh -n "$f"; then echo "zsh syntax error: $f" >&2; fail=1; fi ;;
        esac
      done < <(find bin -type f -perm -u=x -print0)
    fi
    if [ "$fail" -ne 0 ]; then exit 1; fi
    echo "Zsh syntax OK"
    '

# Run Neovim health checks headlessly
nvim-health:
    bash -eu -o pipefail -c '
    if ! command -v nvim >/dev/null 2>&1; then echo "Neovim not found (nvim)" >&2; exit 1; fi
    if [ "${USE_REPO_NVIM:-0}" = 1 ]; then
      export XDG_CONFIG_HOME="$PWD/nvim/.config"
      echo "Using repo Neovim config: $XDG_CONFIG_HOME"
    fi
    nvim --headless "+checkhealth" +qa
    '

# Optional: Lua lint for Neovim config via luacheck (if installed)
nvim-luacheck:
    bash -eu -o pipefail -c '
    if ! command -v luacheck >/dev/null 2>&1; then echo "luacheck not installed" >&2; exit 1; fi
    if [ ! -d "{{nvim_dir}}" ]; then echo "{{nvim_dir}} not found" >&2; exit 1; fi
    luacheck {{nvim_dir}} --codes --no-color
    '

# Optional: Lua static analysis via selene (if installed)
nvim-selene:
    bash -eu -o pipefail -c '
    if ! command -v selene >/dev/null 2>&1; then echo "selene not installed" >&2; exit 1; fi
    if [ ! -d "{{nvim_dir}}" ]; then echo "{{nvim_dir}} not found" >&2; exit 1; fi
    selene {{nvim_dir}}
    '

# Aggregate Neovim lint (runs what is available)
nvim-lint:
    -just nvim-luacheck || true
    -just nvim-selene || true

# Aggregate bin checks
bin-lint:
    just shebang-lint
    just zsh-syntax
