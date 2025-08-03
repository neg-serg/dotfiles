# See https://www.nushell.sh/book/configuration.html
# Also see `help config env` for more options.

$env.EDITOR = "nvim"
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false
$env.error_style = "plain"
$env.config.table.mode = 'none'

$env.config = {
  completions: {
    case_sensitive: false   # Нечувствительность к регистру
    partial: true           # Частичное дополнение
    quick: true             # Показывать меню сразу
    algorithm: "fuzzy"      # Использовать нечёткий поиск
  }
}

$env.config = {
  color_config: {
    separator: "#blue"
    header: "#7c90a8"
    example: "#green"
  }
}

# export-env {
#   $env.config.color_config.separator = "#162b44"
#   # $env.config.color_config.leading_trailing_space_bg = "#ffffff"
#   # $env.config.color_config.header = "gb"
#   # $env.config.color_config.date = "wd"
#   # $env.config.color_config.filesize = "c"
#   # $env.config.color_config.row_index = "cb"
#   # $env.config.color_config.bool = "red"
#   # $env.config.color_config.int = "green"
#   # $env.config.color_config.duration = "blue_bold"
#   # $env.config.color_config.range = "purple"
#   # $env.config.color_config.float = "red"
#   # $env.config.color_config.string = "white"
#   # $env.config.color_config.nothing = "red"
#   # $env.config.color_config.binary = "red"
#   # $env.config.color_config.cellpath = "cyan"
#   # $env.config.color_config.hints = "dark_gray"
# }

$env.config.history = {
  file_format: sqlite
  max_size: 1_000_000
  sync_on_enter: true
  isolation: true
}
