#!/usr/bin/env zsh
set -euo pipefail
typeset -A bystyle
while IFS= read -r line; do
  [[ $line =~ '\$\{FAST_HIGHLIGHT_STYLES\[negfile-extensions-([A-Za-z0-9_+-]+)\]:=([^}]+)\}' ]] || continue
  ext="${match[1]}"; style="${match[2]}"
  ext="${ext:l}"                     # в нижний регистр
  bystyle[$style]="${bystyle[$style]-} $ext"
done < "${1:-/dev/stdin}"

print 'typeset -gA FAST_HIGHLIGHT_STYLES'
print 'FAST_THEME_NAME=${FAST_THEME_NAME:-neg}'
print '_setstyle(){ local k=$1 v=$2; [[ -n ${FAST_HIGHLIGHT_STYLES[$k]-} ]] || FAST_HIGHLIGHT_STYLES[$k]=$v; }'
for style exts in ${(kv)bystyle}; do
  print "for ext in${(j: :)=exts}; do _setstyle \"\${FAST_THEME_NAME}file-extensions-\$ext\" \"$style\"; done"
done
print '# 🥟 pie'
