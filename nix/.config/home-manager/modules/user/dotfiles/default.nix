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
      # █▓▒░ misc ─────────────────────────────────────────────────────────────────────────
      "rustmission" = mkSymlink "misc/.config/rustmission" true;
      "transmission-daemon" = mkSymlink "misc/.config/transmission-daemon" true;
      "tridactyl" = mkSymlink "misc/.config/tridactyl" true;
      # █▓▒░ nix ──────────────────────────────────────────────────────────────────────────
      "home-manager" = mkSymlink "nix/.config/home-manager" true;
      # █▓▒░ launcher ─────────────────────────────────────────────────────────────────────
      "walker" = mkSymlink "walker/.config/walker" true;
      # █▓▒░ shell ────────────────────────────────────────────────────────────────────────
      "dircolors" = mkSymlink "shell/.config/dircolors" true;
      "f-sy-h" = mkSymlink "shell/.config/f-sy-h" false;
      "nushell" = mkSymlink "shell/.config/nushell" true;
      "zsh" = mkSymlink "shell/.config/zsh" false;
      # █▓▒░ wm ───────────────────────────────────────────────────────────────────────────
      "kitty" = mkSymlink "wm/.config/kitty" true;
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
