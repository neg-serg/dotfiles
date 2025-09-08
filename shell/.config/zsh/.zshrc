module_path+=("$HOME/.zi/zmodules/zpmod/Src"); zmodload zi/zpmod 2> /dev/null
FAST_WORK_DIR=~/.config/f-sy-h
source ~/.config/zsh/00-fsyh-parser.zsh
source ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh 2>/dev/null || true
zi_init=${XDG_CONFIG_HOME:-$HOME/.config}/zi/init.zsh
[[ -r $zi_init ]] && . $zi_init && zzinit
[[ -f /etc/NIXOS ]] && fpath=(${ZDOTDIR}/lazyfuncs ${XDG_CONFIG_HOME}/zsh-nix $fpath)
zi ice depth'1' lucid
zi light romkatv/zsh-defer
typeset -f zsh-defer >/dev/null || zsh-defer() { "$@"; }
# F-Sy-H (deferred to next prompt is fine)
# zi ice depth'1' lucid atinit'typeset -gA FAST_HIGHLIGHT; FAST_HIGHLIGHT[use_async]=1 FAST_HIGHLIGHT[BIND_VI_WIDGETS]=0 FAST_HIGHLIGHT[WIDGETS_MODE]=minimal' wait'0'
# zi load neg-serg/F-Sy-H
typeset -gA FAST_HIGHLIGHT
FAST_HIGHLIGHT[use_async]=1
FAST_HIGHLIGHT[BIND_VI_WIDGETS]=0
FAST_HIGHLIGHT[WIDGETS_MODE]=minimal
source ~/.zi/plugins/neg-serg---F-Sy-H/F-Sy-H.plugin.zsh
# P10k — NO wait here -> shows on first prompt
zi ice lucid atload'[[ -r ${ZDOTDIR}/.p10k.zsh ]] && source ${ZDOTDIR}/.p10k.zsh'
zi light romkatv/powerlevel10k
# Utilities (deferred)
zi ice depth'1' lucid wait'0'
zi light QuarticCat/zsh-smartcache
source "${ZDOTDIR}/01-init.zsh"
for file in {02-cmds,03-completion,04-fzf,04-bindings,05-neg-cd}; do
  zsh-defer source "${ZDOTDIR}/$file.zsh"
done
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
[[ $NEOVIM_TERMINAL ]] && source "${ZDOTDIR}/08-neovim-cd.zsh"
# vim: ft=zsh:nowrap
