{
  config,
  pkgs,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
}; {
  xdg.configFile = {
    # █▓▒░ gdb ──────────────────────────────────────────────────────────────────────────
    "gdb" = {
      source = l "${dots}/gdb/.config/gdb";
      recursive = true;
    };
    # █▓▒░ git ──────────────────────────────────────────────────────────────────────────
    "tig" = {
      source = l "${dots}/git/.config/tig";
      recursive = true;
    };
    # █▓▒░ mail ─────────────────────────────────────────────────────────────────────────
    "isync" = {
      source = l "${dots}/mail/.config/isync";
      recursive = true;
    };
    "mutt" = {
      source = l "${dots}/mail/.config/mutt";
      recursive = true;
    };
    # █▓▒░ media ────────────────────────────────────────────────────────────────────────
    "nsxiv" = {
      source = l "${dots}/media/.config/nsxiv";
      recursive = true;
    };
    # █▓▒░ misc ─────────────────────────────────────────────────────────────────────────
    "amfora" = {
      source = l "${dots}/misc/.config/amfora";
      recursive = true;
    };
    "dosbox" = {
      source = l "${dots}/misc/.config/dosbox";
      recursive = true;
    };
    "icedtea-web" = {
      source = l "${dots}/misc/.config/icedtea-web";
      recursive = true;
    };
    "stig" = {
      source = l "${dots}/misc/.config/stig";
      recursive = true;
    };
    "rustmission" = {
      source = l "${dots}/misc/.config/rustmission";
      recursive = true;
    };
    "transmission-daemon" = {
      source = l "${dots}/misc/.config/transmission-daemon";
      recursive = true;
    };
    "tridactyl" = {
      source = l "${dots}/misc/.config/tridactyl";
      recursive = true;
    };
    # █▓▒░ music ────────────────────────────────────────────────────────────────────────
    "ncpamixer.conf" = {
      source = l "${dots}/music/.config/ncpamixer.conf";
      recursive = true;
    };
    "rmpc" = {
      source = l "${dots}/music/.config/rmpc";
      recursive = true;
    };
    # █▓▒░ nix ──────────────────────────────────────────────────────────────────────────
    "home-manager" = {
      source = l "${dots}/nix/.config/home-manager";
      recursive = true;
    };
    # █▓▒░ rofi ─────────────────────────────────────────────────────────────────────────
    "rofi-pass" = {
      source = l "${dots}/rofi/.config/rofi-pass";
      recursive = true;
    };
    "rofi" = {
      source = l "${dots}/rofi/.config/rofi";
      recursive = true;
    };
    # █▓▒░ shell ──────────────────────────────────────────────────────────────────────────
    "dircolors" = {
      source = l "${dots}/shell/.config/dircolors";
      recursive = true;
    };
    "inputrc" = {
      source = l "${dots}/shell/.config/inputrc";
      recursive = true;
    };
    "tmux" = {
      source = l "${dots}/shell/.config/tmux";
      recursive = true;
    };
    "zsh" = {
      source = l "${dots}/shell/.config/zsh";
      recursive = false;
    };
    # █▓▒░ wm ────────────────────────────────────────────────────────────────────────
    "executor" = {
      source = l "${dots}/wm/.config/executor";
      recursive = true;
    };
    "greenclip" = {
      source = l "${dots}/wm/.config/greenclip.toml";
      recursive = true;
    };
    "handlr" = {
      source = l "${dots}/wm/.config/handlr";
      recursive = true;
    };
    "i3" = {
      source = l "${dots}/wm/.config/i3";
      recursive = true;
    };
    "hypr/hyprland.conf" = {
      source = l "${dots}/wm/.config/hypr/hyprland.conf";
      recursive = false;
    };
    "hypr/rules.conf" = {
      source = l "${dots}/wm/.config/hypr/rules.conf";
      recursive = false;
    };
    "hypr/bindings.conf" = {
      source = l "${dots}/wm/.config/hypr/bindings.conf";
      recursive = false;
    };
    "hypr/autostart.conf" = {
      source = l "${dots}/wm/.config/hypr/autostart.conf";
      recursive = false;
    };
    "hypr/workspaces.conf" = {
      source = l "${dots}/wm/.config/hypr/workspaces.conf";
      recursive = false;
    };
    "kitty" = {
      source = l "${dots}/wm/.config/kitty";
      recursive = true;
    };
    "negwm" = {
      source = l "${dots}/wm/.config/negwm";
      recursive = true;
    };
    "warpd" = {
      source = l "${dots}/wm/.config/warpd";
      recursive = true;
    };
  };
  xdg.dataFile = {
    "hack-art" = {
      source = l "${dots}/hack-art/.local/share/hack-art";
      recursive = true;
    };
  };
  home.file = {
    "bin" = {
      source = l "${dots}/bin";
      recursive = false;
    };
    ".ugrep" = {
      source = l "${dots}/shell/.ugrep";
      recursive = true;
    };
    ".zshenv" = {
      source = l "${dots}/shell/.zshenv";
      recursive = true;
    };
    ".xinitrc" = {
      text = ''
        xrdb -merge "$HOME/.Xresources"
        if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
            eval $(dbus-launch --exit-with-session --sh-syntax)
        fi
        systemctl --user import-environment DISPLAY XAUTHORITY MOZ_ENABLE_WAYLAND MOZ_DBUS_REMOTE QT_QPA_PLATFORM QT_QPA_PLATFORMTHEME QT_WAYLAND_DISABLE_WINDOWDECORATION SDL_VIDEODRIVER _JAVA_AWT_WM_NONREPARENTING JDK_JAVA_OPTIONS XCURSOR_SIZE XCURSOR_THEME
        if command -v dbus-update-activation-environment >/dev/null 2>&1; then
            dbus-update-activation-environment --systemd --all
        fi
        systemctl --user start --wait i3
        while true; do
            systemctl --user restart i3
            while pgrep i3; do sleep 1; done
        done
      '';
    };
    "${config.xdg.configHome}/zsh-nix/ylock" = {
      executable = true;
      text = ''
        if ! [[ $(ssh-add -L | grep "PIV AUTH") ]] && \
            [[ $(lsusb | grep "0407 Yubico") ]]; then
            ssh-add -s ${pkgs.opensc}/lib/opensc-pkcs11.so
            ssh-add -l
        fi
      '';
    };
    "${config.xdg.configHome}/nixpkgs/config.nix".text = ''
      {
          allowUnfree = true;
          permittedInsecurePackages = [
          ];
      }
    '';
  };
}
