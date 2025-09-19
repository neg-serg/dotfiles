{ lib, config, pkgs, xdg, ... }:
with lib;
mkIf (config.features.gui.enable or false) (
let
  # Wrapper: start swayimg, export SWAYIMG_IPC, jump to first image via IPC.
  swayimg-first = pkgs.writeShellScriptBin "swayimg-first" (
    let
      tpl = builtins.readFile ./swayimg-first.sh;
      text = lib.replaceStrings ["@SWAYIMG_BIN@" "@SOCAT_BIN@"] [ (lib.getExe pkgs.swayimg) (lib.getExe pkgs.socat) ] tpl;
    in text
  );
in lib.mkMerge [
  {
  home.packages = config.lib.neg.pkgsList [
    # metadata
    pkgs.exiftool pkgs.exiv2 pkgs.mediainfo
    # editors
    pkgs.gimp pkgs.rawtherapee pkgs.graphviz
    # optimizers
    pkgs.jpegoptim pkgs.optipng pkgs.pngquant pkgs.advancecomp pkgs.scour
    # color
    pkgs.pastel pkgs.lutgen
    # qr
    pkgs.qrencode pkgs.zbar
    # viewers
    pkgs.swayimg swayimg-first pkgs.viu
  ];
  }
  # Replace ad-hoc ~/.local/bin files with guarded wrappers
  {
    home.activation.cleanBin_swayimg = config.lib.neg.mkEnsureAbsent "$HOME/.local/bin/swayimg";
    home.file.".local/bin/swayimg" = {
      executable = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        exec ${swayimg-first}/bin/swayimg-first "$@"'';
    };
  }
  {
    home.activation.cleanBin_sx = config.lib.neg.mkEnsureAbsent "$HOME/.local/bin/sx";
    home.file.".local/bin/sx" = {
      executable = true;
      text = (builtins.readFile ./sx.sh);
    };
  }
  {
    home.activation.cleanBin_sxivnc = config.lib.neg.mkEnsureAbsent "$HOME/.local/bin/sxivnc";
    home.file.".local/bin/sxivnc" = {
      executable = true;
      text = (builtins.readFile ./sxivnc.sh);
    };
  }

  # Guard: ensure we don't write through an unexpected symlink or file at ~/.local/bin/swayimg
  # Collapse to a single step that removes any pre-existing file/dir/symlink.
  # Prepared via global prepareUserPaths action

  # Live-editable Swayimg config via helper (guards parent dir and target)
  (xdg.mkXdgSource "swayimg" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/media/images/swayimg/conf";
    recursive = true;
  })
])
