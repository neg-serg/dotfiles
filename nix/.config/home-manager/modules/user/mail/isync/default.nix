{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.mail {
    # Install isync/mbsync and keep using the XDG config at ~/.config/isync/mbsyncrc
    programs.mbsync.enable = true;

    # Optional: ensure the binary is present even if HM changes defaults
    # Also provide a non-blocking trigger to start sync in background
    home.packages = [
      pkgs.isync # mbsync binary (isync)
      (pkgs.writeShellScriptBin "sync-mail" ''
        #!/usr/bin/env bash
        set -euo pipefail
        # Fire-and-forget start of the mbsync systemd unit
        exec systemctl --user start --no-block mbsync-gmail.service
      '')
    ];

    # Create base maildir on activation (mbsync can also create, but this avoids first-run hiccups)
    home.activation.createMaildirs = {
      after = [
        "writeBoundary" # run after HM writes files to disk
      ];
      before = [];
      data = ''
        set -eu
        base="$HOME/.local/mail/gmail"
        mkdir -p "$base/INBOX/cur" "$base/INBOX/new" "$base/INBOX/tmp"
        mkdir -p "$base/[Gmail]/Sent Mail/cur" "$base/[Gmail]/Sent Mail/new" "$base/[Gmail]/Sent Mail/tmp" || true
        mkdir -p "$base/[Gmail]/Drafts/cur" "$base/[Gmail]/Drafts/new" "$base/[Gmail]/Drafts/tmp" || true
        mkdir -p "$base/[Gmail]/All Mail/cur" "$base/[Gmail]/All Mail/new" "$base/[Gmail]/All Mail/tmp" || true
      '';
    };

    # Periodic sync in addition to imapnotify (fallback / catch-up)
    systemd.user.services."mbsync-gmail" = {
      Unit = {
        Description = "Sync mail via mbsync (gmail)";
        After = [
          "network-online.target" # require working network
        ];
        Wants = [
          "network-online.target" # pull in network-online
        ];
      };
      Service = {
        # Use simple so `systemctl start` doesn't block the caller
        Type = "simple";
        # First full sync can take a long time; keep generous timeout
        TimeoutStartSec = "30min";
        ExecStart = ''${pkgs.isync}/bin/mbsync -Va -c %h/.config/isync/mbsyncrc'';
      };
    };
    systemd.user.timers."mbsync-gmail" = {
      Unit = {Description = "Timer: mbsync gmail";};
      Timer = {
        OnBootSec = "2m";
        OnUnitActiveSec = "10m";
        Persistent = true;
      };
      Install = {
        WantedBy = [
          "timers.target" # hook into user timers
        ];
      };
    };
  }
