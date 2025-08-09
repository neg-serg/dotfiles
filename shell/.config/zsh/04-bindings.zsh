autoload -Uz fg-widget && zle -N fg-widget
autoload -Uz imv
autoload -Uz inplace_mk_dirs && zle -N inplace_mk_dirs
autoload -Uz magic-abbrev-expand && zle -N magic-abbrev-expand
autoload -Uz rationalise-dot && zle -N rationalise-dot
autoload -Uz redraw-prompt
autoload -Uz special-accept-line && zle -N special-accept-line
autoload -Uz zleiab && zle -N zleiab

_nothing(){}; zle -N _nothing

autoload -Uz cd-rotate
cd-back(){ cd-rotate +1 }
cd-forward(){ cd-rotate -0 }
zle -N cd-back && zle -N cd-forward
bindkey "^[-" cd-forward
bindkey "^[=" cd-back

autoload up-line-or-beginning-search && zle -N up-line-or-beginning-search
autoload down-line-or-beginning-search && zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
bindkey "^p" up-line-or-beginning-search
bindkey "^n" down-line-or-beginning-search

bindkey " " magic-abbrev-expand
bindkey . rationalise-dot
bindkey "^xD" describe-key-briefly
bindkey "^z" fg-widget
bindkey '^J' fasd-complete
bindkey '^@' fasd-complete
bindkey '^m' special-accept-line
bindkey " "  magic-space
bindkey ",." zleiab
bindkey . rationalise-dot
bindkey -M isearch . self-insert # without this, typing a . aborts incremental history search
bindkey '^xM' inplace_mk_dirs # load the lookup subsystem if it's available on the system
# vim: ft=zsh:nowrap
