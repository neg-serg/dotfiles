{
  self,
  system,
}: {
  config,
  lib,
  pkgs,
  ...
}:
with lib;
# Base config for all Linux systems
  let
    cfg = config.modules.audio-nix.yabridgemgr;
    mkBool =
      if (config ? lib) && (config.lib ? neg) && (config.lib.neg ? mkBool)
      then config.lib.neg.mkBool
      else (desc: default: (lib.mkEnableOption desc) // { inherit default; });
  in {
    options.modules.audio-nix.yabridgemgr = {
      enable = mkBool "Yabridgemgr" false;
      user = mkOption {
        type = types.str;
        description = "User for yabridgemgr";
      };
      plugins = mkOption {
        type = types.listOf types.package;
        default = [
          self.packages.${system}.wine-valhalla
          self.packages.${system}.wine-voxengo-span
          self.packages.${system}.wine-midichordanalyzer
        ];
        description = "Plugin packages to install";
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = with pkgs; [yabridge yabridgectl];
      systemd.user.tmpfiles.users."${cfg.user}".rules = let
        userHome = config.users.users.${cfg.user}.home;
        ybcfg = pkgs.writeText "yabridgecfg" ''
          plugin_dirs = [
            '${userHome}/yabridgemgr/drive_c/Program Files/Common Files/VST2',
            '${userHome}/yabridgemgr/drive_c/Program Files/Common Files/VST3',
          ]
          vst2_location = 'centralized'
          no_verify = false
          blacklist = []
        '';
      in [
        "d %h/yabridgemgr - - - - -"
        "C %h/.config/yabridgectl/config.toml - - - - ${ybcfg}"
      ];
      systemd.user.services = {
        yabridgemgr_mountprefix = let
          build_prefix = pkgs.callPackage ./plumbing/build_prefix.nix {
            username = cfg.user;
            inherit (cfg) plugins;
          };
          mount_prefix = pkgs.callPackage ./plumbing/mount_prefix.nix {
            wineprefix = build_prefix;
          };
          umount_prefix = pkgs.callPackage ./plumbing/umount_prefix.nix {};
        in {
          description = "Mount yabridge prefix";
          after = [
            "systemd-tmpfiles-setup.service" # ensure tmpfiles have run
          ];
          wantedBy = [
            "default.target" # start by default in user session
          ];
          serviceConfig = {
            RuntimeDirectory = "yabridgemgr";
            ExecStart = "${mount_prefix}/bin/mount_prefix";
            ExecStop = "${umount_prefix}/bin/umount_prefix";
            RemainAfterExit = "yes";
          };
          unitConfig = {ConditionUser = "${cfg.user}";};
        };
        yabridgemgr_sync = {
          description = "yabridgectl sync";
          after = [
            "yabridgemgr_mountprefix.service" # mount prefix before sync
          ];
          wantedBy = [
            "default.target" # start by default in user session
          ];
          serviceConfig = {
            ExecStart = "${pkgs.yabridgectl}/bin/yabridgectl sync";
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
            Environment = "NIX_PROFILES=/run/current-system/sw";
            RemainAfterExit = "yes";
          };
          unitConfig = {ConditionUser = "${cfg.user}";};
        };
      };
    };
  }
