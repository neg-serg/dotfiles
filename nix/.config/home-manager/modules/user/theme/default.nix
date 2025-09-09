{
  lib,
  pkgs,
  iosevkaNeg,
  ...
}:
with {
  alkano-aio = pkgs.callPackage ./alkano-aio.nix {};
}; {
  home = {
    packages = with pkgs; [
      adw-gtk3 # adwaita port to gtk3
      dconf # gnome registry
      iosevkaNeg.nerd-font # install my custom iosevka build
      kdePackages.qtstyleplugin-kvantum # nice qt6 themes
      libsForQt5.qtstyleplugin-kvantum # nice qt5 themes
    ];
    pointerCursor = {
      gtk.enable = true;
      x11.enable = lib.mkForce false;
      package = lib.mkDefault alkano-aio;
      name = lib.mkDefault "Alkano-aio";
      size = lib.mkDefault 23;
    };
    sessionVariables = {
      XCURSOR_PATH = "${alkano-aio}/share/icons";
      XCURSOR_SIZE = 23;
      XCURSOR_THEME = "alkano-aio";
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = ["Cantarell"];
      sansSerif = ["Cantarell"];
      monospace = ["Iosevka"];
    };
  };

  qt = {
    platformTheme = "qt6ct";
  };

  gtk = {
    enable = true;

    font = {
      name = "Iosevka";
      size = 10;
    };

    cursorTheme = {
      name = "alkano-aio";
      package = alkano-aio;
      size = 23;
    };

    iconTheme = {
      name = "kora";
      package = pkgs.kora-icon-theme;
    };

    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = 1;
      extraCss = ''/*@import "colors.css";*/'';
    };

    gtk4 = {
      extraConfig.gtk-application-prefer-dark-theme = 1;
      extraCss = ''/*@import "colors.css";*/'';
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-key-theme = "Emacs";
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
    autoEnable = false;

    targets = {
      bemenu.enable = true;
      btop.enable = true;
      foot.enable = true;
      gnome.enable = true;
      gtk = {
        enable = false;
        flatpakSupport.enable = true;
      };
      helix.enable = true;
      sxiv.enable = false;
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
      size = 23;
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
        package = iosevkaNeg.nerd-font;
      };
      monospace = {
        name = "Iosevka";
        package = iosevkaNeg.nerd-font;
      };
      sizes = {
        applications = 10;
        desktop = 10;
      };
    };
  };
}
