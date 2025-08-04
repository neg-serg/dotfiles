# config.nu
# https://www.nushell.sh/book/configuration.html
# This file is loaded after env.nu and before login.nu
# You can open this file in your default editor using: config nu
# See `help config nu` for more options

use ~/.config/nushell/nupm/nupm/
source ~/.config/nushell/aliases.nu
source ~/.config/nushell/git.nu

let carapace_completer = {|spans: list<string>|
  carapace $spans.0 nushell $spans | from json
}

$env.config = ($env.config | upsert completions {
  external: {
    enable: true
    completer: $carapace_completer
  }
})
