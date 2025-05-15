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
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Cantarell" ];
      sansSerif = [ "Cantarell" ];
      monospace = [ "Iosevka" ];
    };
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
      size = 35;
    };

    iconTheme = {
      name = "kora";
      package = pkgs.kora-icon-theme;
    };

    theme = {
      name = "Tokyonight-Dark-Compact";
      package = pkgs.tokyonight-gtk-theme.override {
        colorVariants = [ "dark" ];
        sizeVariants = [ "compact" ];
        tweakVariants = [ "moon" ];
      };
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
}
