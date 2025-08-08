setopt rematchpcre
typeset -A FILE_EXTENSION_STYLES
section=""
while read line; do
  if [[ "$line" =~ '^\[(.+)\]' ]]; then
    section=${match[1]}
  elif [[ "$section" == "file-extensions" && "$line" =~ '^([^ =]+)[ \t]*=[ \t]*(.+)$' ]]; then
    FILE_EXTENSION_STYLES[${match[1]}]=${match[2]}
  fi
done < ${ZDOTDIR}/neg.ini
