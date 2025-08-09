module_path+=( "/home/neg/.zi/zmodules/zpmod/Src" )
zmodload zi/zpmod 2> /dev/null
local __had_pcre=${options[REMATCHPCRE]}
unsetopt rematchpcre
FAST_WORK_DIR=~/.config/f-sy-h
source ~/.config/zsh/00-fsyh-parser.zsh
source ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh 2>/dev/null || true
typeset -gx P9K_SSH=0
if [[ -r "${XDG_CONFIG_HOME:-${HOME}/.config}/zi/init.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-${HOME}/.config}/zi/init.zsh" && zzinit
fi
[[ -f /etc/NIXOS ]] && fpath=(${ZDOTDIR}/lazyfuncs ${XDG_CONFIG_HOME}/zsh-nix $fpath)

# zsh-defer first (so calls won’t fail)
zi ice depth'1' lucid
zi light romkatv/zsh-defer
typeset -f zsh-defer >/dev/null || zsh-defer() { "$@"; }
# F-Sy-H (deferred to next prompt is fine)
zi ice depth'1' lucid atinit'typeset -gA FAST_HIGHLIGHT; FAST_HIGHLIGHT[use_async]=1' wait'0'
zi load neg-serg/F-Sy-H
# P10k — NO wait here -> shows on first prompt
zi ice lucid atload'[[ -r ${ZDOTDIR}/.p10k.zsh ]] && source ${ZDOTDIR}/.p10k.zsh'
zi light romkatv/powerlevel10k
# Utilities (deferred)
zi ice depth'1' lucid wait'0'
zi light QuarticCat/zsh-smartcache
zi light Tarrasch/zsh-functional

source "${ZDOTDIR}/01-init.zsh"
for file in {02-cmds,03-completion,04-bindings}; do
  zsh-defer source "${ZDOTDIR}/$file.zsh"
done
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
[[ $NEOVIM_TERMINAL ]] && source "${ZDOTDIR}/08-neovim-cd.zsh"
nix-your-shell zsh | source /dev/stdin 2>/dev/null || true
(( __had_pcre )) && setopt rematchpcre
# eval "$(oh-my-posh init zsh --config ${ZDOTDIR}/neg.omp.json)"
# vim: ft=zsh:nowrap
