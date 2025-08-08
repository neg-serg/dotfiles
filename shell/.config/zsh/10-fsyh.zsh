while read line; do
  if [[ "$line" =~ "\[(.+)\]" ]]; then
    section=${match[1]}
  elif [[ "$section" == "file-extensions" && "$line" =~ "([^ ]+) *= *(.*)" ]]; then
    FILE_EXTENSION_STYLES[${match[1]}]=${match[2]}
  fi
done < neg.ini
