{
  config,
  pkgs,
  iosevkaneg,
  ...
}:
with {
  alkano-aio = pkgs.callPackage ./alkano-aio.nix {};
}; {
  home.packages = with pkgs; [
    dconf # gnome registry
    libsForQt5.qt5ct # kvantum theme support
    libsForQt5.qtstyleplugin-kvantum # kvantum theme support
    qt6Packages.qtstyleplugin-kvantum # kvantum theme support
  ];

  gtk = {
    iconTheme = {
      name = "kora";
      package = pkgs.kora-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme = "qtct";
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

  home.file = {
    "${config.xdg.configHome}/xinit/xsettingsd".text = ''
      # Used by xsettingsd-setup
      Net/IconThemeName "kora" # gtk-icon-theme-name
      Net/EnableEventSounds 0
      Gtk/FontName "Iosevka 10"
      Gtk/KeyThemeName "Emacs"
      Gtk/ButtonImages 1
      Gtk/MenuImages 1
      Gtk/DecorationLayout ":menu"
    '';
  };

  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://i.imgur.com/t3bTk2b.jpg";
      sha256 = "sha256-WVDIxyy9ww39JNFkMOJA2N6KxLMh9cKjmeQwLY7kCjk=";
    };

    targets = {
      kitty.enable = false;
      zathura.enable = false;
      dunst.enable = false;
    };

    base16Scheme = {
      base00 = "#020202"; # Background
      base01 = "#010912"; # Alternate background(for toolbars)
      base02 = "#8d9eb2"; # Scrollbar highlight ???
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
        name = "Cantarell";
        package = pkgs.cantarell-fonts;
      };
      monospace = {
        name = "Iosevka";
        package = iosevkaneg.nerd-font;
        # package = pkgs.iosevka.override {
        #   set = "neg";
        #   privateBuildPlan = builtins.readFile ../fonts/iosevka-neg.toml;
        # };
      };
      sizes = {
        applications = 10;
        desktop = 10;
      };
    };
  };
}
