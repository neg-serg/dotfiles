# config.nu
# https://www.nushell.sh/book/configuration.html
# This file is loaded after env.nu and before login.nu
# You can open this file in your default editor using: config nu
# See `help config nu` for more options

use ~/.config/nushell/nupm/nupm/

alias gs = git status
alias l = eza --icons=auto --hyperlink
alias lcr = eza --icons=auto --hyperlink -al --sort=created --color=always # | tail -14
alias lsd = eza --icons=auto --hyperlink -alD --sort=created --color=always # | tail -14
alias ll = eza --icons=auto --hyperlink -l
alias cp = cp --reflink=auto

$env.EDITOR = "nvim"
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false
$env.error_style = "plain"
$env.config.table.mode = 'none'
$env.config.color_config = {
  header_fg: '#7c90a8'
}

$env.config.history = {
  file_format: sqlite
  max_size: 1_000_000
  sync_on_enter: true
  isolation: true
}

def greet [name:string] {
  echo $"Hello, ($name)!"
}

$env.config.hooks.pre_prompt = [
  {|| echo "Ready to rock 🤘" }
]

$env.config.color_config.separator = "#162b44"
# $env.config.color_config.leading_trailing_space_bg = "#ffffff"
# $env.config.color_config.header = "gb"
# $env.config.color_config.date = "wd"
# $env.config.color_config.filesize = "c"
# $env.config.color_config.row_index = "cb"
# $env.config.color_config.bool = "red"
# $env.config.color_config.int = "green"
# $env.config.color_config.duration = "blue_bold"
# $env.config.color_config.range = "purple"
# $env.config.color_config.float = "red"
# $env.config.color_config.string = "white"
# $env.config.color_config.nothing = "red"
# $env.config.color_config.binary = "red"
# $env.config.color_config.cellpath = "cyan"
# $env.config.color_config.hints = "dark_gray"
