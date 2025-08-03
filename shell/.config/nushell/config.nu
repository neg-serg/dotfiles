# config.nu
# https://www.nushell.sh/book/configuration.html
# This file is loaded after env.nu and before login.nu
# You can open this file in your default editor using: config nu
# See `help config nu` for more options

use ~/.config/nushell/nupm/nupm/

alias gs = git status
alias cp = ^cp --reflink=auto
alias l = eza --icons=auto --hyperlink
alias lcr = eza --icons=auto --hyperlink -al --sort=created --color=always # | tail -14
alias ll = eza --icons=auto --hyperlink -l
alias ls = eza --icons=auto --hyperlink
alias lsd = eza --icons=auto --hyperlink -alD --sort=created --color=always # | tail -14

alias acp = builtin cp
alias als = builtin ls

alias qe = cd (als -a | where name =~ '^.git.*' | where type == dir | sort-by modified | last | get name)

def _exists [name: string] {
  not (which $name | is-empty)
}

alias fc = do {
  let path = $env.HISTORY_PATH
  ^$env.EDITOR $path
}

# alias cp='cp --reflink=auto'
alias mv = mv -i
# alias mk = ^mkdir -p
alias mk = mkdir
alias rd = rmdir

if (_exists "ugrep") {
  alias egrep = ug -E        # search with extended regular expressions (ERE)
  alias epgrep = ug -P       # search with Perl regular expressions
  alias fgrep = ug -F        # find string(s)
  alias grep = ug -G         # search with basic regular expressions (BRE)
  alias xgrep = ug -W        # search (ERE) and output text or hex for binary

  alias zegrep = ug -zE      # search compressed files and archives with ERE
  alias zfgrep = ug -zF      # find string(s) in compressed files/archives
  alias zgrep = ug -zG       # search compressed files and archives with BRE
  alias zpgrep = ug -zP      # search compressed files and archives with Perl regex
  alias zxgrep = ug -zW      # search (ERE) compressed files and output text or hex

  alias xdump = ug -X ""     # hexdump files without searching
  alias ugit = ug -R --ignore-files
} else {
  alias grep = grep --color=auto
}

if (_exists "rg") {
  let rg_options = [
    --max-columns=0
    --max-columns-preview
    --glob '!*.git*'
    --glob '!*.obsidian'
    --colors match:fg:25
    --colors match:style:underline
    --colors line:fg:cyan
    --colors line:style:bold
    --colors path:fg:249
    --colors path:style:bold
    --smart-case
    --hidden
  ]
  let opts = ($rg_options | str join " ")
  alias rg = ^rg $opts
  alias zrg = ^rg $opts -z
}

if (_exists "nmap") {
  alias nmap-vulners = nmap -sV --script=vulners/vulners.nse
  alias nmap-vulscan = nmap -sV --script=vulscan/vulscan.nse
}

if (_exists "xargs") {
  alias x = xargs
}

if (_exists "erd") {
  alias tree = erd
}

if (_exists "bat") {
  alias cat = bat --paging=never
}

alias sort = ^sort --parallel 8 -S 16M
alias ':q' = exit

# Show only empty directories
def emptydir [] {
  ls ** | where type == dir | where {|it| (ls $it.name | is-empty) }
}

if (_exists "sudo") {
  alias sudo = sudo
  alias s = sudo

  let sudo_list = [chmod chown modprobe umount]
  let logind_sudo_list = [reboot halt poweroff]

  if (_exists "iotop") {
    alias iotop = sudo iotop -oPa
  }

  if (_exists "lsof") {
    alias ports = sudo lsof -Pni
  }

  if (_exists "kmon") {
    alias kmon = sudo kmon -u --color 19683a
  }

# for c in $sudo_list {
#   if (_exists $c) {
#     alias $c = sudo $c
#   }
# }

# for i in $logind_sudo_list {
#   alias $i = sudo $i
# }

  if (_exists "reflector") {
    alias mirrors = sudo /usr/bin/reflector --score 100 --fastest 10 --number 10 --verbose --save /etc/pacman.d/mirrorlist
  }
}

