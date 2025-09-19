{
  lib,
  config,
  inputs,
  hy3,
  ...
}:
with lib; let
  cfg = config.features;
  # Use a local mkBool to avoid early dependency on config.lib.neg during option evaluation
  mkBool = (desc: default: (lib.mkEnableOption desc) // {inherit default;});
  # Read dev-speed mode from environment (HM_DEV_SPEED=1|true|yes)
  devSpeedEnv =
    let v = builtins.getEnv "HM_DEV_SPEED";
    in v == "1" || v == "true" || v == "yes";
in {
  options.features = {
    # Global package exclusions for curated lists in modules that adopt this filter.
    excludePkgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of package names (pname) to exclude from curated home.packages lists.";
    };
    profile = mkOption {
      type = types.enum ["full" "lite"];
      default = "full";
      description = "Profile preset that adjusts feature defaults: full or lite.";
    };

    gui.enable = mkBool "enable GUI stack (wayland/hyprland, quickshell, etc.)" true;
    gui.qt.enable = mkBool "enable Qt integrations for GUI (qt6ct, hyprland-qt-*)" true;
    mail.enable = mkBool "enable Mail stack (notmuch, isync, vdirsyncer, etc.)" true;
    mail.vdirsyncer.enable = mkBool "enable Vdirsyncer sync service/timer" true;
    hack.enable = mkBool "enable Hack/security tooling stack" true;
    dev = {
      enable = mkBool "enable Dev stack (toolchains, editors, hack tooling)" true;
      ai = {
        enable = mkBool "enable AI tools (e.g., LM Studio)" true;
      };
      haskell = {
        enable = mkBool "enable Haskell tooling (ghc, cabal, stack, HLS)" true;
      };
    };

    web = {
      enable = mkBool "enable Web stack (browsers + tools)" true;
      tools.enable = mkBool "enable web tools (aria2, yt-dlp, misc)" true;
      addonsFromNUR.enable = mkBool "install Mozilla addons from NUR packages (heavier eval)" true;
      floorp.enable = mkBool "enable Floorp browser" true;
      firefox.enable = mkBool "enable Firefox browser" false;
      librewolf.enable = mkBool "enable LibreWolf browser" false;
      nyxt.enable = mkBool "enable Nyxt browser" true;
      yandex.enable = mkBool "enable Yandex browser" true;
      prefs = {
        fastfox.enable = mkBool "enable FastFox-like perf prefs for Mozilla browsers" true;
      };
    };

    media = {
      audio = {
        core.enable = mkBool "enable audio core (PipeWire routing tools)" true;
        apps.enable = mkBool "enable audio apps (players, tools)" true;
        creation.enable = mkBool "enable audio creation stack (DAW, synths)" true;
        mpd.enable = mkBool "enable MPD stack (mpd, clients, mpdris2)" true;
      };
    };

    emulators = {
      retroarch.full = mkBool "use retroarchFull with extended (unfree) cores" false;
    };

    # Torrent stack (Transmission and related tools/services)
    torrent = {
      enable = mkBool "enable Torrent stack (Transmission, tools, services)" true;
    };

    # Fun/extras (e.g., curated art assets) that are nice-to-have
    fun = {
      enable = mkBool "enable fun extras (art collections, etc.)" true;
    };

    # GPG stack (gpg, gpg-agent, pinentry)
    gpg.enable = mkBool "enable GPG and gpg-agent (creates ~/.gnupg)" true;

    # Development-speed mode: aggressively trim heavy features/inputs for faster local iteration
    devSpeed.enable = mkBool "enable dev-speed mode (trim heavy features for faster eval)" false;
  };

  # Apply profile defaults. Users can still override flags after this.
  config = mkMerge [
    (mkIf (cfg.profile == "lite") {
      # Slim defaults for lite profile
      features = {
        torrent.enable = mkDefault false;
        gui.enable = mkDefault false;
        mail.enable = mkDefault false;
        hack.enable = mkDefault false;
        dev = {
          enable = mkDefault false;
          ai.enable = mkDefault false;
        };
        media.audio = {
          core.enable = mkDefault false;
          apps.enable = mkDefault false;
          creation.enable = mkDefault false;
          mpd.enable = mkDefault false;
        };
        web = {
          enable = mkDefault false;
          tools.enable = mkDefault false;
          addonsFromNUR.enable = mkDefault false;
          floorp.enable = mkDefault false;
          yandex.enable = mkDefault false;
          prefs.fastfox.enable = mkDefault false;
        };
        emulators.retroarch.full = mkDefault false;
        fun.enable = mkDefault false;
      };
    })
    (mkIf (cfg.profile == "full") {
      # Rich defaults for full profile
      features = {
        torrent.enable = mkDefault true;
        web = {
          enable = mkDefault true;
          tools.enable = mkDefault true;
          addonsFromNUR.enable = mkDefault true;
          floorp.enable = mkDefault true;
          firefox.enable = mkDefault false;
          librewolf.enable = mkDefault false;
          nyxt.enable = mkDefault true;
          yandex.enable = mkDefault true;
          prefs.fastfox.enable = mkDefault true;
        };
        media.audio = {
          core.enable = mkDefault true;
          apps.enable = mkDefault true;
          creation.enable = mkDefault true;
          mpd.enable = mkDefault true;
        };
        emulators.retroarch.full = mkDefault true;
        fun.enable = mkDefault true;
        dev.ai.enable = mkDefault true;
      };
    })
    # When dev-speed is enabled, prefer lean defaults for heavy subfeatures
    (mkIf cfg.devSpeed.enable {
      features = {
        web = {
          tools.enable = mkDefault false;
          addonsFromNUR.enable = mkDefault false;
          floorp.enable = mkDefault false;
          firefox.enable = mkDefault false;
          librewolf.enable = mkDefault false;
          nyxt.enable = mkDefault false;
          yandex.enable = mkDefault false;
          prefs.fastfox.enable = mkDefault false;
        };
        gui.qt.enable = mkDefault false;
        fun.enable = mkDefault false;
        dev.ai.enable = mkDefault false;
        torrent.enable = mkDefault false;
      };
    })
    # If parent feature is disabled, default child toggles to false to avoid contradictions
    (mkIf (! cfg.web.enable) {
      # Parent off must force-disable children to avoid priority conflicts
      features.web = {
        tools.enable = mkForce false;
        addonsFromNUR.enable = mkForce false;
        floorp.enable = mkForce false;
        firefox.enable = mkForce false;
        librewolf.enable = mkForce false;
        nyxt.enable = mkForce false;
        yandex.enable = mkForce false;
        prefs.fastfox.enable = mkForce false;
      };
    })
    (mkIf (! cfg.dev.enable) {
      features.dev.ai.enable = mkDefault false;
    })
    (mkIf (! cfg.dev.haskell.enable) {
      # When Haskell tooling is disabled, proactively exclude common Haskell tool pnames
      # from curated package lists that honor features.excludePkgs via config.lib.neg.pkgsList.
      features.excludePkgs =
        mkAfter [
          "ghc"
          "cabal-install"
          "stack"
          "haskell-language-server"
          "hlint"
          "ormolu"
          "fourmolu"
          "hindent"
          "ghcid"
        ];
    })
    (mkIf (! cfg.gui.enable) {
      features.gui = {
        qt.enable = mkDefault false;
      };
    })
    (mkIf (! cfg.mail.enable) {
      features.mail = {};
    })
    (mkIf (! cfg.hack.enable) {
      features.hack = {};
    })
    # Consistency assertions for nested flags
    {
      assertions =
        # Hypr/hy3 compatibility check only matters when GUI is enabled
        (lib.optionals cfg.gui.enable [
          (let
            # Avoid evaluating inputs.hyprland.packages; read version from pinned ref if available.
            hyprlandRef = lib.attrByPath ["original" "ref"] null inputs.hyprland;
            hyprlandVersion = let
              # Fallback: strip leading 'v' from ref like "v0.50.1"
              refNorm =
                if hyprlandRef == null then null else
                (let s = toString hyprlandRef; in if lib.hasPrefix "v" s then builtins.substring 1 (builtins.stringLength s - 1) s else s);
            in refNorm;
            hy3Rev = lib.attrByPath ["rev"] null hy3;
            compatible = [
              { hv = "0.50.1"; rev = "1fdc0a291f8c23b22d27d6dabb466d018757243c"; }
            ];
            matches = c: (hyprlandVersion == null || hyprlandVersion == c.hv) && (hy3Rev == null || hy3Rev == c.rev);
            ok = lib.any matches compatible;
          in {
            assertion = ok;
            message = ''
              Incompatible Hyprland/hy3 pins detected.
              Expected one of: ${builtins.concatStringsSep ", " (map (c: "Hyprland " + c.hv + " + hy3 " + builtins.substring 0 7 c.rev) compatible)}
              Got: Hyprland ${toString (if hyprlandVersion == null then "<unknown>" else hyprlandVersion)} + hy3 ${toString (if hy3Rev == null then "<unknown>" else builtins.substring 0 7 hy3Rev)}
              Update flake.nix pins or extend the compatibility matrix in modules/features.nix.
            '';
          })
        ])
        ++ [
          {
            assertion = cfg.gui.enable || (! cfg.gui.qt.enable);
            message = "features.gui.qt.enable requires features.gui.enable = true";
          }
          {
            assertion = cfg.web.enable || (! cfg.web.tools.enable && ! cfg.web.floorp.enable && ! cfg.web.yandex.enable && ! cfg.web.firefox.enable && ! cfg.web.librewolf.enable && ! cfg.web.nyxt.enable);
            message = "features.web.* flags require features.web.enable = true (disable sub-flags or enable web)";
          }
          {
            assertion = ! (cfg.web.firefox.enable && cfg.web.librewolf.enable);
            message = "Only one of features.web.firefox.enable or features.web.librewolf.enable can be true";
          }
          {
            assertion = cfg.dev.enable || (! cfg.dev.ai.enable);
            message = "features.dev.ai.enable requires features.dev.enable = true";
          }
        ];
    }
    # Auto-enable dev-speed by env var
    (mkIf devSpeedEnv { features.devSpeed.enable = mkDefault true; })
  ];
}
