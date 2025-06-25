_exists() { (( $+commands[$1] )) }
[[ -x ~/bin/acol ]] && { for t in du env lsblk lspci nmap mount; alias $t="acol $t" }
alias qe='cd ^.git*(/om[1]D)'
alias ls="${aliases[ls]:-ls} --time-style=+\"%d.%m.%Y %H:%M\" --color=auto --hyperlink=auto"
alias l="${aliases[ls]:-ls}"
_exists eza && {
    alias eza="eza --icons=auto --hyperlink"
    alias ls="${aliases[eza]:-eza}"
    alias l="${aliases[eza]:-eza}"
    alias ll="${aliases[eza]:-eza} -l"
    alias lcr="${aliases[eza]:-eza} -al --sort=created --color=always | tail -10"
    alias lsd="${aliases[eza]:-eza} -alD --sort=created --color=always | tail -10"
}
alias fc="fc -liE 100"
alias cp='cp --reflink=auto'
alias ll='ls -lah'
alias mv='mv -i'
alias mk='mkdir -p'
alias rd='rmdir'
_exists procs && _exists gum && k() {
    procs "$1" --no-header \
        | awk -F '│' '{printf $1}{printf "│"}{print $3}' \
        | gum choose --no-limit \
        | awk '{print $1}' \
        | xargs kill -9
}
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
_exists btm && alias htop='btm -b -T --mem_as_value'
_exists dd && alias dd='dd status=progress'
_exists dig && alias dig='dig +noall +answer'
_exists dosbox && alias dosbox=dosbox -conf "$XDG_CONFIG_HOME"/dosbox/dosbox.conf
_exists duf && alias df="duf -theme ansi -hide 'special' -hide-mp $HOME/'*',/nix/store,/var/lib/'*'" || alias df='df -hT'
_exists dust && alias sp='dust -r' || alias sp='du -shc ./*|sort -h'
_exists fd && {alias fd='fd -H --ignore-vcs' && alias fda='fd -Hu'}
_exists gdb && alias gdb="gdb -nh -x ${XDG_CONFIG_HOME}/gdb/gdbinit"
_existsg readelf && alias readelf='readelf -W'
_existsg strace && alias strace="strace -yy"
_exists handlr && alias e='handlr open'
_exists hxd && alias hexdump='hxd'
_exists iostat && alias iostat='iostat --compact -p -h -s'
_exists ip && alias ip='ip -c'
_exists journalctl && journalctl() {command journalctl "${@:--b}";}
_exists khal && alias cal='khal calendar'
_exists mtr && alias mtrr='mtr -wzbe'
_exists nvidia-settings && alias nvidia-settings="nvidia-settings --config=$XDG_CONFIG_HOME/nvidia/settings"
_exists objdump && alias objdump='objdump -M intel -d'
_exists pbzip2 && alias bzip2='pbzip2'
_exists pigz && alias gzip='pigz'
_exists plocate && alias locate='plocate'
_exists prettyping && alias ping='prettyping'
_exists rsync && alias rsync='rsync -az --compress-choice=zstd --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS'
_exists ssh && alias ssh="TERM=xterm-256color ${aliases[ssh]:-ssh}"
_exists umimatrix && alias matrix='unimatrix -l Aang -s 95'
_exists xz && alias xz='xz --threads=0'
_exists zstd && alias zstd='zstd --threads=0'
_exists mpv && {
    alias mpv="mpv"
    alias mpa="${aliases[mpv]:-mpv} -mute "$@" > ${HOME}/tmp/mpv.log"
    alias mpi="${aliases[mpv]:-mpv} --interpolation=yes --tscale='oversample' \
        --video-sync='display-resample' "$@" > ${HOME}/tmp/mpv.log"
}
_exists mpvc && {alias mpvc="mpvc -S ${XDG_CONFIG_HOME}/mpv/socket"}
_exists mpc && {
    alias love='mpc sendmessage mpdas love'
    alias unlove='mpc sendmessage mpdas unlove'
    cdm(){
        dirname="$XDG_MUSIC_DIR/$(dirname "$(mpc -f '%file%'|head -1)")"
        cd "$dirname"
    }
}
_exists yt-dlp && {
    alias yt='yt-dlp --downloader aria2c --embed-metadata --embed-thumbnail --embed-subs --sub-langs=all'
    alias yta='yt-dlp --downloader aria2c --embed-metadata --embed-thumbnail --embed-subs --sub-langs=all --write-info-json'
}
if _exists wget2; then
    alias wget="wget2 --hsts-file=$XDG_DATA_HOME/wget-hsts"
else
    alias wget='wget --continue --show-progress --progress=bar:force:noscroll'
