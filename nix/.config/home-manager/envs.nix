{config, ...} : {
  home.sessionVariables = {
      XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
      XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
      XDG_DESKTOP_DIR = "${config.home.homeDirectory}/.local/desktop";
      XDG_DOCUMENTS_DIR = "${config.home.homeDirectory}/doc";
      XDG_DOWNLOAD_DIR = "${config.home.homeDirectory}/dw";
      XDG_MUSIC_DIR = "${config.home.homeDirectory}/music";
      XDG_PICTURES_DIR = "${config.home.homeDirectory}/pic";
      XDG_PUBLICSHARE_DIR = "${config.home.homeDirectory}/1st_level/public";
      XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
      XDG_TEMPLATES_DIR = "${config.home.homeDirectory}/1st_level/templates";
      XDG_VIDEOS_DIR = "${config.home.homeDirectory}/vid";
      XDG_RUNTIME_DIR = "/run/user/$UID";

      BROWSER = "floorp";
      CARGO_HOME = "${config.home.sessionVariables.XDG_DATA_HOME}/cargo";
      CCACHE_CONFIGPATH = "${config.home.sessionVariables.XDG_CONFIG_HOME}/ccache.config";
      CCACHE_DIR = "${config.home.sessionVariables.XDG_CACHE_HOME}/ccache";
      EZA_COLORS = "da=03:uu=01:gu=0:ur=0:uw=03:ux=04;38;5;24:gr=0:gx=01;38;5;24:tx=01;38;5;24;ur=00;ue=00:tr=00:tw=00:tx=00";
      GHCUP_USE_XDG_DIRS = 1;
      GREP_COLOR = "37;45";
      GREP_COLORS = "ms=0;32:mc=1;33:sl=:cx=:fn=1;32:ln=1;36:bn=36:se=1;30";
      HTTPIE_CONFIG_DIR = "${config.home.sessionVariables.XDG_CONFIG_HOME}/httpie";
      INPUTRC = "${config.home.sessionVariables.XDG_CONFIG_HOME}/inputrc";
      LIBSEAT_BACKEND = "logind";
      MPV_HOME = "${config.home.sessionVariables.XDG_CONFIG_HOME}/mpv";
      NOTMUCH_CONFIG = "${config.home.sessionVariables.XDG_CONFIG_HOME}/notmuch/notmuchrc";
      PARALLEL_HOME = "${config.home.sessionVariables.XDG_CONFIG_HOME}/parallel";
      PASSWORD_STORE_DIR = "${config.home.sessionVariables.XDG_DATA_HOME}/pass";
      PASSWORD_STORE_ENABLE_EXTENSIONS_DEFAULT = "true";
      PYLINTHOME = "${config.home.sessionVariables.XDG_CONFIG_HOME}/pylint";
      TERMINAL = "kitty";
      TERMINFO = "${config.home.sessionVariables.XDG_DATA_HOME}/terminfo";
      TERMINFO_DIRS = "${config.home.sessionVariables.XDG_DATA_HOME}/terminfo:/usr/share/terminfo";
      VAGRANT_HOME = "${config.home.sessionVariables.XDG_DATA_HOME}/vagrant";
      WINEPREFIX = "${config.home.sessionVariables.XDG_DATA_HOME}/wineprefixes/default";
      WORDCHARS = "*?_-.[]~&;!#$%^(){}<>~\\` ";
      XAUTHORITY = "${config.home.sessionVariables.XDG_RUNTIME_DIR}/Xauthority";
      XINITRC = "${config.home.sessionVariables.XDG_CONFIG_HOME}/xinit/xinitrc";
      XSERVERRC = "${config.home.sessionVariables.XDG_CONFIG_HOME}/xinit/xserverrc";
      ZDOTDIR = "${config.home.sessionVariables.XDG_CONFIG_HOME}/zsh";
      _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.home.sessionVariables.XDG_CONFIG_HOME}/java";
      __GL_VRR_ALLOWED = 1;
      PIPEWIRE_LOG_SYSTEMD = "true";
      PIPEWIRE_DEBUG = 2;
  };
}
