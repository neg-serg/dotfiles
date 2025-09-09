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
      # █▓▒░ media ────────────────────────────────────────────────────────────────────────
      "swayimg" = mkSymlink "media/.config/swayimg" true;

      # █▓▒░ misc ─────────────────────────────────────────────────────────────────────────
      "rustmission" = mkSymlink "misc/.config/rustmission" true;
      "transmission-daemon" = mkSymlink "misc/.config/transmission-daemon" true;
      "tridactyl" = mkSymlink "misc/.config/tridactyl" true;

      # █▓▒░ music ────────────────────────────────────────────────────────────────────────
      "rmpc" = mkSymlink "music/.config/rmpc" true;

      # █▓▒░ nix ──────────────────────────────────────────────────────────────────────────
      "home-manager" = mkSymlink "nix/.config/home-manager" true;

      # █▓▒░ launcher ─────────────────────────────────────────────────────────────────────
      "rofi" = mkSymlink "rofi/.config/rofi" true;
      "walker" = mkSymlink "walker/.config/walker" true;

      # █▓▒░ shell ────────────────────────────────────────────────────────────────────────
      "dircolors" = mkSymlink "shell/.config/dircolors" true;
      "f-sy-h" = mkSymlink "shell/.config/f-sy-h" false;
      "nushell" = mkSymlink "shell/.config/nushell" true;
      "zsh" = mkSymlink "shell/.config/zsh" false;

      # █▓▒░ wm ───────────────────────────────────────────────────────────────────────────
      "kitty" = mkSymlink "wm/.config/kitty" true;

      # Hyprland configuration files (live-editable symlinks to repo files)
      # Keep these as out-of-store symlinks to allow real-time editing.
      # Files are copied into this repo under modules/user/gui/hypr/conf.
      "hypr/init.conf" = { source = l "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/user/gui/hypr/conf/init.conf"; recursive = false; };
      "hypr/rules.conf" = { source = l "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/user/gui/hypr/conf/rules.conf"; recursive = false; };
      "hypr/bindings.conf" = { source = l "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/user/gui/hypr/conf/bindings.conf"; recursive = false; };
      "hypr/autostart.conf" = { source = l "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/user/gui/hypr/conf/autostart.conf"; recursive = false; };
      "hypr/workspaces.conf" = { source = l "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/user/gui/hypr/conf/workspaces.conf"; recursive = false; };
      "hypr/pyprland.toml" = { source = l "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/user/gui/hypr/conf/pyprland.toml"; recursive = false; };

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
