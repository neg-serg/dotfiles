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

$env.config.history = {
  file_format: sqlite
  max_size: 1_000_000
  sync_on_enter: true
  isolation: true
}
