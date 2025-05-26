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
    iosevkaneg.nerd-font # install my custom iosevka build
    kdePackages.qtstyleplugin-kvantum
    adw-gtk3 # For Adwaita-dark theme
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = alkano-aio;
    name = "alkano-aio";
    size = 23;
  };

  home.sessionVariables = {
    XCURSOR_PATH = "${alkano-aio}/share/icons";
    XCURSOR_SIZE = 23;
    XCURSOR_THEME = "alkano-aio";
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Cantarell" ];
      sansSerif = [ "Cantarell" ];
      monospace = [ "Iosevka" ];
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

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
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
}
