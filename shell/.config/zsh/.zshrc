# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Added by Zinit's installer
if [[ ! -f ${ZDOTDIR}/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "${ZDOTDIR}/.zinit" && command chmod g-rwX "${ZDOTDIR}/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "${ZDOTDIR}/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
source "${ZDOTDIR}/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

typeset -gx P9K_SSH=0
if [[ ! -f /etc/NIXOS ]]; then
   fpath=(
       ${ZDOTDIR}/lazyfuncs
       ${XDG_CONFIG_HOME}/zsh-nix
       /usr/share/zsh/site-functions
       /usr/share/zsh/functions/{Misc,Zle,Completion}
       /usr/share/zsh/functions/Completion/*
   )
else
    fpath=(${ZDOTDIR}/lazyfuncs ${XDG_CONFIG_HOME}/zsh-nix $fpath)
fi

zinit atload"!source ${ZDOTDIR}/.p10k.zsh" lucid nocd for romkatv/powerlevel10k # best prompt
zinit load romkatv/zsh-defer
zinit load QuarticCat/zsh-smartcache
zinit load Tarrasch/zsh-functional
zinit ice wait'!0'
zinit wait lucid for silent atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay" \
    neg-serg/fast-syntax-highlighting blockf zsh-users/zsh-completions
source "${ZDOTDIR}/01-init.zsh"
zsh-defer source "${ZDOTDIR}/02-cmds.zsh"
zsh-defer source "${ZDOTDIR}/03-completion.zsh"
zsh-defer source "${ZDOTDIR}/04-bindings.zsh"
[[ -e "${XDG_CONFIG_HOME}/broot/launcher/bash/br" ]] && source "${XDG_CONFIG_HOME}/broot/launcher/bash/br"
[[ -x "$(command -v zoxide > /dev/null)" ]] && eval "$(zoxide init zsh)"
[[ $NEOVIM_TERMINAL ]] && source "${ZDOTDIR}/08-neovim-cd.zsh"
[[ ! -f "$XDG_CONFIG_HOME/zsh/.p10k.zsh" ]] || source "$XDG_CONFIG_HOME/zsh/.p10k.zsh"
if command -v nix-your-shell > /dev/null; then
  nix-your-shell zsh | source /dev/stdin
fi
# vim: ft=zsh:nowrap
