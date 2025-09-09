# --- Alt-<digit> quick cd with instant p10k refresh ---
# 1) Directories for Alt-1..9 (edit to taste)
typeset -ga NEGCD_DIRS=(
  "$HOME/1st_level"
  "$HOME/dw"
  "${XDG_CONFIG_HOME:-$HOME/.config}/home-manager"
  "/etc/nixos"
  # add more...
)

# 2) One widget handles both ESC+digit and xterm-style Alt+digit sequences
negcd_widget() {
  local seq=$KEYS idx
  case $seq in
    ($'\e'[1-9]) idx=${seq[-1]} ;; # ESC + 1..9
    ($'\e'[0]) idx=10 ;; # (optional) ESC + 0 -> 10th
    ($'\e[''1;3'[0-9]~) idx=${seq[-2]} ;; # xterm Alt+digit: ^[[1;3X~
    (*) return 0 ;;
  esac

  (( idx >= 1 && idx <= ${#NEGCD_DIRS} )) || { zle -M "No directory assigned for $idx"; return 0; }

  if builtin cd -- "${NEGCD_DIRS[idx]}"; then
    # Tell Powerlevel10k we changed dir and a prompt will be drawn
    (( $+functions[p10k-on-chpwd]  )) && p10k-on-chpwd
    (( $+functions[p10k-on-precmd] )) && p10k-on-precmd
    redraw-prompt # Rebuild & repaint prompt IN PLACE (no new line)
    zle .reset-prompt
    zle -R
  fi
}
zle -N negcd_widget

# 3) Bind Alt-1..9 in both common formats
for i in {1..9}; do
  bindkey "^[${i}" negcd_widget # ESC + digit (most terminals)
  bindkey $'^[[1;3'"$i"$'~' negcd_widget # xterm Alt+digit
done
bindkey "^[0" negcd_widget # (optional) ESC + 0
bindkey $'^[[1;30~' negcd_widget # (optional) xterm Alt+0