if (_exists "btm") {
  alias htop = btm -b -T --mem_as_value
}

if (_exists "dd") {
  alias dd = dd status=progress
}

if (_exists "dig") {
  alias dig = dig +noall +answer
}

if (_exists "dosbox") {
  alias dosbox = dosbox -conf $"($env.XDG_CONFIG_HOME)/dosbox/dosbox.conf"
}

if (_exists "duf") {
  alias df = duf -theme ansi -hide 'special' -hide-mp $"($env.HOME)/*" /nix/store /var/lib/*
} else {
  alias df = df -hT
}

if (_exists "dust") {
  alias sp = dust -r
} else {
  def sp [] {
    ^du -shc ./* | lines | sort
  }
}

if (_exists "fd") {
  alias fd = fd -H --ignore-vcs
  alias fda = fd -Hu
}

if (_exists "gdb") {
  alias gdb = gdb -nh -x $"($env.XDG_CONFIG_HOME)/gdb/gdbinit"
}

if (_exists "readelf") {
  alias readelf = readelf -W
}

if (_exists "strace") {
  alias strace = strace -yy
}

if (_exists "handlr") {
  alias e = handlr open
}

if (_exists "hxd") {
  alias hexdump = hxd
}

if (_exists "iostat") {
  alias iostat = iostat --compact -p -h -s
}

if (_exists "ip") {
  alias ip = ip -c
}

if (_exists "journalctl") {
  def journalctl [...args: string] {
    if ($args | is-empty) {
      ^journalctl -b
    } else {
      ^journalctl ...$args
    }
  }
}

if (_exists "khal") {
  alias cal = khal calendar
}

if (_exists "mtr") {
  alias mtrr = mtr -wzbe
}

if (_exists "nvidia-settings") {
  alias nvidia-settings = nvidia-settings --config=$"($env.XDG_CONFIG_HOME)/nvidia/settings"
}

if (_exists "objdump") {
  alias objdump = objdump -M intel -d
}

if (_exists "pbzip2") {
  alias bzip2 = pbzip2
}

if (_exists "pigz") {
  alias gzip = pigz
}

if (_exists "plocate") {
  alias locate = plocate
}

if (_exists "prettyping") {
  alias ping = prettyping
}

if (_exists "rsync") {
  alias rsync = rsync -az --compress-choice=zstd --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS
}

if (_exists "ssh") {
  alias ssh = TERM=xterm-256color ssh
}

if (_exists "unimatrix") {
  alias matrix = unimatrix -l Aang -s 95
}

if (_exists "xz") {
  alias xz = xz --threads=0
}

if (_exists "zstd") {
  alias zstd = zstd --threads=0
}

# mpv-based aliases/functions
if (_exists "mpv") {
  alias mpv = mpv

  def mpa [...args: string] {
    ^mpv -mute ...$args | save -f $"($env.HOME)/tmp/mpv.log"
  }

  def mpi [...args: string] {
    ^mpv --interpolation=yes --tscale=oversample --video-sync=display-resample ...$args | save -f $"($env.HOME)/tmp/mpv.log"
  }
}

# mpvc alias
if (_exists "mpvc") {
  alias mpvc = mpvc -S $"($env.XDG_CONFIG_HOME)/mpv/socket"
}

# mpc-related aliases and function
if (_exists "mpc") {
  alias love = mpc sendmessage mpdas love
  alias unlove = mpc sendmessage mpdas unlove

  def cdm [] {
    let rel_path = (mpc -f '%file%' | lines | first | path dirname)
    let full_path = $"($env.XDG_MUSIC_DIR)/($rel_path)"
    cd $full_path
  }
}

# yt-dlp-related aliases
if (_exists "yt-dlp") {
  let base_yt_opts = [
    --downloader aria2c
    --embed-metadata
    --embed-thumbnail
    --embed-subs
    --sub-langs=all
  ]

  alias yt = ^yt-dlp ...$base_yt_opts
  alias yta = ^yt-dlp ...$base_yt_opts --write-info-json
}

if (_exists "wget2") {
  alias wget = wget2 --hsts-file $"($env.XDG_DATA_HOME)/wget-hsts"
} else {
  alias wget = wget --continue --show-progress --progress=bar:force:noscroll
}

# local rlwrap_list=(bb fennel guile irb)
# local noglob_list=(fc find ftp history lftp links2 locate lynx nix nixos-remote nixos-rebuild rake rsync sftp you-get yt wget wget2)
# _exists scp && alias scp="noglob scp -r"

# for c in ${noglob_list[@]}; {_exists "$c" && alias "$c=noglob $c"}
# for c in ${rlwrap_list[@]}; {_exists "$c" && alias "$c=rlwrap $c"}
# for c in ${nocorrect_list[@]}; {_exists "$c" && alias "$c=nocorrect $c"}
# for c in ${dev_null_list[@]}; {_exists "$c" && alias "$c=$c 2>/dev/null"}

if (_exists "svn") {
  alias svn = svn --config-dir $"($env.XDG_CONFIG_HOME)/subversion"
}

if (_exists "curl") {
  def cht [...args: string] {
    let query = ($args | str join " " | ^jq -sRr @uri | str trim)
    curl -s $"cheat.sh/($query)"
  }

  alias moon = curl wttr.in/Moon
  alias we = curl 'wttr.in/?T'
  alias wem = curl 'wttr.in/Moscow?lang=ru'

  def sprunge [file: path] {
    open $file | ^curl -F 'sprunge=<-' http://sprunge.us
  }
}

# if (_exists "fzf") {
#   def logs [] {
#     let cmd = "find /var/log/ -type f -name '*log' 2>/dev/null"
#     let log_file = (do -i { ^bash -c $cmd } | from string | lines | 
#       ^fzf --height 40% --min-height 25 --tac --tiebreak=length,begin,index --reverse --inline-info | str trim)
# 
#     if $log_file != "" {
#       if ($env.PAGER | is-empty) {
#         ^less $log_file
#       } else {
#         ^($env.PAGER) $log_file
#       }
#     }
#   }
# }

if (_exists "systemctl") {
  alias ctl = systemctl
  alias stl = s systemctl
  alias utl = systemctl --user
  alias ut  = systemctl --user start
  alias un  = systemctl --user stop
  alias up  = s systemctl start
  alias dn  = s systemctl stop
  alias j   = journalctl
}

# NixOS-specific setup
if ("/etc/NIXOS" | path exists) {
  # let-env NIX_HM $"(/nix/var/nix/profiles/per-user/($env.USER)/home-manager)"
  # let-env NIX_NOW "/run/current-system"
  # let-env NIX_BOOT "/nix/var/nix/profiles/system"

  if (_exists "nixos-rebuild") {
    alias nrb = sudo nixos-rebuild
  }

  def foobar [] {
    nix run github:emmanuelrosa/erosanix#foobar2000
  }

  def flake-checker [] {
    nix run github:DeterminateSystems/flake-checker
  }

  def linux-kernel [] {
    nix-shell -E '
      with import <nixpkgs> {};
      (builtins.getFlake "github:chaotic-cx/nyx/nyxpkgs-unstable")
        .packages.x86_64-linux.linuxPackages_cachyos.kernel.overrideAttrs
        (o: { nativeBuildInputs = o.nativeBuildInputs ++ [ pkg-config ncurses ]; })
    '
  }

  if (_exists "nh") {
    alias seh = home-manager -b bck switch -j 32 --cores 32 --flake ~/.config/home-manager
    alias ser = nh os switch /etc/nixos
  }

  alias nixify = nix-shell -p nur.repos.kampka.nixify
  alias S = nix shell

  def nbuild [] {
    nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
  }

  def nlocate [...args: string] {
    nix run github:nix-community/nix-index-database ...$args
  }

  def qi [pkg: string] {
    let name = $"nixpkgs#($pkg)"
    NIXPKGS_ALLOW_UNFREE=1 nix shell --impure $name
  }

  def q [pkg: string] {
    nix shell $"nixpkgs#($pkg)"
  }

  def flakify [] {
    if not ("./flake.nix" | path exists) {
      nix flake new -t github:Mic92/flake-templates#nix-develop .
    }

    if not ("./.envrc" | path exists) {
      echo "use flake" | save -f .envrc
    }

    direnv allow
    ^($env.EDITOR | default "vim") flake.nix
  }
}

# docker-based functions
if (_exists "docker") {
  def carbonyl [] {
    docker run --rm -ti fathyb/carbonyl https://youtube.com
  }

  def ipmi_one [] {
    docker run -p 127.0.0.1:5900:5900 -p 127.0.0.1:8080:8080 gari123/ipmi-kvm-docker
    echo "xdg-open http://127.0.0.1:8080" | xsel
  }

  def ipmi_two [] {
    docker run -p 8080:8080 solarkennedy/ipmi-kvm-docker
    echo "xdg-open localhost:8080" | xsel
  }
}

# cryptsetup-based functions
if (_exists "cryptsetup") {
  def horny [] {
    sudo cryptsetup luksOpen $"($env.XDG_VIDEOS_DIR)/1st_level/.nd/hiddenfs" cryptroot --key-file /one/hdd.key
  }

  def unhorny [] {
    sudo umount /dev/mapper/cryptroot
    sudo cryptsetup close cryptroot
  }
}

if (_exists "flatpak") {
  alias bottles = flatpak run com.usebottles.bottles
  alias obs = flatpak run com.obsproject.Studio
  alias onlyoffice = QT_QPA_PLATFORM=xcb flatpak run org.onlyoffice.desktopeditors
  alias zoom = flatpak run us.zoom.Zoom
}

$env.EDITOR = "nvim"
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false
$env.error_style = "plain"
$env.config.table.mode = 'none'
$env.config.color_config = {
  header_fg: '#7c90a8'
}

$env.config.history = {
  file_format: sqlite
  max_size: 1_000_000
  sync_on_enter: true
  isolation: true
}

def greet [name:string] {
  echo $"Hello, ($name)!"
}

$env.config.hooks.pre_prompt = [
  {|| echo "Ready to rock 🤘" }
]

if (_exists "git") {
  alias add = git add
  alias checkout = git checkout
  alias commit = git commit
  alias gaa = git add --all
  alias ga = git add
  alias gama = git am --abort
  alias gamc = git am --continue
  alias gam = git am
  alias gamscp = git am --show-current-patch
  alias gams = git am --skip
  alias gapa = git add --patch
  alias gap = git apply
  alias gapt = git apply --3way
  alias gau = git add --update
  alias gav = git add --verbose
  alias gba = git branch -a
  alias gbd = git branch -d
  alias gbD = git branch -D
  alias gb = git branch
  alias gbl = git blame -b -w
  alias gbnm = git branch --no-merged
  alias gbr = git branch --remote
  alias gbsb = git bisect bad
  alias gbsg = git bisect good
  alias gbs = git bisect
  alias gbsr = git bisect reset
  alias gbss = git bisect start
  alias gca = git commit -v -a
  alias 'gca!' = git commit -v -a --amend
  alias gcam = git commit -a -m
  alias 'gcan!' = git commit -v -a --no-edit --amend
  alias 'gcans!' = git commit -v -a -s --no-edit --amend
  alias gcas = git commit -a -s
  alias gcasm = git commit -a -s -m
  alias gcb = git checkout -b
  alias gc = git commit -v
  alias 'gc!' = git commit -v --amend
  alias gclean = git clean -id
  alias gcl = git clone --recurse-submodules
  alias gcmsg = git commit -m
  alias 'gcn!' = git commit -v --no-edit --amend
  alias gco = git checkout
  alias gcor = git checkout --recurse-submodules
  alias gcount = git shortlog -sn
  alias gcpa = git cherry-pick --abort
  alias gcpc = git cherry-pick --continue
  alias gcp = git cherry-pick
  alias gcs = git commit -S
  alias gcsm = git commit -s -m
  alias gdca = git diff --cached
  alias gdct = do { let tag = (git rev-list --tags --max-count=1 | str trim); git describe --tags $tag }
  alias gdcw = git diff --cached --word-diff
  alias gd = git diff -w -U0 --word-diff-regex=[^[:space:]]
  alias gds = git diff --staged
  alias gdup = git diff @{upstream}
  alias gdw = git diff --word-diff
  alias gfa = git fetch --all --prune
  alias gfg = do { git ls-files | lines | where { |l| $l =~ $env.FILTER } }
  alias gf = git fetch
  alias gfo = git fetch origin
  alias ggf = git push --force origin (git rev-parse --abbrev-ref HEAD | str trim)
  alias ggfl = git push --force-with-lease origin (git rev-parse --abbrev-ref HEAD | str trim)
  alias ggl = git pull origin (git rev-parse --abbrev-ref HEAD | str trim)
  alias ggp = git push origin (git rev-parse --abbrev-ref HEAD | str trim)
  alias ggsup = git branch --set-upstream-to=origin/(git rev-parse --abbrev-ref HEAD | str trim)
  alias ggu = git pull --rebase origin (git rev-parse --abbrev-ref HEAD | str trim)
  alias gignored = do { git ls-files -v | lines | where {|l| $l | str starts-with 'h' } }
  alias gignore = git update-index --assume-unchanged
  alias gl = git pull
  alias gma = git merge --abort
  alias gm = git merge
  alias gmtl = git mergetool --no-prompt
  alias gpd = git push --dry-run
  alias 'gpf!' = git push --force
  alias gpf = git push --force-with-lease
  alias gp = git push
  alias gpr = git pull --rebase
  alias gpristine = do { git reset --hard; git clean -dffx }
  alias gpsup = git push --set-upstream origin (git rev-parse --abbrev-ref HEAD | str trim)
  alias gpv = git push -v
  alias gra = git remote --add
  alias grba = git rebase --abort
  alias grbc = git rebase --continue
  alias grb = git rebase
  alias grbi = git rebase -i
  alias grbo = git rebase --onto
  alias grbs = git rebase --skip
  alias grev = git revert
  alias gr = git remote
  alias grh = git reset
  alias grhh = git reset --hard
  alias grmc = git rm --cached
  alias grm = git rm
  alias grs = git restore
  alias grup = git remote update
  alias gs = git status --short -b
  alias gsh = git show
  alias gsi = git submodule init
  alias gsps = git show --pretty=short --show-signature
  alias gstaa = git stash apply
  alias gsta = git stash push
  alias gstall = git stash --all
  alias gstc = git stash clear
  alias gstd = git stash drop
  alias gstl = git stash list
  alias gstp = git stash pop
  alias gsts = git stash show --text
  alias gstu = git stash --include-untracked
  alias gsu = git submodule update
  alias gswc = git switch -c
  alias gsw = git switch
  alias gts = git tag -s
  alias gu = git reset @ --
  alias gupa = git pull --rebase --autostash
  alias gupav = git pull --rebase --autostash -v
  alias gup = git pull --rebase
  alias gupv = git pull --rebase -v
  alias gwch = git whatchanged -p --abbrev-commit --pretty=medium
  alias gx = git reset --hard @
  alias pull = git pull
  alias push = git push
  alias resolve = git mergetool --tool=nwim
  alias stash = git stash
  alias status = git status
  alias uncommit = git reset --soft HEAD^
}

$env.config.color_config.separator = "#162b44"
# $env.config.color_config.leading_trailing_space_bg = "#ffffff"
# $env.config.color_config.header = "gb"
# $env.config.color_config.date = "wd"
# $env.config.color_config.filesize = "c"
# $env.config.color_config.row_index = "cb"
# $env.config.color_config.bool = "red"
# $env.config.color_config.int = "green"
# $env.config.color_config.duration = "blue_bold"
# $env.config.color_config.range = "purple"
# $env.config.color_config.float = "red"
# $env.config.color_config.string = "white"
# $env.config.color_config.nothing = "red"
# $env.config.color_config.binary = "red"
# $env.config.color_config.cellpath = "cyan"
# $env.config.color_config.hints = "dark_gray"
