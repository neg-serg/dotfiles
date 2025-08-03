# env.nu
#
# Installed by:
# version = "0.105.1"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.


$env.config.hooks.pre_prompt = [
  {|| echo "Ready to rock 🤘" }
]

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
