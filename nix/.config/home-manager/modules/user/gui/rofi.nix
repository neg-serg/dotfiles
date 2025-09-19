{ lib, pkgs, config, xdg, ... }:
with lib;
  mkIf config.features.gui.enable (let
    rofiPkg = (pkgs.rofi.override {
      plugins = [
        pkgs.rofi-file-browser
        pkgs.neg.rofi_games
      ];
    });
    xdgDataHome = config.xdg.dataHome or ("${config.home.homeDirectory}/.local/share");
    xdgConfigHome = config.xdg.configHome or ("${config.home.homeDirectory}/.config");
    # Build theme link descriptors from a compact list of relative paths.
    themeFiles = [
      "theme.rasi"
      "common.rasi"
      "clip.rasi"
      "sxiv.rasi"
      "win/left_btm.rasi"
    ];
    themeLinks = map (rel: {
      dst = "rofi/themes/${rel}";
      src = "conf/${rel}";
    }) themeFiles;
  in lib.mkMerge ([
    {
      home.packages = config.lib.neg.pkgsList [
        pkgs.rofi-pass-wayland # pass interface for rofi-wayland
        rofiPkg # modern dmenu alternative with plugins
        # cliphist is provided in gui/apps.nix; no need for greenclip/clipmenu
      ];
    }
    # Wrap rofi to ensure '-theme <name|name.rasi>' works even when caller uses a relative theme path.
    # If a theme is given without a path, we cd into the themes directory so rofi finds the file.
    (let
       tpl = builtins.readFile ./rofi/rofi-wrapper.sh;
       rendered = lib.replaceStrings ["@ROFI_BIN@" "@JQ_BIN@" "@HYPRCTL_BIN@"] [ (lib.getExe rofiPkg) (lib.getExe pkgs.jq) (lib.getExe' pkgs.hyprland "hyprctl") ] tpl;
       rofiWrapper = pkgs.writeShellApplication {
         name = "rofi-wrapper";
         runtimeInputs = [ pkgs.gawk pkgs.gnused ];
         text = rendered;
       };
     in {
       home.file.".local/bin/rofi".source = "${rofiWrapper}/bin/rofi-wrapper";
     })
    # Live-editable config via helper (guards parent dir and target)
    (xdg.mkXdgSource "rofi" {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/rofi/conf";
      recursive = true;
    })
  ]
  ++ (map (e: xdg.mkXdgDataSource e.dst { source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/rofi/${e.src}"; recursive = false; }) themeLinks)
  ++ [{
    # Clean up leftovers from pre-refactor
    home.activation.cleanupRofiLeftovers =
      let ch = xdgConfigHome; d = xdgDataHome; in
      config.lib.neg.mkEnsureAbsentMany [
        "${d}/rofi/themes/win/center_btm.rasi"
        "${d}/rofi/themes/win/no_gap.rasi"
        "${d}/rofi/themes/neg.rasi"
        "${d}/rofi/themes/pass.rasi"
        "${ch}/rofimoji"
        "${d}/applications/rofimoji.desktop"
      ];
  }])
)
