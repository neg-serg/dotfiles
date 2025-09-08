setopt always_to_end # When completing from the middle of a word, move the cursor to the end of the word
setopt auto_cd # if a command is issued that can't be executed as a normal command, and the command is the name of a directory, perform the cd command to that directory.
setopt auto_pushd # make cd push the old directory onto the directory stack.
setopt c_bases  # print $(( [#16] 0xff ))
setopt completeinword # not just at the end
setopt correct # use autocorrection
setopt extendedglob # enable extended globbing
setopt glob_star_short # */** -> **
setopt hash_list_all  # whenever a command completion is attempted, make sure the entire command path is hashed first.
setopt longlistjobs # display PID when suspending processes as well
setopt magic_equal_subst # ~ substitution and tab completion after a = (for --x=filename args)
setopt multios # support multiple redirections
setopt no_beep # get rid of beeps
setopt no_bg_nice # don't nice background jobs
setopt no_flowcontrol # no c-s/c-q output freezing
setopt no_hup  # don't send SIGHUP to background processes when the shell exits.
setopt no_monitor # do not notify about bg task ending
setopt no_nomatch # try to avoid the 'zsh: no matches found...'
setopt notify  # report the status of backgrounds jobs immediately
setopt nullglob # delete the pattern from the argument list if no match
setopt prompt_subst # set the prompt
setopt pushd_ignore_dups # don't push the same dir twice.
setopt pushdminus # pushd -N goes to Nth dir in stack
setopt pushd_silent # do not print directory stack
setopt pushdtohome # pushd with no args pushes to home
setopt rematch_pcre # use perl-like regexes
setopt rm_star_wait # most Massively Useful Option ever! protects you from "you shoot yourself in the foot".
setopt short_loops # short loops support
setopt transient_rprompt # only show the rprompt on the current prompt
setopt rc_quotes # quotes with ''

() {
    local hist
    for hist in ~/.zsh_history*~$HISTFILE(N); do
        fc -RI $hist
    done
    setopt append_history # this is default, but set for share_history
    setopt extended_history # save each command's beginning timestamp and the duration to the history file
    setopt hist_expire_dups_first # when trimming history, lose oldest duplicates first
    setopt histignorealldups # remove command lines from the history list when the first character on the line is a space
    setopt hist_ignore_dups # ignore duplication command history list
    setopt hist_ignore_space # reduce whitespace in history
    setopt histignorespace # remove command lines from the history list when the first character on the line is a space
    setopt hist_verify # don't execute, just expand history
    setopt inc_append_history # add comamnds as they are typed, don't wait until shell exit
    setopt share_history # import new commands from the history file also in other zsh-session
    setopt nohist_beep # Don't beep when a widget tries to access an history entry which isn't there.
    setopt hist_fcntl_lock # Use the OS's locking mechanism instead of ZSH's
    setopt hist_find_no_dups # When searching in the history do not show dups multiple times
    setopt hist_no_store # Don't add the "history" command to the history when it's called
    setopt hist_reduce_blanks # Don't store blank lines in the history
}

_exists() { (( $+commands[$1] )) }
watch=(notme root) # watch for everyone but me and root
typeset -U path cdpath fpath manpath # automatically remove duplicates from these arrays
typeset -gx PATH=$HOME/bin:/bin:$HOME/.local/bin:$PATH
_exists nvim && {
    typeset -gx EDITOR="nvim"
    typeset -gx VISUAL="${EDITOR}"
    typeset -gx MANPAGER="nvim +Man!"
}
unfunction _exists

typeset -gx TIMEFMT="[37m[34m⟬[37m[37m%J[34m⟭[39m[34m⟬[37m%U[34m⟭[39m[34m⟬[37muser %S[34m⟭[39m[34m⟬[37msystem %P[34m⟭[39m[34m⟬[37mcpu %*E total[34m⟭[39m[34m[39m[34m⟬[37mMem: %M kb max[34m⟭[39m"
typeset -gx WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
typeset -gx READNULLCMD="wbat"
typeset -gx LS_COLORS
typeset -gx HISTFILE=${ZDOTDIR}/zsh_history
typeset -gx SAVEHIST=10000000
typeset -gx HISTSIZE=$((SAVEHIST * 1.10))
typeset -gx HISTORY_IGNORE="&:l:ls:[bf]g:exit:reset:clear:cd*:gs:gd"

_zpcompinit_custom() {
    setopt extendedglob local_options
    autoload -Uz compinit
    local zcd=${ZDOTDIR:-$HOME}/.zcompdump
    local zcdc="$zcd.zwc"
    # Compile the completion dump to increase startup speed, if dump is newer or doesn't exist,
    # in the background as this is doesn't affect the current session
    if [[ -f "$zcd"(#qN.m+1) ]]; then
        compinit -i -d "$zcd"
        { rm -f "$zcdc" && zcompile "$zcd" } &!
        else
            compinit -C -d "$zcd"
            { [[ ! -f "$zcdc" || "$zcd" -nt "$zcdc" ]] && rm -f "$zcdc" && zcompile "$zcd" } &!
    fi
}

zmodload -i zsh/complist
autoload -Uz -- history-search-end split-shell-arguments lookupinit dircolors_init ylock greynoise
autoload -Uz run-help ${^fpath}/run-help-*(N:t) || return
(( $+aliases[run-help] )) && unalias run-help  # make run-help more useful

fasd_init() {
    if [[ -x =fasd ]]; then
        (( $+functions[compdef] )) && {
            # zsh word mode completion
            _fasd_zsh_word_complete() {
                [ "$2" ] && local _fasd_cur="$2"
                [ -z "$_fasd_cur" ] && local _fasd_cur="${words[CURRENT]}"
                local fnd="${_fasd_cur//,/ }"
                local typ=${1:-e}
                fasd --query $typ "$fnd" 2>> "/dev/null" | \
                sort -nr | sed 's/^[^ ]*[ ]*//' | while read -r line; do
                    compadd -U -V fasd "$line"
                done
                compstate[insert]=menu # no expand
            }
            _fasd_zsh_word_complete_f() { _fasd_zsh_word_complete f ; }
            _fasd_zsh_word_complete_d() { _fasd_zsh_word_complete d ; }
            _fasd_zsh_word_complete_trigger() {
                local _fasd_cur="${words[CURRENT]}"
                eval $(fasd --word-complete-trigger _fasd_zsh_word_complete $_fasd_cur)
            }
            # define zle widgets
            zle -C fasd-complete complete-word _generic
            zstyle ':completion:fasd-complete:*' completer _fasd_zsh_word_complete
            zstyle ':completion:fasd-complete:*' menu-select

            zle -C fasd-complete-f complete-word _generic
            zstyle ':completion:fasd-complete-f:*' completer _fasd_zsh_word_complete_f
            zstyle ':completion:fasd-complete-f:*' menu-select

            zle -C fasd-complete-d complete-word _generic
            zstyle ':completion:fasd-complete-d:*' completer _fasd_zsh_word_complete_d
            zstyle ':completion:fasd-complete-d:*' menu-select
        }
    fi
}

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
autoload -Uz fzf-on-tab
zle -N fzf-on-tab

autoload -Uz chpwd
autoload -Uz zcompare
autoload -Uz h
zle_highlight=(region:bg=228 paste:none)
zsh-defer _zpcompinit_custom
zsh-defer fasd_init
zsh-defer dircolors_init

# vim: ft=zsh:nowrap
