{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    (qutebrowser.overrideAttrs (oldAttrs: {
      qtWrapperArgs =
        (oldAttrs.qtWrapperArgs or [])
        ++ [
          "--set QT_ENABLE_VULKAN 1"
          "--set QT_QUICK_BACKEND vulkan"
          "--set QT_QPA_PLATFORM wayland"
        ]; # prefer Wayland + Vulkan
      preFixup =
        (oldAttrs.preFixup or "")
        + ''
          wrapQtApp "$out/bin/qutebrowser" \
            --add-flags "--qt-flag enable-gpu-rasterization" \
            --add-flags "--qt-flag enable-features=VaapiVideoDecoder,VaapiVideoEncoder" \
            --add-flags "--qt-flag disable-features=UseChromeOSDirectVideoDecoder"
        '';
    }))
  ];
}
