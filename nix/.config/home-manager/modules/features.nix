{
  lib,
  config,
  pkgs,
  inputs,
  hy3,
  ...
}:
with lib; let
  cfg = config.features;
  mkBool =
    if (config ? lib) && (config.lib ? neg) && (config.lib.neg ? mkBool)
    then config.lib.neg.mkBool
    else (desc: default: (lib.mkEnableOption desc) // {inherit default;});
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
    mail.enable = mkBool "enable Mail stack (notmuch, isync, vdirsyncer, etc.)" true;
    mail.vdirsyncer.enable = mkBool "enable Vdirsyncer sync service/timer" true;
    hack.enable = mkBool "enable Hack/security tooling stack" true;
    dev = {
      enable = mkBool "enable Dev stack (toolchains, editors, hack tooling)" true;
      ai = {
        enable = mkBool "enable AI tools (e.g., LM Studio)" true;
      };
    };

    web = {
      enable = mkBool "enable Web stack (browsers + tools)" true;
      tools.enable = mkBool "enable web tools (aria2, yt-dlp, misc)" true;
      floorp.enable = mkBool "enable Floorp browser" true;
      firefox.enable = mkBool "enable Firefox browser" false;
      librewolf.enable = mkBool "enable LibreWolf browser" false;
      nyxt.enable = mkBool "enable Nyxt browser" true;
      yandex.enable = mkBool "enable Yandex browser" true;
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

    # Fun/extras (e.g., curated art assets) that are nice-to-have
    fun = {
      enable = mkBool "enable fun extras (art collections, etc.)" true;
    };

    # GPG stack (gpg, gpg-agent, pinentry)
    gpg.enable = mkBool "enable GPG and gpg-agent (creates ~/.gnupg)" true;
  };

  # Apply profile defaults. Users can still override flags after this.
  config = mkMerge [
    (mkIf (cfg.profile == "lite") {
      # Slim defaults for lite profile
      features = {
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
          floorp.enable = mkDefault false;
          yandex.enable = mkDefault false;
        };
        emulators.retroarch.full = mkDefault false;
        fun.enable = mkDefault false;
      };
    })
    (mkIf (cfg.profile == "full") {
      # Rich defaults for full profile
      features = {
        web = {
          enable = mkDefault true;
          tools.enable = mkDefault true;
          floorp.enable = mkDefault true;
          firefox.enable = mkDefault false;
          librewolf.enable = mkDefault false;
          nyxt.enable = mkDefault true;
          yandex.enable = mkDefault true;
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
    # If parent feature is disabled, default child toggles to false to avoid contradictions
    (mkIf (! cfg.web.enable) {
      features.web = {
        tools.enable = mkDefault false;
        floorp.enable = mkDefault false;
        firefox.enable = mkDefault false;
        librewolf.enable = mkDefault false;
        nyxt.enable = mkDefault false;
        yandex.enable = mkDefault false;
      };
    })
    (mkIf (! cfg.dev.enable) {
      features.dev.ai.enable = mkDefault false;
    })
    (mkIf (! cfg.gui.enable) {
      features.gui = {};
    })
    (mkIf (! cfg.mail.enable) {
      features.mail = {};
    })
    (mkIf (! cfg.hack.enable) {
      features.hack = {};
    })
    # Consistency assertions for nested flags
    {
      assertions = [
        # Guard: hy3 plugin <-> Hyprland version compatibility.
        # We pin Hyprland to v0.50.1 and hy3 to commit 1fdc0a2 (pre-CHyprColor API).
        # If either pin changes, fail early with a helpful message.
        (let
          # Best-effort extraction of versions from flake inputs without forcing builds
          hyprlandVersion = lib.attrByPath ["packages" pkgs.system "hyprland" "version"] null inputs.hyprland or null;
          hy3Rev = lib.attrByPath ["rev"] null hy3 or null;
          # Known compatible matrix (extend as you update pins)
          compatible = [
            {
              hv = "0.50.1";
              rev = "1fdc0a291f8c23b22d27d6dabb466d018757243c";
            }
          ];
          matches = c: (
            (hyprlandVersion == null || hyprlandVersion == c.hv)
          ) && (
            (hy3Rev == null || hy3Rev == c.rev)
          );
          ok = lib.any matches compatible;
        in {
          assertion = ok;
          message = ''
            Incompatible Hyprland/hy3 pins detected.
            Expected one of: ${builtins.concatStringsSep ", " (map (c: "Hyprland " + c.hv + " + hy3 " + builtins.substring 0 7 c.rev) compatible)}
            Got: Hyprland ${toString hyprlandVersion} + hy3 ${toString (if hy3Rev == null then "<unknown>" else builtins.substring 0 7 hy3Rev)}
            Update flake.nix pins or extend the compatibility matrix in modules/features.nix.
          '';
        })
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
  ];
}
