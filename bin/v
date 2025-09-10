#!/bin/sh
# v: open Neovim with system profile sourced
# Usage: v [ARGS...]
. /etc/profile
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  printf "v: wrapper for nvim (sources /etc/profile)\n" >&2
  exit 0
fi
nvim "$@"
# vim:filetype=sh
