#!/bin/sh
# pic-notify: send image preview notification and copy path to clipboard
# Usage: pic-notify IMAGE
#   Shows a notification with basic EXIF and copies path (png extension) to clipboard.


IFS=' 	
'
img="${1:-}"
if [ -z "${img}" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
fi
send_notify() {
    c1="<span weight='bold' color='#395573'>"
    c2="<span weight='bold' color='#245361'>"
    b="<span weight='bold'>"
    clear="</span>"
    header="⟬$(echo "$img"|sed -e "s/.bmp$/.png/")⟭"
    header="$(echo "$header" | sed -e "s:$HOME:~:" \
                -e "s:\/:$c1/$clear:g" \
                -e "s:\(⟬\|⟭\):$c1\1$clear:g" -e "s:~:$c2~$clear:g")"
    if command -v exiftool >/dev/null 2>&1; then
        inf="$(exiftool -ImageSize -MIMEType -Megapixels "$img")"
    else
        inf="ImageSize: N/A\nMIMEType: N/A\nMegapixels: N/A"
    fi
    output=$(echo "$inf" | xargs -n4 \
        | sed -e 's/^/⟬/' -e 's/$/⟭/' \
        -e "s;\(.*\):;$b\\1$c1:$clear$clear;" \
        -e "s:\(⟬\|⟭\):$c1\1$clear:g"
    )
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -h "string:fgcolor:#6C7E96" -a "pic" -i "$img" ' ' "$header\n$output"
    fi
}

main() {
    shots_pikz="$HOME/tmp/shots"
    [ ! -d "$shots_pikz" ] && mkdir -p "$shots_pikz"
    echo "$img" | sed -e "s/.bmp$/.png/" | wl-copy
    send_notify
}

main "$@"
