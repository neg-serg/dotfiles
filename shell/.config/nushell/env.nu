# See https://www.nushell.sh/book/configuration.html
# Also see `help config env` for more options.

$env.EDITOR = "nvim"
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false
$env.error_style = "plain"
$env.config.table.mode = 'none'

$env.config = {
  completions: {
    case_sensitive: false
    partial: true
    quick: true
    # algorithm: "fuzzy"
#   menu: {
#     columns: 4
#     col_width: 20
#     col_padding: 2
#     selection_rows: 4
#     description_rows: 10
#   }
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
