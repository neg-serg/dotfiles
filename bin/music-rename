#!/usr/bin/env zsh
# music-rename: rename music files/directories to a normalized scheme
# Usage: music-rename [options] PATH...
#   Renames files/dirs in-place following custom rules. Use with care.
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  sed -n '2,4p' "$0" | sed 's/^# \{0,1\}//'; exit 0
fi

typeset -A conv_table

lhs='-⟨'
rhs='⟩-'

trim() {
    local var="$@"
    var="${var#"${var%%[![:space:]]*}"}"
    echo -n "${var%"${var##*[![:space:]]}"}"
}

# MPD query: get relative path of current track (field "file:")
_current_file_path() {
    local host port pass
    host=${MPD_HOST:-localhost}
    port=${MPD_PORT:-6600}
    pass=""

    # MPD allows password in MPD_HOST like "password@host"
    if [[ "$host" == *"@"* ]]; then
        pass="${host%%@*}"
        host="${host#*@}"
    fi

    local payload
    if [[ -n "$pass" ]]; then
        payload=$'password '"$pass"$'\ncurrentsong\nclose\n'
    else
        payload=$'currentsong\nclose\n'
    fi

    if command -v nc >/dev/null 2>&1; then
        print -r -- "$payload" | nc -w 1 "$host" "$port" \
          | awk -F': ' '/^file: /{print substr($0,7); exit}'
    elif command -v socat >/dev/null 2>&1; then
        print -r -- "$payload" | socat - "TCP:$host:$port,connect-timeout=1" \
          | awk -F': ' '/^file: /{print substr($0,7); exit}'
    else
        print -u2 "Neither nc nor socat found"
        return 1
    fi
}

generate_convert_table() {
    for i in {800..889}; do q=${i:1:5}; conv_table[1$i]="18$q"; done
    for i in {890..899}; do q=${i:2:5}; conv_table[1$i]="18$q"; done
    for i in {900..989}; do q=${i:1:5}; conv_table[1$i]="1x$q"; done
    for i in {990..999}; do q=${i:2:5}; conv_table[1$i]="1x$q"; done

    i="000"
    num=$(sed "s/^000/0/" <<< "$i")
    conv_table[2$i]="2x${num}"
    for i in {001..035}; do
        num=$(sed "s/^0*//" <<< "$i")
        if [[ ${num} -lt 10 ]]; then
            conv_table[2$i]="2x$num"
        else
            j=10
            for q in {A..Z}; do
                if [[ $j == $num ]]; then
                    conv_table[2$i]="2x$q"
                fi
                ((j++))
            done
        fi
    done
}

rename_files() {
    Data=$(albumdetails "$@")
    rename "$@"
}

rename_dir() {
    if [[ -n "$1" ]]; then
        Data=$(find "$1" -exec albumdetails '{}' + 2>/dev/null)
        rename "$@"
    fi
}

extract_field() {
    rg "^$1:" <<< "$Data" | cut -d ':' -f 2-
}

rename() {
    local artist year album src music_dirname result

    artist="$(extract_field 'Artist')"
    year="$(extract_field 'Year')"
    album="$(extract_field 'Album')"

    generate_convert_table
    year=$(awk '{print $1}' <<< "$year")
    year=${year//$year/$conv_table[$year]}

    album="${album//\//-}"
    artist="${artist//\//-}"

    if [[ -d "$1" ]]; then
        src="$1"
    else
        src="$(builtin print -- "$(dirname -- "$1")")"
    fi

    artist=$(trim "$artist")
    album=$(trim "$album")
    year=$(trim "$year")

    if [[ -n "$artist" && -n "$year" && -n "$album" ]]; then
        music_dirname="$XDG_MUSIC_DIR"
        result="$music_dirname/$(basename -- "$(sed 's; ;·;g' <<< "${artist}${lhs}${year}${rhs}${album}")")"
        if [[ "$(realpath -m -- "$src")" != "$(realpath -m -- "$result")" ]]; then
            mv -i -- "$src" "$result"
        fi
        ren -i -- "$result"
        rmdir -- "$src" 2>/dev/null || true
    fi
}

main() {
    [[ -z "${1// }" ]] && exit 0
    case "$1" in
        c*)
            current_rel="$(_current_file_path)"
            [[ -z "$current_rel" ]] && { print -u2 "No current track from MPD"; exit 1; }
            dirname="$XDG_MUSIC_DIR/$(dirname -- "$current_rel")"
            rename_dir "$dirname"
        ;;
        f*)
            shift
            rename_files "$@"
        ;;
        *)
            for dir; do
                rename_dir "$dir"
            done
        ;;
    esac
}

main "$@"
