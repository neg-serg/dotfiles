{
  pkgs,
  iosevkaneg,
  ...
}:
with {
  alkano-aio = pkgs.callPackage ./alkano-aio.nix {};
}; {
  home.packages = with pkgs; [
    dconf # gnome registry
  ];

  gtk = {
    iconTheme = {
      name = "kora";
      package = pkgs.kora-icon-theme;
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-key-theme = "emacs";
        icon-theme = "kora";
        font-hinting = "hintsfull";
        font-antialiasing = "grayscale";
      };
      "org/gnome/desktop/privacy".remember-recent-files = false;
      "org/gnome/desktop/screensaver".lock-enabled = false;
      "org/gnome/desktop/session".idle-delay = 0;
      "org/gtk/gtk4/settings/file-chooser" = {
        sort-directories-first = true;
        show-hidden = true;
        view-type = "list";
      };
      "org/gtk/settings/file-chooser" = {
        date-format = "regular";
        location-mode = "path-bar";
        show-hidden = false;
        show-size-column = true;
        show-type-column = true;
        sidebar-width = 189;
        sort-column = "name";
        sort-directories-first = false;
        sort-order = "descending";
        type-format = "category";
      };
    };
  };

  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://i.imgur.com/HbYZDyA.jpeg";
      sha256 = "sha256-Axp121bLA7vMXCmpB/K2jaFR3PldUxOHfbWJxKV5Z8w=";
    };

    targets = {
      dunst.enable = false;
      firefox.profileNames = ["8ymzp4k3.default"];
      hyprpaper.enable = false;
      kitty.enable = false;
      zathura.enable = false;
    };

    base16Scheme = {
      base00 = "#020202"; # Background
      base01 = "#010912"; # Alternate background(for toolbars)
      base02 = "#0f2329"; # Scrollbar highlight ???
      base03 = "#15181f"; # Selection background
      base04 = "#6c7e96"; # Alternate(darker) text
      base05 = "#8d9eb2"; # Default text
      base06 = "#ff0000"; # Light foreground (not often used)
      base07 = "#00ff00"; # Light background (not often used)
      base08 = "#8a2f58"; # Error (I use red for it)
      base09 = "#914e89"; # Urgent (I use magenta or yellow for it)
      base0A = "#005faf"; # Warning, progress bar, text selection
      base0B = "#005200"; # Green
      base0C = "#005f87"; # Cyan
      base0D = "#0a3749"; # Alternative window border
      base0E = "#5B5BBB"; # Purple
      base0F = "#162b44"; # Brown
    };

    cursor = {
      size = 35;
      name = "Alkano-aio";
      package = alkano-aio;
    };

    polarity = "dark";

    fonts = {
      serif = {
        name = "Cantarell";
        package = pkgs.cantarell-fonts;
      };
      sansSerif = {
        name = "Iosevka";
        package = iosevkaneg.nerd-font;
      };
      monospace = {
        name = "Iosevka";
        package = iosevkaneg.nerd-font;
      };
      sizes = {
        applications = 10;
        desktop = 10;
      };
    };
  };
}
