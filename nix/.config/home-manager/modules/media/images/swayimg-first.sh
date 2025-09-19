#!/usr/bin/env bash
set -euo pipefail
uid="$(id -u)" # Unique socket path for this instance
rt="$XDG_RUNTIME_DIR"; [ -n "$rt" ] || rt="/run/user/$uid"
sock="$rt/swayimg-$PPID-$$-$RANDOM.sock"
# Export socket path for child exec actions to use
export SWAYIMG_IPC="$sock"
# Start swayimg with IPC enabled
"@SWAYIMG_BIN@" --ipc="$sock" "$@" &
pid=$!
i=0
while :; do
  if ! kill -0 "$pid" 2>/dev/null; then break; fi
  [ -S "$sock" ] && break
  i=$((i+1))
  [ "$i" -ge 40 ] && break
  sleep 0.025
done # Wait until the socket appears or process exits (max ~1s)
# Send on-start action(s) if socket is ready
if [ -S "$sock" ]; then
  action="$(printenv SWAYIMG_ONSTART_ACTION 2>/dev/null || true)"
  [ -n "$action" ] || action="first_file"
  # Send each action on its own line; keep spaces intact
  printf '%s' "$action" \
      | tr ';' '\n' \
      | sed '/^[[:space:]]*$/d' \
      | "@SOCAT_BIN@" - "UNIX-CONNECT:$sock" >/dev/null 2>&1 || true
fi
wait "$pid" # Forward exit code
rc=$?
[ -S "$sock" ] && rm -f "$sock" || true # Best-effort cleanup
exit $rc
