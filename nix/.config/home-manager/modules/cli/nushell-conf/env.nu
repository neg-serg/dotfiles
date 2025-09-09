# See https://www.nushell.sh/book/configuration.html
# Also see `help config env` for more options.

$env.EDITOR = "nvim"
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false
$env.error_style = "plain"
$env.config.table.mode = 'none'

# Respect XDG for Nushell state/cache and nupm
let xdg_state = ($env.XDG_STATE_HOME? | default ($nu.home-path | path join ".local" "state"))
let xdg_cache = ($env.XDG_CACHE_HOME? | default ($nu.home-path | path join ".cache"))
let xdg_data  = ($env.XDG_DATA_HOME?  | default ($nu.home-path | path join ".local" "share"))

$env.NU_CONFIG_DIR = ($env.NU_CONFIG_DIR? | default (
  ($env.XDG_CONFIG_HOME? | default ($nu.home-path | path join ".config"))
  | path join "nushell"
))
$env.NU_DATA_DIR  = ($env.NU_DATA_DIR?  | default ($xdg_state | path join "nushell"))
$env.NU_CACHE_DIR = ($env.NU_CACHE_DIR? | default ($xdg_cache | path join "nushell"))

# History location (sqlite)
$env.NU_HISTORY_PATH = ($env.NU_HISTORY_PATH? | default ($env.NU_DATA_DIR | path join "history.sqlite3"))

# Ensure dirs exist
if not ($env.NU_DATA_DIR | path exists) { mkdir $env.NU_DATA_DIR }
if not ($env.NU_CACHE_DIR | path exists) { mkdir $env.NU_CACHE_DIR }

# nupm: prefer XDG data/cache
$env.NUPM_HOME  = ($env.NUPM_HOME?  | default ($xdg_data | path join "nushell" "nupm"))
$env.NUPM_CACHE = ($env.NUPM_CACHE? | default ($env.NU_CACHE_DIR | path join "nupm"))
$env.NUPM_TEMP  = ($env.NUPM_TEMP?  | default ($nu.temp-path | path join "nupm"))
if not ($env.NUPM_HOME | path exists) { mkdir $env.NUPM_HOME }
if not ($env.NUPM_CACHE | path exists) { mkdir $env.NUPM_CACHE }

$env.config = {
  completions: {
    case_sensitive: false
    partial: true
    quick: true
    algorithm: "fuzzy"
  }
}

let carapace_completer = {|spans: list<string>|
  carapace $spans.0 nushell $spans | from json
}

$env.config = ($env.config | upsert completions {
  external: {
    enable: true
    completer: $carapace_completer
  }
})

$env.config = {
  color_config: {
    separator: white
    leading_trailing_space_bg: { attr: n }
    header: green_bold
    date: { fg: "#ff9e64" attr: b }
    filesize: cyan
    row_index: green_bold
    bool: light_cyan
    int: "#fab387"
    float: "#fab387"
    string: "#a6e3a1"
    nothing: white
    binary: purple
    cellpath: white
    hints: dark_gray
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_internalcall: blue_bold
    shape_list: blue_bold
    shape_literal: "#fab387"
    shape_nothing: light_cyan
    shape_record: blue_bold
    shape_signature: green_bold
    shape_string: "#a6e3a1"
    shape_string_interpolation: cyan
    shape_table: blue_bold
    shape_variable: purple
  }
  float_precision: 2
  buffer_editor: "nvim"
}

$env.config.history = {
  file_format: sqlite
  max_size: 1_000_000
  sync_on_enter: true
  isolation: true
}

# Also reflect the history path if supported
$env.config = ($env.config | upsert history ($env.config.history | upsert path $env.NU_HISTORY_PATH))
