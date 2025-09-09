{
  lib,
  config,
  ...
}: let
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
  mkSymlink = path: recursive: {
    source = l "${dots}/${path}";
    inherit recursive;
  };
in {
  xdg = {
    configFile = {
      # █▓▒░ mail ─────────────────────────────────────────────────────────────────────────
      # mutt/neomutt config is now managed via Home Manager (modules/user/mail/mutt)

      # █▓▒░ media ────────────────────────────────────────────────────────────────────────
      "swayimg" = mkSymlink "media/.config/swayimg" true;

      # █▓▒░ misc ─────────────────────────────────────────────────────────────────────────
      "amfora" = mkSymlink "misc/.config/amfora" true;
      "dosbox" = mkSymlink "misc/.config/dosbox" true;
      "icedtea-web" = mkSymlink "misc/.config/icedtea-web" true;
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
      "fuzzel" = mkSymlink "fuzzel/.config/fuzzel" true;
      "walker" = mkSymlink "walker/.config/walker" true;

      # █▓▒░ shell ────────────────────────────────────────────────────────────────────────
      "dircolors" = mkSymlink "shell/.config/dircolors" true;
      "f-sy-h" = mkSymlink "shell/.config/f-sy-h" false;
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
    dataFile."hack-art" = mkSymlink "hack-art/.local/share/hack-art" true;
    dataFile."fantasy-art" = mkSymlink "fantasy-art/.local/share/fantasy-art" true;
  };

  home.file = {
    "bin" = mkSymlink "bin" false;
    ".ugrep" = mkSymlink "shell/.ugrep" true;
    ".zshenv" = mkSymlink "shell/.zshenv" true;
    "${config.xdg.configHome}/nixpkgs/config.nix".text = let
      # Render current allowlist into a Nix list literal in the written config
      allowedList = lib.concatStringsSep " " (map (s: "\"${s}\"") config.features.allowUnfree.allowed);
    in ''
      {
        # Only allow specific unfree packages by name (synced with Home Manager)
        allowUnfreePredicate = pkg: let
          name = (pkg.pname or (builtins.parseDrvName (pkg.name or "")).name);
          allowed = [ ${allowedList} ];
        in builtins.elem name allowed;
      }
    '';
  };
}
