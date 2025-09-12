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
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
in
  lib.mkIf enableIac (lib.mkMerge [
    {
    # Ensure ~/.config/ansible is a real directory
    home.activation.fixAnsibleConfigDir =
      config.lib.neg.mkEnsureRealDir "${config.xdg.configHome}/ansible";

    # Guard: avoid writing through unexpected symlinks for ansible config files
    home.activation.fixAnsibleCfgSymlink =
      config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/ansible/ansible.cfg";
    home.activation.fixAnsibleHostsSymlink =
      config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/ansible/hosts";

    # Ensure galaxy target dirs exist under XDG data
    # using pure helpers that guard parent dirs and target files
    # (roles, collections)
    
    # Ensure cache dirs exist for fact cache and SSH control sockets
    # (facts, ssh)

    # Environment hints for tools that prefer env vars over ansible.cfg
    home.sessionVariables = {
      ANSIBLE_CONFIG = "${XDG_CFG}/ansible/ansible.cfg";
      ANSIBLE_ROLES_PATH = "${XDG_DATA}/ansible/roles";
      ANSIBLE_GALAXY_COLLECTIONS_PATHS = "${XDG_DATA}/ansible/collections";
    };
  }
  (xdg.mkXdgText "ansible/ansible.cfg" ''
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
    '')
  (xdg.mkXdgText "ansible/hosts" ''# Add your inventory groups/hosts here\n'')
  # Data/cache .keep files via helpers (ensure real dirs + safe writes)
  (xdg.mkXdgDataText "ansible/roles/.keep" "")
  (xdg.mkXdgDataText "ansible/collections/.keep" "")
  (xdg.mkXdgCacheText "ansible/facts/.keep" "")
  (xdg.mkXdgCacheText "ansible/ssh/.keep" "")
])
