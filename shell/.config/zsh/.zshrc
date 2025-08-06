source ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh 2>/dev/null || true
typeset -gx P9K_SSH=0
zinit_dir="${ZDOTDIR:-$HOME}/.zinit"; zinit_bin="$zinit_dir/bin/zinit.zsh"
if [[ ! -f $zinit_bin ]]; then
  mkdir -p "$zinit_dir" && chmod g-rwX "$zinit_dir"
  git clone https://github.com/zdharma-continuum/zinit "$zinit_dir/bin"
fi
source "${ZDOTDIR}/.zinit/bin/zinit.zsh"; autoload -Uz _zinit; (( ${+_comps} )) && _comps[zinit]=_zinit
[[ -f /etc/NIXOS ]] && fpath=(${ZDOTDIR}/lazyfuncs ${XDG_CONFIG_HOME}/zsh-nix $fpath)
zinit atload"!source ${ZDOTDIR}/.p10k.zsh" lucid nocd for romkatv/powerlevel10k # best prompt
zinit load romkatv/zsh-defer
zinit load QuarticCat/zsh-smartcache
zinit load Tarrasch/zsh-functional
zinit ice wait'!0'
zinit wait lucid silent atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay" for neg-serg/fast-syntax-highlighting blockf zsh-users/zsh-completions
source "${ZDOTDIR}/01-init.zsh"
zsh-defer source "${ZDOTDIR}/02-cmds.zsh"
zsh-defer source "${ZDOTDIR}/03-completion.zsh"
zsh-defer source "${ZDOTDIR}/04-bindings.zsh"
[[ -e "${XDG_CONFIG_HOME}/broot/launcher/bash/br" ]] && source "${XDG_CONFIG_HOME}/broot/launcher/bash/br"
[[ -x "$(command -v zoxide > /dev/null)" ]] && eval "$(zoxide init zsh)"
[[ $NEOVIM_TERMINAL ]] && source "${ZDOTDIR}/08-neovim-cd.zsh"
command -v nix-your-shell >/dev/null && nix-your-shell zsh | source /dev/stdin
[[ -f "$XDG_CONFIG_HOME/zsh/.p10k.zsh" ]] && . "$XDG_CONFIG_HOME/zsh/.p10k.zsh"
eval "$(oh-my-posh init zsh --config ${ZDOTDIR}/neg.omp.json)"
# vim: ft=zsh:nowrap
