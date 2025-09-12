{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.mail.enable {
    # Install isync/mbsync and keep using the XDG config at ~/.config/isync/mbsyncrc
    programs.mbsync.enable = true;

    # Inline mbsyncrc under XDG with automatic guards via helper
    # (ensures parent dir is real and removes stale file/symlink)
    xdg.configFile."isync/mbsyncrc" = {
      text = ''
        #-- gmail
        IMAPAccount gmail
        Host imap.gmail.com
        User serg.zorg@gmail.com
        PassCmd "pass show mail/gmail/serg.zorg@gmail.com/mbsync-app"
        AuthMechs LOGIN
        SSLType IMAPS
        CertificateFile /etc/ssl/certs/ca-bundle.crt

        IMAPStore gmail-remote
        Account gmail

        MaildirStore gmail-local
        Subfolders Verbatim
        Path ~/.local/mail/gmail/
        Inbox ~/.local/mail/gmail/INBOX/

        Channel gmail
        Far :gmail-remote:
        Near :gmail-local:
        Patterns "INBOX" "[Gmail]/Sent Mail" "[Gmail]/Drafts" "[Gmail]/All Mail" "[Gmail]/Trash" "[Gmail]/Spam"
        # Download-only to avoid uploading local changes to Gmail
        Sync Pull
        # Create/expunge only locally (Near) to prevent remote changes
        Create Near
        Expunge Near
        SyncState *
      '';
    };

    # Optional: ensure the binary is present even if HM changes defaults
    # Also provide a non-blocking trigger to start sync in background
    home.packages = config.lib.neg.filterByExclude [
      pkgs.isync # mbsync binary (isync)
      (pkgs.writeShellScriptBin "sync-mail" ''
        #!/usr/bin/env bash
        set -euo pipefail
        # Fire-and-forget start of the mbsync systemd unit
        exec systemctl --user start --no-block mbsync-gmail.service
      '')
    ];

    # Create base maildir on activation (mbsync can also create, but this avoids first-run hiccups)
    # Use a shared activation key to consolidate output with other minor ensures
    home.activation.prepareUserPaths = config.lib.neg.mkEnsureMaildirs "$HOME/.local/mail/gmail" [
      "INBOX"
      "[Gmail]/Sent Mail"
      "[Gmail]/Drafts"
      "[Gmail]/All Mail"
    ];

    # Periodic sync in addition to imapnotify (fallback / catch-up)
    systemd.user.services."mbsync-gmail" = lib.recursiveUpdate {
      Unit.Description = "Sync mail via mbsync (gmail)";
      Service = {
        # Use simple so `systemctl start` doesn't block the caller
        Type = "simple";
        # First full sync can take a long time; keep generous timeout
        TimeoutStartSec = "30min";
        ExecStart = ''${pkgs.isync}/bin/mbsync -Va -c %h/.config/isync/mbsyncrc'';
      };
    } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["netOnline"];});
    systemd.user.timers."mbsync-gmail" = lib.recursiveUpdate {
      Unit.Description = "Timer: mbsync gmail";
      Timer = {
        OnBootSec = "2m";
        OnUnitActiveSec = "10m";
        Persistent = true;
      };
    } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["timers"];});
  }
