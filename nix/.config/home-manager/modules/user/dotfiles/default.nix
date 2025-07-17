{ config, pkgs, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
  mkSymlink = path: recursive: {
    source = l "${dots}/${path}";
    inherit recursive;
  };
in {
  xdg.configFile = {
    # █▓▒░ gdb ──────────────────────────────────────────────────────────────────────────
    "gdb" = mkSymlink "gdb/.config/gdb" true;
    
    # █▓▒░ git ──────────────────────────────────────────────────────────────────────────
    "tig" = mkSymlink "git/.config/tig" true;
    
    # █▓▒░ mail ─────────────────────────────────────────────────────────────────────────
    "isync" = mkSymlink "mail/.config/isync" true;
    "mutt" = mkSymlink "mail/.config/mutt" true;
    
    # █▓▒░ media ────────────────────────────────────────────────────────────────────────
    "nsxiv" = mkSymlink "media/.config/nsxiv" true;
    
    # █▓▒░ misc ─────────────────────────────────────────────────────────────────────────
    "amfora" = mkSymlink "misc/.config/amfora" true;
    "dosbox" = mkSymlink "misc/.config/dosbox" true;
    "icedtea-web" = mkSymlink "misc/.config/icedtea-web" true;
    "stig" = mkSymlink "misc/.config/stig" true;
    "rustmission" = mkSymlink "misc/.config/rustmission" true;
    "transmission-daemon" = mkSymlink "misc/.config/transmission-daemon" true;
    "tridactyl" = mkSymlink "misc/.config/tridactyl" true;
    
    # █▓▒░ music ────────────────────────────────────────────────────────────────────────
    "ncpamixer.conf" = mkSymlink "music/.config/ncpamixer.conf" true;
    "rmpc" = mkSymlink "music/.config/rmpc" true;
    
    # █▓▒░ nix ──────────────────────────────────────────────────────────────────────────
    "home-manager" = mkSymlink "nix/.config/home-manager" true;
    
    # █▓▒░ launcher ─────────────────────────────────────────────────────────────────────
    "rofi" = mkSymlink "rofi/.config/rofi" true;
    "tofi" = mkSymlink "tofi/.config/tofi" true;
    "fuzzel" = mkSymlink "fuzzel/.config/fuzzel" true;
    
    # █▓▒░ shell ────────────────────────────────────────────────────────────────────────
    "dircolors" = mkSymlink "shell/.config/dircolors" true;
    "inputrc" = mkSymlink "shell/.config/inputrc" true;
    "nushell" = mkSymlink "shell/.config/nushell" true;
    "tmux" = mkSymlink "shell/.config/tmux" true;
    "zsh" = mkSymlink "shell/.config/zsh" false;

    # █▓▒░ wm ───────────────────────────────────────────────────────────────────────────
    "handlr" = mkSymlink "wm/.config/handlr" true;
    "kitty" = mkSymlink "wm/.config/kitty" true;
    
    # Hyprland configuration files
    "hypr/init.conf" = mkSymlink "wm/.config/hypr/init.conf" false;
    "hypr/rules.conf" = mkSymlink "wm/.config/hypr/rules.conf" false;
    "hypr/bindings.conf" = mkSymlink "wm/.config/hypr/bindings.conf" false;
    "hypr/autostart.conf" = mkSymlink "wm/.config/hypr/autostart.conf" false;
    "hypr/workspaces.conf" = mkSymlink "wm/.config/hypr/workspaces.conf" false;
    "hypr/pyprland.toml" = mkSymlink "wm/.config/hypr/pyprland.toml" false;

    # █▓▒░ quickshell ───────────────────────────────────────────────────────────────────
    "quickshell" = mkSymlink "quickshell/.config/quickshell" true;
  };

  xdg.dataFile."hack-art" = mkSymlink "hack-art/.local/share/hack-art" true;
  xdg.dataFile."fantasy-art" = mkSymlink "fantasy-art/.local/share/fantasy-art" true;

  home.file = {
    "bin" = mkSymlink "bin" false;
    ".ugrep" = mkSymlink "shell/.ugrep" true;
    ".zshenv" = mkSymlink "shell/.zshenv" true;
    "${config.xdg.configHome}/nixpkgs/config.nix".text = ''{ allowUnfree = true; }'';
  };
}
