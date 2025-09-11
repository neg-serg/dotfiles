{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
mkIf (config.features.web.enable && config.features.web.nyxt.enable) (let
  nyxtPkg = pkgs.nyxt;
  dlDir = "${config.home.homeDirectory}/dw";
in {
  home.packages = [ nyxtPkg ];

  # Ensure Nyxt config dir exists and file is not blocking linking
  home.activation.fixNyxtConfigDir =
    config.lib.neg.mkEnsureRealDir "${config.xdg.configHome}/nyxt";
  home.activation.fixNyxtConfigFile =
    config.lib.neg.mkEnsureAbsent "${config.xdg.configHome}/nyxt/init.lisp";

  # Nyxt 4 config with vim-friendly behavior
  xdg.configFile."nyxt/init.lisp".text = ''
    ;; Nyxt init (HM-managed). Safe defaults + Vim-friendly tweaks.
    (in-package :nyxt-user)

    ;; Use vi-normal-mode by default
    (define-configuration nyxt:buffer
      ((default-modes (cons 'nyxt/vi-mode:vi-normal-mode %slot-default%))))

    ;; Minimal UI/UX tweaks
    (define-configuration nyxt:buffer
      ((download-directory #p"${dlDir}/")
       (confirm-before-quit :always-ask)))

    ;; Add a few vi-like bindings (t: new tab, x: close, H/L: history)
    ;; Wrapped defensively to avoid breaking on missing symbols between Nyxt versions.
    (handler-case
      (progn
        (define-configuration nyxt/vi-mode:vi-normal-mode
          ((keymap
             (let ((map %slot-default%))
               (when (fboundp 'nyxt:make-buffer)
                 (define-key map "t" 'nyxt:make-buffer))
               (when (fboundp 'nyxt:delete-buffer)
                 (define-key map "x" 'nyxt:delete-buffer))
               (when (fboundp 'nyxt:list-buffers)
                 (define-key map "T" 'nyxt:list-buffers))
               (when (fboundp 'nyxt:history-backwards)
                 (define-key map "H" 'nyxt:history-backwards))
               (when (fboundp 'nyxt:history-forwards)
                 (define-key map "L" 'nyxt:history-forwards))
               (when (fboundp 'nyxt:reload-current-buffer)
                 (define-key map "r" 'nyxt:reload-current-buffer))
               (when (fboundp 'nyxt:query-selection-in-search-engine)
                 (define-key map "/" 'nyxt:query-selection-in-search-engine))
               map))))
      (error (c)
        (declare (ignore c))
        ;; Ignore keybinding errors to keep startup resilient.
        nil))
  '';
})
