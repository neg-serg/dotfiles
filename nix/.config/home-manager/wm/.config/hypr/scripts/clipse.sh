#!/usr/bin/env bash
set -euo pipefail

# Toggle existing instance
if hyprctl -j clients 2>/dev/null | jq -e '.[] | select(.class=="clipse")' >/dev/null 2>&1; then
  # Try to close gracefully, then force
  hyprctl dispatch focuswindow "class:clipse" >/dev/null 2>&1 || true
  hyprctl dispatch killactive >/dev/null 2>&1 || true
  exit 0
fi

KITTY=${KITTY:-kitty}
CFG="$HOME/.config/kitty/clipse.conf"
CLASS=clipse

CMD=("$KITTY" --class "$CLASS" --title "Clipse" --config "$CFG" clipse)

# Launch
"${CMD[@]}" &

# Wait a moment for the window to appear
tries=0
while ! hyprctl -j clients | jq -e '.[] | select(.class=="clipse")' >/dev/null 2>&1; do
  sleep 0.05
  tries=$((tries+1))
  [ $tries -gt 60 ] && break
done

# Focus and make floating
hyprctl dispatch focuswindow "class:clipse" >/dev/null 2>&1 || true
hyprctl dispatch togglefloating >/dev/null 2>&1 || true

# Resize to a comfortable size (px)
W=820
H=520
hyprctl dispatch resizeactive exact $W $H >/dev/null 2>&1 || true

# Compute bottom-left coordinates on focused monitor
MON_JSON=$(hyprctl -j monitors)
FMON=$(printf '%s' "$MON_JSON" | jq -r '.[] | select(.focused==true)')
MX=$(printf '%s' "$FMON" | jq -r '.x')
MY=$(printf '%s' "$FMON" | jq -r '.y')
MH=$(printf '%s' "$FMON" | jq -r '.height')

MARGIN=12
X=$((MX + MARGIN))
Y=$((MY + MH - H - MARGIN))

hyprctl dispatch moveactive exact $X $Y >/dev/null 2>&1 || true

exit 0

