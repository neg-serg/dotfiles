_exists() { (( $+commands[$1] )) }
[[ -x ~/bin/acol ]] && { for t in du env lsblk lspci nmap mount; alias $t="acol $t" }
alias qe='cd ^.git*(/om[1]D)'
alias ls="${aliases[ls]:-ls} --time-style=+\"%d.%m.%Y %H:%M\" --color=auto --hyperlink=auto"
alias l="${aliases[ls]:-ls}"
_exists eza && {
    alias ls="eza --icons=auto --hyperlink"
    alias l="${aliases[ls]:-eza}"
    alias ll="${aliases[ls]:-eza} -l"
}
alias cp='cp --reflink=auto'
alias ll='ls -lah'
alias mv='mv -i'
alias mk='mkdir -p'
alias rd='rmdir'
if _exists ugrep; then
    # ------------------------------------------------------------------
    alias egrep='ug -E' # search with extended regular expressions (ERE)
    alias epgrep='ug -P' # search with Perl regular expressions
    alias fgrep='ug -F' # find string(s)
    alias grep='ug -G' # search with basic regular expressions (BRE)
    alias xgrep='ug -W' # search (ERE) and output text or hex for binary
    # ------------------------------------------------------------------
    alias zegrep='ug -zE' # search compressed files and archives with ERE
    alias zfgrep='ug -zF' # find string(s) in compressed files and/or archives
    alias zgrep='ug -zG' # search compressed files and archives with BRE
    alias zpgrep='ug -zP' # search compressed files and archives with Perl regular expressions
    alias zxgrep='ug -zW' # search (ERE) compressed files/archives and output text or hex for binary
    # ----------------------------------------------------------------------------------------------
    alias xdump='ug -X ""' # hexdump files without searching
    alias ugit='ug -R --ignore-files'
else
    alias grep='grep --color=auto'
fi
_exists rg && {
    local rg_options=(
        --max-columns=0
        --max-columns-preview
        --glob="'!*.git*'"
        --glob="'!*.obsidian'"
        --colors=match:fg:25
        --colors=match:style:underline
        --colors=line:fg:cyan
        --colors=line:style:bold
        --colors=path:fg:249
        --colors=path:style:bold
        --smart-case
        --hidden
    )
    alias rg="rg $rg_options"
    alias -g RG="rg $rg_options"
    alias -g zrg="rg $rg_options -z"
}
_exists nmap && {
    alias nmap-vulners="nmap -sV --script=vulners/vulners.nse"
    alias nmap-vulscan="nmap -sV --script=vulscan/vulscan.nse"
}
_exists xargs && alias x='xargs'
_exists erd && alias tree='erd'
_exists bat && alias cat='bat --paging=never'
alias sort='sort --parallel 8 -S 16M'
alias :q="exit"
alias emptydir='ls -ld **/*(/^F)'
_exists nh && {
    alias swh="nh home switch $(readlink -f $XDG_CONFIG_HOME/home-manager)"
    alias sws="nh os switch /etc/nixos"
    alias S="nix-shell"
}
_exists sudo && {
    alias {sudo,s}='sudo '
    local sudo_list=(chmod chown modprobe umount)
    local logind_sudo_list=(reboot halt poweroff)
    _exists iotop && alias iotop='sudo iotop -oPa'
    _exists lsof && alias ports='sudo lsof -Pni'
    _exists kmon && alias kmon='sudo kmon -u --color 19683a'
    for c in ${sudo_list[@]}; {_exists "$c" && alias "$c=sudo $c"}
    for i in ${logind_sudo_list[@]}; alias "${i}=sudo ${sysctl_pref} ${i}"
    unset sudo_list noglob_list rlwrap_list nocorrect_list logind_sudo_list
    _exists reflector && alias mirrors='sudo /usr/bin/reflector --score 100 --fastest 10 --number 10 --verbose --save /etc/pacman.d/mirrorlist'
}
_exists nvidia-settings && alias nvidia-settings="nvidia-settings --config=$XDG_CONFIG_HOME/nvidia/settings"
_exists plocate && alias locate='plocate'
_exists dd && alias dd='dd status=progress'
_exists hxd && alias hexdump='hxd'
_existsg readelf && alias readelf='readelf -W'
_existsg strace && alias strace="strace -yy"
_exists ssh && alias ssh="TERM=xterm-256color ${aliases[ssh]:-ssh}"
_exists prettyping && alias ping='prettyping'
_exists khal && alias cal='khal calendar'
_exists umimatrix && alias matrix='unimatrix -l Aang -s 95'
_exists handlr && alias e='handlr open'
_exists rsync && alias rsync='rsync -az --compress-choice=zstd --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS'
_exists dig && alias dig='dig +noall +answer'
_exists mtr && alias mtrr='mtr -wzbe'
_exists dust && alias sp='dust -r' || alias sp='du -shc ./*|sort -h'
_exists duf && alias df="duf -theme ansi -hide 'special' -hide-mp $HOME/'*',/nix/store" || alias df='df -hT'
_exists btm && alias htop='btm -b -T --mem_as_value'
_exists journalctl && journalctl() {command journalctl "${@:--b}";}
_exists ip && alias ip='ip -c'
_exists fd && {alias fd='fd -H --ignore-vcs' && alias fda='fd -Hu'}
_exists objdump && alias objdump='objdump -M intel -d'
_exists gdb && alias gdb="gdb -nh -x ${XDG_CONFIG_HOME}/gdb/gdbinit"
_exists nvim && alias nvim='v'
_exists iostat && alias iostat='--compact -p -h -s'
_exists patool && {alias se='patool extract'; alias pk='patool create';}
_exists xz && alias xz='xz --threads=0'
_exists pigz && alias gzip='pigz'
_exists pbzip2 && alias bzip2='pbzip2'
_exists zstd && alias zstd='zstd --threads=0'
_exists mpv && {
    alias mpv="mpv --vo=gpu"
    alias mpa="${aliases[mpv]:-mpv} -mute "$@" > ${HOME}/tmp/mpv.log"
    alias mpi="${aliases[mpv]:-mpv} --interpolation=yes --tscale='oversample' \
        --video-sync='display-resample' "$@" > ${HOME}/tmp/mpv.log"
}
_exists mpvc && {alias mpvc="mpvc -S ${XDG_CONFIG_HOME}/mpv/socket"}
_exists mpc && {
    alias love='mpc sendmessage mpdas love'
    alias unlove='mpc sendmessage mpdas unlove'
    cdm(){
        dirname="$(awk '/music_directory/{print $2}' "$XDG_CONFIG_HOME/mpd/mpd.conf"|tr -d '"'|sed 's:^~:'$HOME':')/$(dirname "$(mpc -f '%file%'|head -1)")"
        cd "$dirname"
    }
}
_exists yt-dlp && {
    alias yt='yt-dlp --downloader aria2c --embed-metadata --embed-thumbnail --embed-subs --sub-langs=all'
    alias yta='yt-dlp --downloader aria2c --embed-metadata --embed-thumbnail --embed-subs --sub-langs=all --write-info-json'
    alias ytt='ytfzf --preview-side=left -t'
}
if _exists wget2; then
    alias wget="wget2 --hsts-file=$XDG_DATA_HOME/wget-hsts"
