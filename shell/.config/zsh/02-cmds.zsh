_exists() { (( $+commands[$1] )) }
alias qe='cd ^.git*(/om[1]D)'
alias ls="${aliases[ls]:-ls} --time-style=+\"%d.%m.%Y %H:%M\" --color=auto --hyperlink=auto"
alias l="${aliases[ls]:-ls}"
_exists eza && {
    alias eza="eza --icons=auto --hyperlink"
    alias ll="${aliases[eza]:-eza} -l"
    alias {l,ls}="${aliases[eza]:-eza}"
    lcr(){eval "${aliases[eza]:-eza} -al --sort=created --color=always" "$@" | tail -14 }
    lsd(){eval "${aliases[eza]:-eza} -alD --sort=created --color=always" "$@" | tail -14 }
}
alias fc="fc -liE 100"
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
_exists readelf && alias readelf='readelf -W'
_exists strace && alias strace="strace -yy"
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
    alias commit='git commit'
    alias gaa="git add --all"
    alias ga="git add"
    alias gama='git am --abort'
    alias gamc='git am --continue'
    alias gam='git am'
    alias gamscp='git am --show-current-patch'
    alias gams='git am --skip'
    alias gapa="git add --patch"
    alias gap="git apply"
    alias gapt="git apply --3way"
    alias gau="git add --update"
    alias gav="git add --verbose"
    alias gba="git branch -a"
    alias gbd="git branch -d"
    alias gbD="git branch -D"
    alias gb="git branch"
    alias gbl="git blame -b -w"
    alias gbnm="git branch --no-merged"
    alias gbr="git branch --remote"
    alias gbsb="git bisect bad"
    alias gbsg="git bisect good"
    alias gbs="git bisect"
    alias gbsr="git bisect reset"
    alias gbss="git bisect start"
    alias gca="git commit -v -a"
    alias gca!="git commit -v -a --amend"
    alias gcam="git commit -a -m"
    alias gcan!="git commit -v -a --no-edit --amend"
    alias gcans!="git commit -v -a -s --no-edit --amend"
    alias gcas="git commit -a -s"
    alias gcasm="git commit -a -s -m"
    alias gcb="git checkout -b"
    alias gc="git commit -v"
    alias gc!="git commit -v --amend"
    alias gclean="git clean -id"
    alias gcl="git clone --recurse-submodules"
    alias gcmsg="git commit -m"
    alias gcn!="git commit -v --no-edit --amend"
    alias gco="git checkout"
    alias gcor="git checkout --recurse-submodules"
    alias gcount="git shortlog -sn"
    alias gcpa="git cherry-pick --abort"
    alias gcpc="git cherry-pick --continue"
    alias gcp="git cherry-pick"
    alias gcs="git commit -S"
    alias gcsm="git commit -s -m"
    alias gdca='git diff --cached'
    alias gdcw="git diff --cached --word-diff"
    alias gd='git diff -w -U0 --word-diff-regex=[^[:space:]]'
    alias gds="git diff --staged"
    alias gdup='git diff @{upstream}'
    alias gdw='git diff --word-diff'
    alias gfa='git fetch --all --prune'
    alias gfg='git ls-files | grep'
    alias gf='git fetch'
    alias gfo='git fetch origin'
    alias gignored='git ls-files -v | grep "^[[:lower:]]"'
    alias gignore='git update-index --assume-unchanged'
    alias gl="git pull"
    alias gma="git merge --abort"
    alias gm="git merge"
    alias gmtl="git mergetool --no-prompt"
    alias gpd='git push --dry-run'
    alias gpf!='git push --force'
    alias gpf='git push --force-with-lease'
    alias gp='git push'
    alias gpr="gh pr create"
    alias gpr='git pull --rebase'
    alias gpristine="git reset --hard && git clean -dffx"
    alias gpv='git push -v'
    alias gra='git remote --add'
    alias grba='git rebase --abort'
    alias grbc='git rebase --continue'
    alias grb='git rebase'
    alias grbi='git rebase -i'
    alias grbo='git rebase --onto'
    alias grbs='git rebase --skip'
    alias grev='git revert'
    alias gr="git rebase -i"
    alias gr='git remote'
    alias grh='git reset'
    alias grhh='git reset --hard'
    alias grmc='git rm --cached'
    alias grm='git rm'
    alias grs='git restore'
    alias grup='git remote update'
    alias gs='git status --short -b'
    alias gsh='git show'
    alias gsi='git submodule init'
    alias gsps='git show --pretty=short --show-signature'
    alias gstaa='git stash apply'
    alias gsta='git stash push'
    alias gsta='git stash save'
    alias gstall='git stash --all'
    alias gstc='git stash clear'
    alias gstd='git stash drop'
    alias gstl='git stash list'
    alias gstp='git stash pop'
    alias gsts='git stash show --text'
    alias gstu='git stash --include-untracked'
    alias gsu='git submodule update'
    alias gswc='git switch -c'
    alias gsw='git switch'
    alias gts='git tag -s'
    alias gu="git reset --soft 'HEAD^'"
    alias gupa='git pull --rebase --autostash'
    alias gupav='git pull --rebase --autostash -v'
    alias gup='git pull --rebase'
    alias gupv='git pull --rebase -v'
    alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
    alias pull="git pull"
    alias push='git push'
    alias resolve="git mergetool --tool=nwim"
    alias stash="git stash"
    alias status="git status"
}
_exists curl && {
    alias cht='f(){ curl -s "cheat.sh/$(echo -n "$*"|jq -sRr @uri)";};f'
    alias moon='curl wttr.in/Moon'
    alias we="curl 'wttr.in/?T'"
    alias wem="curl wttr.in/Moscow\?lang=ru"
    geoip(){ curl ipinfo.io/$1; }
    sprunge(){ curl -F "sprunge=<-" http://sprunge.us <"$1" ;}
}
_exists fzf && {
    logs() {
        local cmd log_file
        cmd="command find /var/log/ -type f -name '*log' 2>/dev/null"
        log_file=$(eval "$cmd" | fzf --height 40% --min-height 25 --tac --tiebreak=length,begin,index --reverse --inline-info) && $PAGER "$log_file"
    }
}
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
    _exists nh && {
        alias seh="home-manager -b bck switch -j 32 --cores 32 --flake $(readlink -f ~/.config/home-manager)"
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
    ipmi_one(){ docker run -p 127.0.0.1:5900:5900 -p 127.0.0.1:8080:8080 gari123/ipmi-kvm-docker; echo xdg-open http://127.0.0.1:8080|wl-copy }
    ipmi_two(){ docker run -p 8080:8080 solarkennedy/ipmi-kvm-docker; echo xdg-open localhost:8080|wl-copy }
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

_exists broot && autoload -Uz br

autoload zc
unfunction _exists
# vim: ft=zsh:nowrap
