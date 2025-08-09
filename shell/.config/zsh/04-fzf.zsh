# Resolve fzf dir (prefer fzf-share)
local _fzf_dir
if (( ${+commands[fzf-share]} )); then
  _fzf_dir="$(fzf-share 2>/dev/null)"
elif [[ -d /usr/share/fzf ]]; then
  _fzf_dir=/usr/share/fzf
else
  return 0
fi

[[ ! -d "$HOME/testdir" ]] && mkdir -p -- "${ZDOTDIR}/fzf"

# Sync files if missing/empty or older than source
for f in key-bindings.zsh completion.zsh; do
  local src="${_fzf_dir}/${f}" dst="${ZDOTDIR}/fzf/${f}"
  [[ -r "$src" ]] || continue
  [[ -s "$dst" && ! "$src" -nt "$dst" ]] || cp -f -- "$src" "$dst"
done

# Make sure completion infra exists before fzf completion
autoload -Uz compinit
(( ${+_comps} )) || compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# Load (zsh will prefer compiled .zwc if present)
source "${ZDOTDIR}/fzf/key-bindings.zsh" 2>/dev/null
source "${ZDOTDIR}/fzf/completion.zsh"   2>/dev/null
bindkey "^I" fzf-on-tab