else
    alias wget='wget --continue --show-progress --progress=bar:force:noscroll'
fi
xkcdpass(){echo "$(nix run nixpkgs#xkcdpass -- -d '-' -n 3 -C capitalize)$((RANDOM % 9))"}
local rlwrap_list=(bb fennel guile irb)
local noglob_list=(fc find ftp history lftp links2 locate lynx nix nixos-remote nixos-rebuild rake rsync scp sftp you-get yt wget wget2)
for c in ${noglob_list[@]}; {_exists "$c" && alias "$c=noglob $c"}
for c in ${rlwrap_list[@]}; {_exists "$c" && alias "$c=rlwrap $c"}
for c in ${nocorrect_list[@]}; {_exists "$c" && alias "$c=nocorrect $c"}
for c in ${dev_null_list[@]}; {_exists "$c" && alias "$c=$c 2>/dev/null"}
_exists svn && alias svn="svn --config-dir $XDG_CONFIG_HOME/subversion"
_exists git && {
    alias gd='git diff -w -U0 --word-diff-regex=[^[:space:]]'
    alias gp='git push'
    alias gs='git status --short -b'
    # http://neurotap.blogspot.com/2012/04/character-level-diff-in-git-gui.html
    intra_line_diff='--word-diff-regex="[^[:space:]]|([[:alnum:]]|UTF_8_GUARD)+"'
    intra_line_less='LESS="-R +/-\]|\{\+"' # jump directly to changes in diffs
    alias add="git add"
    alias checkout='git checkout'
    alias pull="git pull"
    alias push='git push'
    alias stash="git stash"
    alias status="git status"
    alias uncommit="git reset --soft 'HEAD^'"
    alias resolve="git mergetool --tool=nwim"
    if _exists gum; then
        autoload -Uz commit
    else
        alias commit='git commit'
    fi
}
_exists curl && {
    alias cht='f(){ curl -s "cheat.sh/$(echo -n "$*"|jq -sRr @uri)";};f'
    alias moon='curl wttr.in/Moon'
    alias we="curl 'wttr.in/?T'"
    alias wem="curl wttr.in/Moscow\?lang=ru"
    sprunge(){ curl -F "sprunge=<-" http://sprunge.us <"$1" ;}
}
_exists fzf && {
    logs() {
        local cmd log_file
        cmd="command find /var/log/ -type f -name '*log' 2>/dev/null"
        log_file=$(eval "$cmd" | fzf --height 40% --min-height 25 --tac --tiebreak=length,begin,index --reverse --inline-info) && $PAGER "$log_file"
    }
}
_exists xev && alias xev="xev | grep -A2 --line-buffered '^KeyRelease' | sed -n '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'"
_exists systemctl && {
    alias ctl='systemctl'
    alias stl='s systemctl'
    alias utl='systemctl --user'
    alias ut='systemctl --user start'
    alias un='systemctl --user stop'
    alias up='s systemctl start'
    alias dn='s systemctl stop'
    alias j='journalctl'
}
_exists nixos-rebuild && {
    alias nrb='sudo nixos-rebuild'
}

# thx to @oni: https://discourse.nixos.org/t/nvd-simple-nix-nixos-version-diff-tool/12397/3
hash -d nix-hm="/nix/var/nix/profiles/per-user/$USER/home-manager"
hash -d nix-now="/run/current-system"
hash -d nix-boot="/nix/var/nix/profiles/system"
# thx to Mic92:
flakify() {
    if [ ! -e flake.nix ]; then
        nix flake new -t github:Mic92/flake-templates#nix-develop .
    elif [ ! -e .envrc ]; then
        echo "use flake" > .envrc
    fi
    direnv allow
    ${EDITOR:-vim} flake.nix
}

autoload zc
unfunction _exists
# vim: ft=zsh:nowrap
