{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.features;
in {
  options.features = {
    profile = mkOption {
      type = types.enum ["full" "lite"];
      default = "full";
      description = "Profile preset that adjusts feature defaults: full or lite.";
    };

    gui.enable = mkEnableOption "enable GUI stack (wayland/hyprland, quickshell, etc.)" // {default = true;};
    mail.enable = mkEnableOption "enable Mail stack (notmuch, isync, vdirsyncer, etc.)" // {default = true;};
    hack.enable = mkEnableOption "enable Hack/security tooling stack" // {default = true;};
    dev = {
      enable = mkEnableOption "enable Dev stack (toolchains, editors, hack tooling)" // {default = true;};
      ai = {
        enable = mkEnableOption "enable AI tools (e.g., LM Studio)" // {default = true;};
      };
    };

    web = {
      enable = mkEnableOption "enable Web stack (browsers + tools)" // {default = true;};
      tools.enable = mkEnableOption "enable web tools (aria2, yt-dlp, misc)" // {default = true;};
      floorp.enable = mkEnableOption "enable Floorp browser" // {default = true;};
      firefox.enable = mkEnableOption "enable Firefox browser" // {default = false;};
      librewolf.enable = mkEnableOption "enable LibreWolf browser" // {default = false;};
      yandex.enable = mkEnableOption "enable Yandex browser" // {default = true;};
    };

    media = {
      audio = {
        core.enable = mkEnableOption "enable audio core (PipeWire routing tools)" // {default = true;};
        apps.enable = mkEnableOption "enable audio apps (players, tools)" // {default = true;};
        creation.enable = mkEnableOption "enable audio creation stack (DAW, synths)" // {default = true;};
        mpd.enable = mkEnableOption "enable MPD stack (mpd, clients, mpdris2)" // {default = true;};
      };
    };

    emulators = {
      retroarch.full = mkEnableOption "use retroarchFull with extended (unfree) cores" // {default = false;};
    };
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
          yandex.enable = mkDefault true;
        };
        media.audio = {
          core.enable = mkDefault true;
          apps.enable = mkDefault true;
          creation.enable = mkDefault true;
          mpd.enable = mkDefault true;
        };
        emulators.retroarch.full = mkDefault true;
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
        {
          assertion = cfg.web.enable || (! cfg.web.tools.enable && ! cfg.web.floorp.enable && ! cfg.web.yandex.enable);
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
