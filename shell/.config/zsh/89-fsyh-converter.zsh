#!/usr/bin/env zsh

# Converter: f-sy-h styles → INI format
input_file="styles"
output_file="file-extensions.ini"

# Create INI section header
echo "[file-extensions]" > $output_file
echo "; File extension highlight styles" >> $output_file
echo "; 'fg=' can be omitted, 'bg=' becomes 'bg:'" >> $output_file
echo >> $output_file

# Function: convert a style string
convert_style() {
    local style=$1
    style=${style//bg=/bg:} # replace bg= with bg:
    style=${style//fg=/} # remove fg=
    echo $style | sed 's/^,//; s/,$//; s/,,/,/g' # clean up commas
}

# Process each matching line
grep 'FAST_HIGHLIGHT_STYLES\[ftype-' $input_file | while read line
do
    if [[ $line =~ "ftype-([a-zA-Z0-9_]+)" ]]; then
        extension="${match[1]}"
        style_value="${line#*:=}"
        style_value="${style_value%\}*}"
        
        # Convert and write
        new_style=$(convert_style "$style_value")
        printf "%-8s = %s\n" "$extension" "$new_style" >> $output_file
    fi
done

# Optional: Add 24-bit color examples
cat <<EOT >> $output_file

; Example 24-bit color styles
; txt     = #1e88e5
; py      = #306998,bg:#FFD43B,bold
; js      = #f0db4f,bg:#323330
; css     = #264de4,bg:#2965f1,underline
EOT

echo "Conversion complete. Output saved to $output_file"
