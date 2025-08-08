module_path+=( "/home/neg/.zi/zmodules/zpmod/Src" )
zmodload zi/zpmod
FAST_HIGHLIGHT_THEME="$HOME/.config/zsh/neg.ini"
source ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh 2>/dev/null || true
typeset -gx P9K_SSH=0
if [[ -r "${XDG_CONFIG_HOME:-${HOME}/.config}/zi/init.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-${HOME}/.config}/zi/init.zsh" && zzinit
fi
[[ -f /etc/NIXOS ]] && fpath=(${ZDOTDIR}/lazyfuncs ${XDG_CONFIG_HOME}/zsh-nix $fpath)
zi light z-shell/F-Sy-H
zi ice atload"!source ${ZDOTDIR}/.p10k.zsh" lucid nocd
zi light romkatv/powerlevel10k
zi light romkatv/zsh-defer
zi light QuarticCat/zsh-smartcache
zi light Tarrasch/zsh-functional
zi ice wait'!0'
source "${ZDOTDIR}/01-init.zsh"
for file in {02-cmds,03-completion,04-bindings}; do
  zsh-defer source "${ZDOTDIR}/$file.zsh"
done
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
[[ $NEOVIM_TERMINAL ]] && source "${ZDOTDIR}/08-neovim-cd.zsh"
nix-your-shell zsh | source /dev/stdin 2>/dev/null || true
# eval "$(oh-my-posh init zsh --config ${ZDOTDIR}/neg.omp.json)"
# vim: ft=zsh:nowrap
