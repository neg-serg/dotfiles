zstyle ':acceptline:*' rehash true
# allow one error for every three characters typed in approximate completer
zstyle ':completion:*:approximate:' max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'
# don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'
# start menu completion only if it could find no unambiguous initial string
zstyle ':completion:*:correct:*' insert-unambiguous true
zstyle ':completion:*:corrections' format "%{${fg[blue]}%}--%{${reset_color}%} %d%{${reset_color}%} - (%{${fg[cyan]}%}errors %e%{${reset_color}%})"
zstyle ':completion:*:descriptions' format "%{${fg[blue]}%}--%{${reset_color}%} %d%{${reset_color}%}%{${reset_color}%}"
zstyle ':completion:*:correct:*' original true
zstyle ':completion:*:-tilde-:*' group-order 'named-directories'
# Don't complete unavailable commands.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:history-words' list false
# autorehash for completion
zstyle ':completion:*' rehash true
# match uppercase from lowercase
zstyle ':completion:*' matcher-list '' \
  '+m:{[:lower:]}={[:upper:]}' \
  '+m:{[:upper:]}={[:lower:]}' \
  '+m:{_-}={-_}' \
  'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# automatically load bash completion functions
autoload -Uz bashcompinit && bashcompinit
# separate matches into groups
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=5
zstyle ':completion:*:messages' format "- %{${fg[cyan]}%}%d%{${reset_color}%} -"
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*' verbose true
zstyle ':completion:*:-command-:*:' verbose false
zstyle ':completion:*:warnings' format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'
zstyle ':completion:*:*:zcompile:*' ignored-patterns '(*~|*.zwc)'
zstyle ':completion:correct:' prompt 'correct to: %e'
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' insert-sections true
zstyle ':completion:*:man:*' menu yes select
zstyle ':completion:*' special-dirs ..
zstyle ':completion:*:(mv|cp|file|mp|mpv|mpa):*' ignored-patterns '(#i)*.(url|mht)'
zstyle ':completion:*:*:(mp|mpv|mpa):*' tag-order files
zstyle ':completion:*:*:(mp|mpv|mpa):*' file-sort name
zstyle ':completion:*:*:(mp|mpv|mpa):*' menu select auto
zstyle ':completion:*:*:(mp|mpv|mpa):*' file-patterns '(#i)*.(rmvb|mkv|vob|ts|mp4|m4a|iso|wmv|webm|flv|ogv|avi|mpg|mpeg|iso|nrg|mp3|alac|ogg|flac|rm|wv|m4v):files:mpv\ play *(-/):directories:directories'
zstyle ':completion:*:*:(wine|wine64):*' file-patterns '*.exe:files:wine\ exec *(-/):directories:directories'
zstyle ':completion:*:default' select-prompt \
    "%{${fg[cyan]}%}Match %{${fg_bold[cyan]}%}%m%{${fg_no_bold[cyan]}%} Line %{${fg_bold[cyan]}%}%l%{${fg_no_bold[blue]}%} %p%{${reset_color}%}"
    zstyle ':completion:*:default' \
    list-prompt "%{${fg[cyan]}%}Line %{${fg_bold[cyan]}%}%l%{${fg_no_bold[cyan]}%}  Continue?%{${reset_color}%}"
    zstyle ':completion:*:warnings' \
    format "- %{${fg_no_bold[blue]}%}no match%{${reset_color}%} - %{${fg_no_bold[cyan]}%}%d%{${reset_color}%}"
zstyle ":completion:*" list-colors ${(s.:.)LS_COLORS%ec=*} "ma=07;01;38;5;0;48;5;25"
zstyle ':completion:*:options' list-colors '=^(-- *)=00;38;5;25'
zstyle ':completion:*' squeeze-slashes true # e.g. ls foo//bar -> ls foo/bar
# highlight the original input.
zstyle ':completion:*:original' list-colors "=*=$color[blue];$color[bold]"
# colorize username completion
zstyle ':completion:*:*:*:*:users' list-colors "=*=$color[blue];$color[bg-black]"
zstyle ':completion:*:wine:*' file-patterns '(#i)*.(exe):exe'
# highlight parameters with uncommon names
zstyle ':completion:*:parameters' list-colors "=[^a-zA-Z]*=$color[cyan]"
# highlight aliases
zstyle ':completion:*:aliases' list-colors "=*=$color[green]"
# highlight words like 'esac' or 'end'
zstyle ':completion:*:reserved-words' list-colors "=*=$color[blue]"
# colorize processlist for 'kill'
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#) #([^ ]#)*=$color[cyan]=$color[yellow]=$color[green]"
zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -e -o pid,user,tty,cmd'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:*:zathura:*' tag-order files
zstyle ':completion:*:*:zathura:*' file-patterns '*(/)|*.{pdf,djvu}'
# make them a little less short, after all (mostly adds -l option to the whatis calll)
zstyle ':completion:*:command-descriptions' command '_call_whatis -l -s 1 -r .\*; _call_whatis -l -s 6 -r .\* 2>/dev/null'
# Filename suffixes to ignore during completion (except after rm command)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' '*?.old' '*?.pro'
# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH_CACHE_DIR

autoload -U select-word-style backward-kill-word-match backward-word-match forward-word-match
select-word-style shell

zle -N backward-kill-word-match
zle -N backward-word-match
zle -N forward-word-match

# for backward-kill, all but / are word chars (ie, delete word up to last directory)
zstyle ':zle:backward-kill-word*' word-style standard
zstyle ':zle:*kill*' word-chars '*?_-.[]~=&;!#$%^(){}<>'

zshcache_time="$(date +%s%N)"
autoload -Uz add-zsh-hook

# vim: ft=zsh:nowrap