fi
local rlwrap_list=(bb fennel guile irb)
local noglob_list=(fc find ftp history lftp links2 locate lynx nix nixos-remote nixos-rebuild rake rsync sftp you-get yt wget wget2)
_exists scp && alias scp="noglob scp -r"
for c in ${noglob_list[@]}; {_exists "$c" && alias "$c=noglob $c"}
for c in ${rlwrap_list[@]}; {_exists "$c" && alias "$c=rlwrap $c"}
for c in ${nocorrect_list[@]}; {_exists "$c" && alias "$c=nocorrect $c"}
for c in ${dev_null_list[@]}; {_exists "$c" && alias "$c=$c 2>/dev/null"}
_exists svn && alias svn="svn --config-dir $XDG_CONFIG_HOME/subversion"
_exists git && {
    alias add="git add"
    alias checkout='git checkout'
    alias gd='git diff -w -U0 --word-diff-regex=[^[:space:]]'
    alias gm="git merge"
    alias gp='git push'
    alias gpr="gh pr create"
    alias gr="git rebase -i"
    alias gs='git status --short -b'
    alias gu="git reset @ --"
    alias gx="git reset --hard @"
    alias pull="git pull"
    alias push='git push'
    alias resolve="git mergetool --tool=nwim"
    alias stash="git stash"
    alias status="git status"
    alias uncommit="git reset --soft 'HEAD^'"
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

if [[ -e /etc/NIXOS ]]; then
    # thx to @oni: https://discourse.nixos.org/t/nvd-simple-nix-nixos-version-diff-tool/12397/3
    hash -d nix-hm="/nix/var/nix/profiles/per-user/$USER/home-manager"
    hash -d nix-now="/run/current-system"
    hash -d nix-boot="/nix/var/nix/profiles/system"
    _exists nixos-rebuild && {
        alias nrb='sudo nixos-rebuild'
    }
    foobar(){nix run github:emmanuelrosa/erosanix#foobar2000}
    flake-checker(){nix run github:DeterminateSystems/flake-checker}
    linux-kernel(){
        nix-shell -E 'with import <nixpkgs> {};
            (builtins.getFlake "github:chaotic-cx/nyx/nyxpkgs-unstable").packages.x86_64-linux.linuxPackages_cachyos.kernel.overrideAttrs
            (o: {nativeBuildInputs=o.nativeBuildInputs ++ [ pkg-config ncurses ];})'
        # unpackPhase && cd linux-*; patchPhase; make nconfig
    }
    xkcdpass(){echo "$(nix run nixpkgs#xkcdpass -- -d '-' -n 3 -C capitalize)$((RANDOM % 9))"}
    _exists nh && {
        alias seh="home-manager -b bck switch -j 32 --cores 32 --flake ~/.config/home-manager"
        alias ser="nh os switch /etc/nixos"
    }
    alias nixify='nix-shell -p nur.repos.kampka.nixify'
    alias S="nix shell"
    nbuild(){ nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'}
    nlocate(){ nix run github:nix-community/nix-index-database "$@" }
    qi(){ NIXPKGS_ALLOW_UNFREE=1 nix shell --impure 'nixpkgs#'$1 }
    q(){ nix shell 'nixpkgs#'$1 }
    flakify() {
        # thx to Mic92:
        if [ ! -e flake.nix ]; then
            nix flake new -t github:Mic92/flake-templates#nix-develop .
        elif [ ! -e .envrc ]; then
            echo "use flake" > .envrc
        fi
        direnv allow
        ${EDITOR:-vim} flake.nix
    }
fi

_exists docker && {
    carbonyl(){docker run --rm -ti fathyb/carbonyl https://youtube.com}
    ipmi_one(){ docker run -p 127.0.0.1:5900:5900 -p 127.0.0.1:8080:8080 gari123/ipmi-kvm-docker; echo xdg-open http://127.0.0.1:8080|xsel }
    ipmi_two(){ docker run -p 8080:8080 solarkennedy/ipmi-kvm-docker; echo xdg-open localhost:8080|xsel }
}

_exists cryptsetup && {
    horny(){ sudo cryptsetup luksOpen "$XDG_VIDEOS_DIR/1st_level/.nd/hiddenfs" cryptroot --key-file /one/hdd.key }
    unhorny(){ sudo umount /dev/mapper/cryptroot && sudo cryptsetup close cryptroot }
}

_exists flatpak && {
    alias bottles='flatpak run com.usebottles.bottles'
    alias obs='flatpak run com.obsproject.Studio'
    alias onlyoffice='QT_QPA_PLATFORM=xcb flatpak run org.onlyoffice.desktopeditors'
    alias zoom='flatpak run us.zoom.Zoom'
}

autoload zc
unfunction _exists
# vim: ft=zsh:nowrap
