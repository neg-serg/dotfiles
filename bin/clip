#!/bin/sh
# clip: clipboard helper (cliphist/clipcat + extras)
# Usage:
#   clip                       # open clipboard menu (cliphist/clipcat)
#   clip pipe [-p|--paste] [-c|--command CMD] [--]
#   clip youtube-dw-list       # pick video URL from history and download
#   clip youtube-dw            # download URL currently in clipboard
#   clip youtube-view          # open yt scratchpad and paste selection
#   clip -h|--help|help        # this help
# Env:
#   USE_CLIPCAT=true           # use clipcat instead of cliphist
[ -z "${USE_CLIPCAT-}" ] && USE_CLIPCAT=false


IFS=' 	
'



# POSIX sh: avoid alias; provide function instead
yt() {
    yt-dlp --downloader aria2c -f "(bestvideo+bestaudio/best)" "$@"
}

read_command() {
    # Offer a tiny preset list; user can also type arbitrary command
    printf '%s\n' sort tac \
      | rofi -dmenu -matching glob -p '❯>'
}

send_key() {
    key="$1"
    case "$key" in
        'Control_L+c') wtype -M ctrl -k c -m ctrl ;;
        'Control_L+v') wtype -M ctrl -k v -m ctrl ;;
        *) : ;;
    esac
}

clipboard_pipe() {
    cmd=""
    selection=""
    out=""
    paste=false
    # Parse options once
    while [ $# -gt 0 ]; do
        case "$1" in
            --) shift; break ;;
            -p|--paste) paste=true; shift ;;
            -c|-e|--command)
                if [ "${2-}" ]; then
                    cmd="$2"; shift 2
                else
                    shift
                    cmd="$(read_command)"
                fi
                ;;
            *) cmd="$(read_command)"; break ;;
        esac
    done
    if [ -z "$cmd" ]; then
        cmd="$(read_command)"
    fi

    # If paste mode: first copy selection from active app
    if [ "$paste" = true ]; then
        send_key 'Control_L+c'
        sleep 0.05
    fi
    # Read current clipboard contents
    selection=$(wl-paste || true)
    if [ -z "$selection" ] && [ "$paste" = true ]; then
        echo "no input, aborting..." >&2
        exit 1
    fi
    # Transform selection through the provided command
    out=$(printf "%s" "$selection" | sh -c "$cmd")
    printf "%s" "$out" | wl-copy
    # If paste mode: paste transformed result back
    if [ "$paste" = true ]; then
        sleep 0.05
        send_key 'Control_L+v'
    fi
    exit 0
}

clip_main() {
    if [ "$USE_CLIPCAT" = true ]; then
        clipcat-menu -c "$HOME/.config/clipcat/clipcat-menu.toml"
    else
        # cliphist: show history -> decode -> copy
        sel=$(cliphist list | rofi -dmenu -lines 10 -i -matching glob -p '⟬clip⟭ ❯>' -theme clip.rasi)
        [ -z "$sel" ] && exit 0
        idx="$(printf '%s' "$sel" | awk -F ':' '{print $1}')"
        cliphist decode "$idx" | wl-copy
    fi
}

yr() {
    negwm send 'scratchpad toggle youtube'
    sleep 1s
    echo "$@" | wl-copy
    wtype -M ctrl -k v -m ctrl
}

youtube_url() {
    if command -v rg >/dev/null 2>&1; then
        sel=$(cliphist list | rg -E 'https.*(youtube|vimeo)\\.com' \
            | rofi -lines 7 -dmenu -p '⟬youtube⟭ ❯>')
    else
        sel=$(cliphist list | grep -E 'https.*(youtube|vimeo)\\.com' \
            | rofi -lines 7 -dmenu -p '⟬youtube⟭ ❯>')
    fi
    [ -z "$sel" ] && exit 1
    idx="$(printf '%s' "$sel" | awk -F ':' '{print $1}')"
    cliphist decode "$idx" | tr -d '\n'
}

case "$1" in
    -h|--help|help)
        sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    pipe) shift; clipboard_pipe "$@" ;;
    youtube-dw-list) shift; cd "${XDG_VIDEOS_DIR:-$HOME/vid}/new" && yt "$(youtube_url)" ;;
    youtube-dw) shift; cd "${XDG_VIDEOS_DIR:-$HOME/vid}/new" && yt "$(wl-paste)" ;;
    youtube-view) shift; yr clip ;;
    *) clip_main ;;
esac
