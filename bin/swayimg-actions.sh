#!/usr/bin/env zsh
# swayimg-actions: move/copy/rotate/wallpaper for swayimg; dests limited to $XDG_PICTURES_DIR; before mv send prev_file via IPC to avoid end-of-list crash
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0
fi

set -eu
cache="${HOME}/tmp"
mkdir -p "${cache}"
ff="${cache}/swayimg.$$"
tmp_wall="${cache}/wall_swww.$$"
mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}/swayimg
z="${XDG_DATA_HOME:-$HOME/.local/share}/swayimg/data"
last_file="${XDG_DATA_HOME:-$HOME/.local/share}/swayimg/last"
trash="${HOME}/trash/1st-level/pic"
rofi_cmd='rofi -dmenu -sort -matching fuzzy -no-plugins -no-only-match -theme sxiv -custom'
pics_dir_default="$HOME/Pictures"
pics_dir="${XDG_PICTURES_DIR:-$pics_dir_default}"

# ---- IPC helpers -----------------------------------------------------------
# Find swayimg IPC socket from env or runtime dir (best-effort)
_find_ipc_socket() {
  if [ -n "${SWAYIMG_IPC:-}" ] && [ -S "$SWAYIMG_IPC" ]; then
    printf '%s' "$SWAYIMG_IPC"
    return 0
  fi
  # Fallback: pick the newest socket that looks like swayimg-*.sock
  local rt="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  if [ -d "$rt" ]; then
    # shellcheck disable=SC2012
    local s
    s="$(ls -t "$rt"/swayimg-*.sock 2>/dev/null | head -n1 || true)"
    [ -n "$s" ] && [ -S "$s" ] && { printf '%s' "$s"; return 0; }
  fi
  return 1
}

_ipc_send() { # _ipc_send <command>
  local sock cmd
  cmd="$1"
  sock="$(_find_ipc_socket || true)"
  [ -n "$sock" ] || return 0
  if command -v socat >/dev/null 2>&1; then
    printf '%s\n' "$cmd" | socat - "UNIX-CONNECT:$sock" >/dev/null 2>&1 || true
  elif command -v ncat >/dev/null 2>&1; then
    printf '%s\n' "$cmd" | ncat -U "$sock" >/dev/null 2>&1 || true
  else
    return 0
  fi
}

# ---- swww helpers -----------------------------------------------------------
ensure_swww() {
  # Start swww daemon if not running
  if ! swww query >/dev/null 2>&1; then
    swww init >/dev/null 2>&1 || true
    sleep 0.05
  fi
}

# Return maximum WxH among active outputs (fallback 1920x1080)
screen_wh() {
  local wh
  if command -v swaymsg >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    wh="$(swaymsg -t get_outputs -r 2>/dev/null \
      | jq -r '[.[] | select(.active and .current_mode != null)
                | {w:.current_mode.width|tonumber, h:.current_mode.height|tonumber, a:(.current_mode.width|tonumber)*(.current_mode.height|tonumber)}]
               | if length>0 then (max_by(.a) | "\(.w)x\(.h)") else empty end' 2>/dev/null || true)"
  fi
  [ -n "${wh:-}" ] && printf '%s\n' "$wh" || printf '1920x1080\n'
}

# Render image to tmp file based on mode for swww
# writes output path to $tmp_wall
render_for_mode() {
  local mode="$1" file="$2" wh
  wh="$(screen_wh)"
  rm -f "$tmp_wall" 2>/dev/null || true
  case "$mode" in
    cover|full|fill)
      # cover: crop to fill screen from center
      convert "$file" -resize "${wh}^" -gravity center -extent "$wh" "$tmp_wall" ;;
    center)
      # fit inside with borders, centered
      convert "$file" -resize "${wh}" -gravity center -background black -extent "$wh" "$tmp_wall" ;;
    tile)
      # make tiled canvas of exact screen size
      convert -size "$wh" tile:"$file" "$tmp_wall" ;;
    mono)
      convert "$file" -colors 2 "$tmp_wall" ;;
    retro)
      convert "$file" -colors 12 "$tmp_wall" ;;
    *)
      # default to cover
      convert "$file" -resize "${wh}^" -gravity center -extent "$wh" "$tmp_wall"
      ;;
  esac
}

# ---- helpers ---------------------------------------------------------------
rotate() { # modifies file in-place
  angle="$1"
  shift
  while read -r file; do mogrify -rotate "$angle" "$file"; done
}

choose_dest() {
  # Fuzzy-pick a destination dir using fasd history, limited to XDG_PICTURES_DIR
  local prompt="$1"
  local entries sxiv_db
  sxiv_db="${XDG_DATA_HOME:-$HOME/.local/share}/sxiv/data"

  entries="$(
    {
      _FASD_DATA="$z" fasd -Rdl 2>/dev/null || true
      _FASD_DATA="$sxiv_db" fasd -Rdl 2>/dev/null || true
    } \
    | awk '{ $1=""; sub(/^ +/, ""); print }' \
    | awk -v pic="$pics_dir" 'index($0, pic) == 1' \
    | sed "s:^$HOME:~:" \
    | awk 'NF' \
    | sort -u
  )"

  if [ -z "$entries" ]; then
    entries="$(
      {
        printf '%s\n' "$pics_dir"
        if command -v fd >/dev/null 2>&1; then
          fd -td -d 3 . "$pics_dir" 2>/dev/null
        else
          find "$pics_dir" -maxdepth 3 -type d -print 2>/dev/null
        fi
      } \
      | sed "s:^$HOME:~:" \
      | awk 'NF' \
      | sort -u
    )"
  fi

  printf '%s\n' "$entries" \
    | sh -c "$rofi_cmd -p \"⟬$prompt⟭ ❯>\"" \
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
    # Avoid swayimg crash when current list ends after move: switch away first
    if [ "$cmd" = "mv" ]; then
      _ipc_send "prev_file"
    fi
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

wall() { # wall <mode> <file> via swww
  local mode="$1" file="$2"
  ensure_swww
  render_for_mode "$mode" "$file"
  # Allow user to override transition opts via $SWWW_FLAGS
  swww img "${SWWW_IMAGE_OVERRIDE:-$tmp_wall}" ${SWWW_FLAGS:-} >/dev/null 2>&1 || true
  echo "$file" >> "${XDG_DATA_HOME:-$HOME/.local/share}/wl/wallpaper.list" 2>/dev/null || true
}

finish() { rm -f "$ff" "$tmp_wall" 2>/dev/null || true; }
trap finish EXIT

# ---- dispatch --------------------------------------------------------------
action="${1:-}"; file="${2:-}"

case "$action" in
  rotate-left) printf '%s\n' "$file" | rotate 270 ;;
  rotate-right) printf '%s\n' "$file" | rotate 90 ;;
  rotate-180) printf '%s\n' "$file" | rotate 180 ;;
  rotate-ccw) printf '%s\n' "$file" | rotate -90 ;;
  copyname) copy_name "$file" ;;
  repeat) repeat_action "$file" ;;
  mv) proc mv "$file" "${3:-}" ;;
  cp) proc cp "$file" "${3:-}" ;;
  wall-mono) wall mono "$file" ;;
  wall-fill) wall fill "$file" ;;
  wall-full) wall full "$file" ;;
  wall-tile) wall tile "$file" ;;
  wall-center) wall center "$file" ;;
  wall-cover) wall cover "$file" ;;
  *) echo "Unknown action: $action" >&2; exit 2 ;;
esac
