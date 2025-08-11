#!/bin/sh
# Port of your sxiv helper for swayimg.
# Usage from swayimg: exec ~/.local/bin/swayimg-actions.sh <action> "%"
# Notes:
# - % is expanded by swayimg to the absolute path of the current image.
# - We keep your rofi+fasd flow; env and dirs adapted.

set -eu

cache="${HOME}/tmp"
mkdir -p "${cache}"
ff="${cache}/swayimg.$$"
tmp_wall="${cache}/wall_swayimg.$$"

mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}/swayimg
z="${XDG_DATA_HOME:-$HOME/.local/share}/swayimg/data"
last_file="${XDG_DATA_HOME:-$HOME/.local/share}/swayimg/last"
trash="${HOME}/trash/1st-level/pic"
rofi_cmd='rofi -dmenu -sort -matching fuzzy -no-plugins -no-only-match -theme sxiv -custom'

# ---- helpers ---------------------------------------------------------------

rotate() {  # modifies file in-place
  angle="$1"
  shift
  while read -r file; do mogrify -rotate "$angle" "$file"; done
}

choose_dest() {
  # Fuzzy-pick a destination dir using fasd history
  _FASD_DATA="$z" fasd -tlR \
    | sed "s:^$HOME:~:" \
    | sh -c "$rofi_cmd -p \"⟬$1⟭ ❯>\"" \
    | sed "s:^~:$HOME:"
}

proc() { # mv/cp with remembered last dest
  cmd="$1"; file="$2"; dest="${3:-}"
  printf '%s\n' "$file" | tee "$ff" >/dev/null

  if [ -z "${dest}" ]; then
    dest="$(choose_dest "$cmd" || true)"
  fi
  [ -z "${dest}" ] && exit 0

  if [ -d "$dest" ]; then
    while read -r line; do
      "$cmd" "$(realpath "$line")" "$dest"
    done <"$ff"
    _FASD_DATA="$z" fasd -RA "$dest"
    printf '%s %s\n' "$cmd" "$dest" >"$last_file"
  else
    _FASD_DATA="$z" fasd -D "$dest" || true
  fi
}

repeat_action() { # repeat last mv/cp to same dir
  file="$1"
  [ -f "$last_file" ] || exit 0
  last="$(cat "$last_file")"
  cmd="$(printf '%s\n' "$last" | awk '{print $1}')"
  dest="$(printf '%s\n' "$last" | awk '{print $2}')"
  if [ "$cmd" = "mv" ] || [ "$cmd" = "cp" ]; then
    "$cmd" "$file" "$dest"
  fi
}

copy_name() { # copy absolute path to clipboard
  file="$1"
  printf '%s\n' "$(realpath "$file")" | wl-copy
  [ -x "$HOME/bin/pic-notify" ] && "$HOME/bin/pic-notify" "$file" || true
}

make_mono(){
  convert "$1" -colors 2 "$cache/mono__$(basename "$1")"
  hsetroot -cover "$cache/mono__$(basename "$1")"
  echo "$1" >> "${XDG_DATA_HOME:-$HOME/.local/share}/wl/wallpaper.list" 2>/dev/null || true
  rm -f "$cache/mono__$(basename "$1")"
}

make_retro(){
  convert "$1" -colors 12 "$cache/retro__$(basename "$1")"
  hsetroot -cover "$cache/retro__$(basename "$1")"
  echo "$1" >> "${XDG_DATA_HOME:-$HOME/.local/share}/wl/wallpaper.list" 2>/dev/null || true
  rm -f "$cache/retro__$(basename "$1")"
}

wall() { # wall <mode> <file>
  mode="$1"; file="$2"
  case "$mode" in
    center) hsetroot -center "$file" ;;
    tile)   hsetroot -tile "$file" ;;
    fill)   hsetroot -fill "$file" ;;
    full|cover) hsetroot -full "$file" ;;
    mono)   make_mono "$file" ;;
    retro)  make_retro "$file" ;;
  esac
  echo "$file" >> "${XDG_DATA_HOME:-$HOME/.local/share}/wl/wallpaper.list" 2>/dev/null || true
}

finish() { rm -f "$ff" "$tmp_wall" 2>/dev/null || true; }
trap finish EXIT

# ---- dispatch --------------------------------------------------------------
action="${1:-}"; file="${2:-}"

case "$action" in
  rotate-left)    printf '%s\n' "$file" | rotate 270 ;;
  rotate-right)   printf '%s\n' "$file" | rotate 90 ;;
  rotate-180)     printf '%s\n' "$file" | rotate 180 ;;
  rotate-ccw)     printf '%s\n' "$file" | rotate -90 ;;
  copyname)       copy_name "$file" ;;
  repeat)         repeat_action "$file" ;;
  mv)             proc mv "$file" "${3:-}" ;;
  cp)             proc cp "$file" "${3:-}" ;;
  wall-mono)      wall mono "$file" ;;
  wall-fill)      wall fill "$file" ;;
  wall-full)      wall full "$file" ;;
  wall-tile)      wall tile "$file" ;;
  wall-center)    wall center "$file" ;;
  wall-cover)     wall cover "$file" ;;
  *)              echo "Unknown action: $action" >&2; exit 2 ;;
esac
