MAGIC="# 🥟 pie"
THEME_FILE="${XDG_CONFIG_HOME}/f-sy-h/current_theme.zsh"
typeset -gA FAST_HIGHLIGHT_STYLES
FAST_THEME_NAME="neg"

if [ -f "$THEME_FILE" ] && tail -n1 "$THEME_FILE" | grep -Fxq "$MAGIC"; then
    return 0 2>/dev/null || exit 0
fi

typeset -gA FILE_EXTENSION_STYLES # Global associative array for file extension styles
section=""

# Process each line in the INI file
while IFS= read -r line; do
  # Clean up the line:
  line="${line%%\;*}" # Remove everything after ;
  line="${line%%\#*}" # Remove everything after #
  line="${line#"${line%%[![:space:]]*}"}" # Trim leading whitespace
  line="${line%"${line##*[![:space:]]}"}" # Trim trailing whitespace
  [[ -z "$line" ]] && continue # Skip empty lines

  # Check for section headers [section-name]
  if [[ "$line" =~ '^\[(.*)\]$' ]]; then
    section="${match[1]}"

  # Process file-extension styles
  elif [[ "$section" == "file-extensions" && "$line" =~ '^([a-zA-Z0-9_+-]+)[[:space:]]*=[[:space:]]*(.*)$' ]]; then
    key="${match[1]}"
    value="${match[2]}"
    value="${value//\"/}" # Remove double quotes

    # Transform style format for f-sy-h compatibility
    if [[ "$value" == bg:* ]]; then
      # Handle background styles (bg:color,fg,attributes)
      rest=${value#bg:} # Remove 'bg:' prefix
      parts=(${(s:,:)rest}) # Split by commas
      bg_color=${parts[1]} # First part is background color
      shift parts # Remove bg color from parts array

      new_value="bg=$bg_color" # Start with background

      # Check if next part is foreground color (numeric)
      if [[ -n "$parts[1]" && "$parts[1]" =~ '^[0-9]+$' ]]; then
        new_value+=",fg=$parts[1]" # Add foreground
        shift parts # Remove fg color
      fi

      # Add any remaining attributes (bold, underline, etc)
      [[ ${#parts} -gt 0 ]] && new_value+=",${(j:,:)parts}"
      value=$new_value

    else
      # Handle regular styles (fg=color,attributes)
      value="fg=$value" # Add fg= prefix
    fi

    FILE_EXTENSION_STYLES[$key]="$value"
  fi
done < ${XDG_CONFIG_HOME}/f-sy-h/neg.ini

# Apply styles to fast-syntax-highlighting
for ext style in "${(@kv)FILE_EXTENSION_STYLES}"; do
  [[ -n $ext && -n $style ]] || continue
  FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}file-extensions-${ext}]="$style"
  key_str="${FAST_THEME_NAME}file-extensions-${ext}"
  line=": \${FAST_HIGHLIGHT_STYLES[${key_str}]:=$style}"
  # drop old lines for this key (if any), then append the fresh one
  sed -i "/^: \${FAST_HIGHLIGHT_STYLES\\[${key_str//\//\\/}\\]:=/d}" "$THEME_FILE" 2>/dev/null
  print -r -- "$line" >> "$THEME_FILE"
done
echo "# 🥟 pie" >> $THEME_FILE
