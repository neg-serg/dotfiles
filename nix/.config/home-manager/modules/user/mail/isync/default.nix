{ pkgs, ... }:
{
  # Install isync/mbsync and keep using the XDG config at ~/.config/isync/mbsyncrc
  programs.mbsync.enable = true;

  # Optional: ensure the binary is present even if HM changes defaults
  home.packages = [ pkgs.isync ];

  # Create base maildir on activation (mbsync can also create, but this avoids first-run hiccups)
  home.activation.createMaildirs = {
    after = [ "writeBoundary" ];
    before = [ ];
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
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = ''${pkgs.isync}/bin/mbsync -Va -c "$HOME/.config/isync/mbsyncrc"'';
    };
  };
  systemd.user.timers."mbsync-gmail" = {
    Unit = { Description = "Timer: mbsync gmail"; };
    Timer = {
      OnBootSec = "2m";
      OnUnitActiveSec = "10m";
      Persistent = true;
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}
