{
  lib,
  config,
  ...
}: let
  cfgDev = config.features.dev;
  enableIac = cfgDev.enable && (config.features.dev.pkgs.iac or false);
  XDG_CFG = config.home.sessionVariables.XDG_CONFIG_HOME or "${config.home.homeDirectory}/.config";
  XDG_DATA = config.home.sessionVariables.XDG_DATA_HOME or "${config.home.homeDirectory}/.local/share";
  XDG_CACHE = config.home.sessionVariables.XDG_CACHE_HOME or "${config.home.homeDirectory}/.cache";
in
  lib.mkIf enableIac {
    # Ensure ~/.config/ansible is a real directory
    home.activation.fixAnsibleConfigDir =
      config.lib.neg.mkEnsureRealDir "${config.xdg.configHome}/ansible";

    # Guard: avoid writing through unexpected symlinks for ansible config files
    home.activation.fixAnsibleCfgSymlink =
      config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/ansible/ansible.cfg";
    home.activation.fixAnsibleHostsSymlink =
      config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/ansible/hosts";

    # Ensure XDG data/cache subdirectories are real directories before writing .keep files
    home.activation.fixAnsibleDataRolesDir =
      config.lib.neg.mkEnsureRealDir "${config.xdg.dataHome or "$HOME/.local/share"}/ansible/roles";
    home.activation.fixAnsibleDataCollectionsDir =
      config.lib.neg.mkEnsureRealDir "${config.xdg.dataHome or "$HOME/.local/share"}/ansible/collections";
    home.activation.fixAnsibleCacheFactsDir =
      config.lib.neg.mkEnsureRealDir "${config.xdg.cacheHome or "$HOME/.cache"}/ansible/facts";
    home.activation.fixAnsibleCacheSshDir =
      config.lib.neg.mkEnsureRealDir "${config.xdg.cacheHome or "$HOME/.cache"}/ansible/ssh";

    # XDG-friendly ansible configuration + galaxy install paths
    xdg.configFile."ansible/ansible.cfg".text = ''
      [defaults]
      roles_path = ${XDG_DATA}/ansible/roles
      collections_paths = ${XDG_DATA}/ansible/collections
      inventory = ${XDG_CFG}/ansible/hosts
      retry_files_enabled = False
      stdout_callback = yaml
      bin_ansible_callbacks = True
      interpreter_python = auto_silent
      forks = 20
      strategy = free
      gathering = smart
      fact_caching = jsonfile
      fact_caching_connection = ${XDG_CACHE}/ansible/facts
      fact_caching_timeout = 86400
      timeout = 30

      [galaxy]
      server_list = galaxy

      [galaxy_server.galaxy]
      url=https://galaxy.ansible.com/

      [ssh_connection]
      pipelining = True
      control_path_dir = ${XDG_CACHE}/ansible/ssh
      ssh_args = -o ControlMaster=auto -o ControlPersist=60s
    '';

    # Minimal inventory placeholder (safe to edit/remove)
    xdg.configFile."ansible/hosts".text = ''# Add your inventory groups/hosts here\n'';

    # Ensure galaxy target dirs exist under XDG data
    xdg.dataFile."ansible/roles/.keep".text = "";
    xdg.dataFile."ansible/collections/.keep".text = "";
    # Ensure cache dirs exist for fact cache and SSH control sockets
    xdg.cacheFile."ansible/facts/.keep".text = "";
    xdg.cacheFile."ansible/ssh/.keep".text = "";

    # Environment hints for tools that prefer env vars over ansible.cfg
    home.sessionVariables = {
      ANSIBLE_CONFIG = "${XDG_CFG}/ansible/ansible.cfg";
      ANSIBLE_ROLES_PATH = "${XDG_DATA}/ansible/roles";
      ANSIBLE_GALAXY_COLLECTIONS_PATHS = "${XDG_DATA}/ansible/collections";
    };
  }
