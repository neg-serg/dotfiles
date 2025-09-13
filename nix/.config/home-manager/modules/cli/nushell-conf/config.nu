source ~/.config/nushell/aliases.nu
source ~/.config/nushell/git.nu
source ~/.config/nushell/broot.nu
use ~/.config/nushell/git-completion.nu *

# Add bebexpand plugin only if installed locally
let _bexpand_path = ("~/.local/share/cargo/bin/nu_plugin_bexpand" | path expand)
if ($_bexpand_path | path exists) {
  plugin add $_bexpand_path
}

# Initialize oh-my-posh only if available
if not (which oh-my-posh | is-empty) {
  oh-my-posh init nu
}
