#!/bin/sh
# unlock: unlock SSH keys (optionally Yubikey) via expect using pass(1) secrets
# Usage: unlock
pp0="$(pass show ssh-key)"
pp2="$(pass show wrk/ssh-key || true)" # unused fallback; kept for compatibility
cleanup() { unset pp0 pp1 pp2 || true; }
trap cleanup EXIT HUP INT TERM

. /etc/profile
pp0="$(pass show ssh-key)"
pp2="$(pass show wrk/ssh-key)"
if lsusb | grep -q "0407 Yubico"; then
    pp1="$(pass show pin)"
    expect << EOF
        spawn "$XDG_CONFIG_HOME/zsh-nix/ylock"
        expect "Enter passphrase"
        send "$pp1\r"
        expect eof
EOF
fi
expect << EOF
    spawn ssh-add $HOME/.ssh/id_neg
    expect "Enter passphrase"
    send "$pp0\r"
    expect eof
EOF
