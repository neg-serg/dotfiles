// Theme.qml
pragma Singleton
import QtQuick
import "../Helpers/Utils.js" as Utils
import "../Helpers/Color.js" as Color
import Quickshell
import Quickshell.Io
import qs.Settings

Singleton {
    id: root
    // Removed unused designScreenWidth
    // Per-monitor UI scaling (defaults to 1.0)
    function scale(currentScreen) {
        try {
            const overrides = Settings.settings.monitorScaleOverrides || {};
            if (currentScreen && currentScreen.name && overrides[currentScreen.name] !== undefined) {
                return overrides[currentScreen.name];
            }
        } catch (e) { /* ignore */ }
        return 1.0;
    }

    function applyOpacity(color, opacity) {
        try {
            const c = String(color);
            const op = String(opacity);

            // Validate opacity as 2-digit hex
            if (!/^[0-9a-fA-F]{2}$/.test(op)) {
                return c; // fallback: leave as-is
            }

            // Accept only #RRGGBB or #AARRGGBB; otherwise fallback
            if (/^#[0-9a-fA-F]{6}$/.test(c)) {
                // Insert alpha prefix to make #AARRGGBB
                return "#" + op + c.slice(1);
            }
            if (/^#[0-9a-fA-F]{8}$/.test(c)) {
                // Replace existing leading alpha (assumes #AARRGGBB)
                return "#" + op + c.slice(3);
            }

            // Fallback: return original color unchanged
            return c;
        } catch (e) {
            return color; // conservative fallback
        }
    }
    
    // FileView to load theme data from JSON file
    FileView {
        id: themeFile
        path: Settings.themeFile
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: function(error) {
            if (error.toString().includes("No such file") || error === 2) {
                writeAdapter() // File doesn't exist, create it with default values
            }
        }
        JsonAdapter {
            id: themeData
            // Defaults aligned with Theme.json; file values override these

            // Backgrounds
            property string background:  "#ef000000"
            // Surfaces & Elevation
            property string surface:        "#181C25"
            property string surfaceVariant: "#242A35"
            // Text Colors
            property string textPrimary:   "#CBD6E5"
            property string textSecondary: "#AEB9C8"
            property string textDisabled:  "#6B718A"
            // Accent Colors
            property string accentPrimary:   "#006FCC"
            // Error/Warning
            property string error:   "#FF6B81"
            property string warning: "#FFBB66"
            // Highlights & Focus
            property string highlight:    "#94E1F9"
            property string rippleEffect: "#D6F3FF"
            // Additional Theme Properties
            property string onAccent: "#FFFFFF"
            property string outline:  "#3B4C5C"
            // Shadows & Overlays
            property string shadow:  "#000000"
            property string overlay: "#10141A"

            // Panel metrics (logical px; scaled per-screen via Theme.scale(screen))
            property int panelHeight: 28
            property int panelSideMargin: 18
            property int panelWidgetSpacing: 12
            // Separator overshoot is typically unscaled to preserve look
            property int panelSepOvershoot: 60

            // Panel icon sizing (logical)
            property int panelIconSize: 24          // typical icon/button size in bar
            property int panelIconSizeSmall: 16     // small icon or inner icon
            property int panelGlyphSize: 14         // glyphs inside overlays/buttons

            // Panel hover hot-zone (logical)
            property int panelHotzoneWidth: 16
            property int panelHotzoneHeight: 9
            // Factor to compute right shift of hotzone relative to its width
            property real panelHotzoneRightShift: 1.15

            // Typical bar module preferred height (logical)
            property int panelModuleHeight: 36
            // Generic menu Y offset from anchor (logical)
            property int panelMenuYOffset: 20

            // Corners
            property int cornerRadius: 8
            property int cornerRadiusSmall: 4

            // Tooltip
            property int tooltipDelayMs: 1500
            property int tooltipMinSize: 20
            property int tooltipMargin: 12
            property int tooltipPadding: 8
            property int tooltipBorderWidth: 1
            property int tooltipRadius: 2
            property int tooltipFontPx: 14

            // Pill indicator defaults
            property int panelPillHeight: 22
            property int panelPillIconSize: 22
            property int panelPillPaddingH: 14
            property int panelPillShowDelayMs: 500
            property int panelPillAutoHidePauseMs: 2500
            // Pill background (used by modules like Volume)
            property string panelPillBackground: "#000000"

            // Animation timings
            property int panelAnimStdMs: 250
            property int panelAnimFastMs: 200

            // Tray behavior timings (ms)
            property int panelTrayLongHoldMs: 2500
            property int panelTrayShortHoldMs: 1500
            property int panelTrayGuardMs: 120
            property int panelTrayOverlayDismissDelayMs: 5000

            // Generic row spacing in bar context (logical)
            property int panelRowSpacing: 8
            property int panelRowSpacingSmall: 4

            // Volume module behavior (ms)
            property int panelVolumeFullHideMs: 800
            // Volume gradient endpoint colors
            property string panelVolumeLowColor:  "#D62E6E"  // raspberry
            property string panelVolumeHighColor: "#0E6B4D"  // spruce green

            // Core module timings (ms)
            property int timeTickMs: 1000
            property int wsRefreshDebounceMs: 120
            property int applauncherClipboardPollMs: 1000
            property int musicPositionPollMs: 1000
            property int musicPlayersPollMs: 5000
            property int musicMetaRecalcDebounceMs: 80
            property int vpnPollMs: 2500
            property int networkRestartBackoffMs: 1500
            property int networkLinkPollMs: 4000
            property int mediaHoverOpenDelayMs: 320
            property int mediaHoverStillThresholdMs: 180
            // Spectrum animations
            property int spectrumPeakDecayIntervalMs: 50
            property int spectrumBarAnimMs: 100

            // Calendar metrics
            property int calendarRowSpacing: 2
            property int calendarCellSpacing: 2
            property int calendarSideMargin: 2

            // Side-panel popup timings/margins (MusicPopup)
            property int  sidePanelPopupSlideMs: 220
            property int  sidePanelPopupAutoHideMs: 4000
            property int  sidePanelPopupOuterMargin: 4

            // Side-panel spacing medium (in addition to small/tight)
            property int  sidePanelSpacingMedium: 8

            // Hover behavior (opacity/timing)
            property real panelHoverOpacity: 0.18
            property int  panelHoverFadeMs: 120

            // Tray/Panel menu metrics
            property int  panelMenuWidth: 180
            property int  panelSubmenuWidth: 180
            property int  panelMenuPadding: 4
            property int  panelMenuItemSpacing: 2
            property int  panelMenuItemHeight: 26
            property int  panelMenuSeparatorHeight: 6
            property int  panelMenuDividerMargin: 10
            property int  panelMenuRadius: 0
            property int  panelMenuHeightExtra: 12
            property int  panelMenuAnchorYOffset: 4
            property int  panelSubmenuGap: 12
            property int  panelMenuChevronSize: 15
            property int  panelMenuIconSize: 16

            // Side panel defaults (logical)
            property int  sidePanelCornerRadius: 9
            property int  sidePanelSpacing: 12
            property int  sidePanelSpacingTight: 6
            property int  sidePanelSpacingSmall: 4
            property int  sidePanelAlbumArtSize: 200
            property int  sidePanelWeatherWidth: 440
            property int  sidePanelWeatherHeight: 180
            property int  uiIconSizeLarge: 28

            // Overlay panels
            property int  panelOverlayRadius: 20
            property int  cornerRadiusLarge: 12

            // Generic UI spacings/margins (logical)
            property int  uiMarginLarge: 32
            property int  uiMarginMedium: 16
            property int  uiPaddingMedium: 14
            property int  uiSpacingLarge: 18
            property int  uiSpacingSmall: 10
            property int  uiSpacingXSmall: 2
            property int  uiGapTiny: 1
            property int  uiControlHeight: 48

            // Calendar popup sizing
            property int  calendarWidth: 280
            property int  calendarHeight: 320
            property int  calendarPopupMargin: 2
            property int  calendarBorderWidth: 1
            property int  calendarCellSize: 28
            property int  calendarHolidayDotSize: 3
            // Calendar highlight darken factor (0..1)
            property real calendarAccentDarken: 0.8
        }
        
    }

    // --- Nested reader helpers (support hierarchical Theme.json with backward-compat) ---
    function _getNested(path) {
        try {
            var obj = themeData; var parts = String(path).split('.');
            for (var i=0;i<parts.length;i++) {
                if (!obj) return undefined;
                var k = parts[i];
                obj = obj[k];
            }
            return obj;
        } catch (e) { return undefined }
    }
    function val(path, fallback) {
        var v = _getNested(path);
        return (v !== undefined && v !== null) ? v : fallback;
    }
    
    // Backgrounds
    property color background: val('colors.background', themeData.background)
    // Surfaces & Elevation
    property color surface: val('colors.surface', themeData.surface)
    property color surfaceVariant: val('colors.surfaceVariant', themeData.surfaceVariant)
    // Text Colors
    property color textPrimary: val('colors.text.primary', themeData.textPrimary)
    property color textSecondary: val('colors.text.secondary', themeData.textSecondary)
    property color textDisabled: val('colors.text.disabled', themeData.textDisabled)
    // Accent Colors
    property color accentPrimary: val('colors.accent.primary', themeData.accentPrimary)
    // Error/Warning
    property color error: val('colors.status.error', themeData.error)
    property color warning: val('colors.status.warning', themeData.warning)
    // Highlights & Focus
    property color highlight: val('colors.highlight', themeData.highlight)
    property color rippleEffect: val('colors.ripple', themeData.rippleEffect)
    // Additional Theme Properties
    property color onAccent: val('colors.onAccent', themeData.onAccent)
    property color outline: val('colors.outline', themeData.outline)
    // Shadows & Overlays
    property color shadow: applyOpacity(val('colors.shadow', themeData.shadow), "B3")
    property color overlay: applyOpacity(val('colors.overlay', themeData.overlay), "66")
    property string fontFamily: "Iosevka" // Font Properties
    // Font size multiplier - adjust this in Settings.json to scale all fonts
    property real fontSizeMultiplier: Settings.settings.fontSizeMultiplier || 1.0
    // Global contrast threshold used by Color.contrastOn callers
    property real contrastThreshold: (Settings.settings && Settings.settings.contrastThreshold !== undefined)
        ? Settings.settings.contrastThreshold : 0.5
    // Base font sizes (multiplied by fontSizeMultiplier)
    property int fontSizeHeader: Math.round(32 * fontSizeMultiplier)     // Headers and titles
    property int fontSizeBody: Math.round(16 * fontSizeMultiplier)       // Body text and general content
    property int fontSizeSmall: Math.round(14 * fontSizeMultiplier)      // Small text like clock, labels
    property int fontSizeCaption: Math.round(12 * fontSizeMultiplier)    // Captions and fine print

    // Panel metrics (logical)
    property int panelHeight: Utils.clamp(val('panel.height', themeData.panelHeight), 16, 64)
    property int panelSideMargin: val('panel.sideMargin', themeData.panelSideMargin)
    property int panelWidgetSpacing: val('panel.widgetSpacing', themeData.panelWidgetSpacing)
    property int panelSepOvershoot: val('panel.sepOvershoot', themeData.panelSepOvershoot)
    // Panel icon sizing
    property int panelIconSize: val('panel.icons.iconSize', themeData.panelIconSize)
    property int panelIconSizeSmall: val('panel.icons.iconSizeSmall', themeData.panelIconSizeSmall)
    property int panelGlyphSize: val('panel.icons.glyphSize', themeData.panelGlyphSize)
    // Panel hot-zone
    property int panelHotzoneWidth: Utils.clamp(val('panel.hotzone.width', themeData.panelHotzoneWidth), 4, 64)
    property int panelHotzoneHeight: Utils.clamp(val('panel.hotzone.height', themeData.panelHotzoneHeight), 2, 64)
    property real panelHotzoneRightShift: Utils.clamp(val('panel.hotzone.rightShift', themeData.panelHotzoneRightShift), 0.5, 3.0)
    property int panelModuleHeight: val('panel.moduleHeight', themeData.panelModuleHeight)
    property int panelMenuYOffset: val('panel.menuYOffset', themeData.panelMenuYOffset)
    // Corners
    property int cornerRadius: val('shape.cornerRadius', themeData.cornerRadius)
    property int cornerRadiusSmall: val('shape.cornerRadiusSmall', themeData.cornerRadiusSmall)
    // Tooltip
    property int tooltipDelayMs: val('tooltip.delayMs', themeData.tooltipDelayMs)
    property int tooltipMinSize: val('tooltip.minSize', themeData.tooltipMinSize)
    property int tooltipMargin: val('tooltip.margin', themeData.tooltipMargin)
    property int tooltipPadding: val('tooltip.padding', themeData.tooltipPadding)
    property int tooltipBorderWidth: val('tooltip.borderWidth', themeData.tooltipBorderWidth)
    property int tooltipRadius: val('tooltip.radius', themeData.tooltipRadius)
    property int tooltipFontPx: val('tooltip.fontPx', themeData.tooltipFontPx)
    // Pill indicator defaults
    property int panelPillHeight: val('panel.pill.height', themeData.panelPillHeight)
    property int panelPillIconSize: val('panel.pill.iconSize', themeData.panelPillIconSize)
    property int panelPillPaddingH: val('panel.pill.paddingH', themeData.panelPillPaddingH)
    property int panelPillShowDelayMs: val('panel.pill.showDelayMs', themeData.panelPillShowDelayMs)
    property int panelPillAutoHidePauseMs: val('panel.pill.autoHidePauseMs', themeData.panelPillAutoHidePauseMs)
    property color panelPillBackground: val('panel.pill.background', themeData.panelPillBackground)
    // Animation timings
    property int panelAnimStdMs: Utils.clamp(val('panel.animations.stdMs', themeData.panelAnimStdMs), 0, 5000)
    property int panelAnimFastMs: Utils.clamp(val('panel.animations.fastMs', themeData.panelAnimFastMs), 0, 5000)
    // Tray behavior timings
    property int panelTrayLongHoldMs: Utils.clamp(val('panel.tray.longHoldMs', themeData.panelTrayLongHoldMs), 0, 10000)
    property int panelTrayShortHoldMs: Utils.clamp(val('panel.tray.shortHoldMs', themeData.panelTrayShortHoldMs), 0, 10000)
    property int panelTrayGuardMs: Utils.clamp(val('panel.tray.guardMs', themeData.panelTrayGuardMs), 0, 2000)
    property int panelTrayOverlayDismissDelayMs: Utils.clamp(val('panel.tray.overlayDismissDelayMs', themeData.panelTrayOverlayDismissDelayMs), 0, 600000)
    // Generic row spacing
    property int panelRowSpacing: val('panel.rowSpacing', themeData.panelRowSpacing)
    property int panelRowSpacingSmall: val('panel.rowSpacingSmall', themeData.panelRowSpacingSmall)
    // Volume behavior
    property int panelVolumeFullHideMs: val('panel.volume.fullHideMs', themeData.panelVolumeFullHideMs)
    property color panelVolumeLowColor: val('panel.volume.lowColor', themeData.panelVolumeLowColor)
    property color panelVolumeHighColor: val('panel.volume.highColor', themeData.panelVolumeHighColor)
    // Core module timings
    property int timeTickMs: Utils.clamp(val('timers.timeTickMs', themeData.timeTickMs), 100, 60000)
    property int wsRefreshDebounceMs: Utils.clamp(val('timers.wsRefreshDebounceMs', themeData.wsRefreshDebounceMs), 0, 10000)
    property int vpnPollMs: Utils.clamp(val('network.vpnPollMs', themeData.vpnPollMs), 500, 600000)
    property int networkRestartBackoffMs: Utils.clamp(val('network.restartBackoffMs', themeData.networkRestartBackoffMs), 0, 600000)
    property int networkLinkPollMs: Utils.clamp(val('network.linkPollMs', themeData.networkLinkPollMs), 500, 600000)
    property int mediaHoverOpenDelayMs: Utils.clamp(val('media.hover.openDelayMs', themeData.mediaHoverOpenDelayMs), 0, 5000)
    property int mediaHoverStillThresholdMs: Utils.clamp(val('media.hover.stillThresholdMs', themeData.mediaHoverStillThresholdMs), 0, 10000)
    property int spectrumPeakDecayIntervalMs: Utils.clamp(val('spectrum.peakDecayIntervalMs', themeData.spectrumPeakDecayIntervalMs), 10, 1000)
    property int spectrumBarAnimMs: Utils.clamp(val('spectrum.barAnimMs', themeData.spectrumBarAnimMs), 0, 5000)
    property int musicPositionPollMs: Utils.clamp(val('timers.musicPositionPollMs', themeData.musicPositionPollMs), 100, 600000)
    property int musicPlayersPollMs: Utils.clamp(val('timers.musicPlayersPollMs', themeData.musicPlayersPollMs), 100, 600000)
    property int musicMetaRecalcDebounceMs: Utils.clamp(val('timers.musicMetaRecalcDebounceMs', themeData.musicMetaRecalcDebounceMs), 0, 10000)
    // Applauncher
    property int applauncherClipboardPollMs: Utils.clamp(val('applauncher.clipboardPollMs', themeData.applauncherClipboardPollMs), 100, 600000)
    // Calendar metrics
    property int calendarRowSpacing: val('calendar.rowSpacing', themeData.calendarRowSpacing)
    property int calendarCellSpacing: val('calendar.cellSpacing', themeData.calendarCellSpacing)
    property int calendarSideMargin: val('calendar.sideMargin', themeData.calendarSideMargin)
    // Side-panel popup timings/margins
    property int  sidePanelPopupSlideMs: val('sidePanel.popup.slideMs', themeData.sidePanelPopupSlideMs)
    property int  sidePanelPopupAutoHideMs: val('sidePanel.popup.autoHideMs', themeData.sidePanelPopupAutoHideMs)
    property int  sidePanelPopupOuterMargin: val('sidePanel.popup.outerMargin', themeData.sidePanelPopupOuterMargin)
    // Side-panel spacing medium
    property int  sidePanelSpacingMedium: val('sidePanel.spacingMedium', themeData.sidePanelSpacingMedium)
    // Hover behavior
    property real panelHoverOpacity: val('panel.hover.opacity', themeData.panelHoverOpacity)
    property int  panelHoverFadeMs: val('panel.hover.fadeMs', themeData.panelHoverFadeMs)
    // Panel menu metrics
    property int  panelMenuWidth: Utils.clamp(val('panel.menu.width', themeData.panelMenuWidth), 100, 600)
    property int  panelSubmenuWidth: val('panel.menu.submenuWidth', themeData.panelSubmenuWidth)
    property int  panelMenuPadding: Utils.clamp(val('panel.menu.padding', themeData.panelMenuPadding), 0, 32)
    property int  panelMenuItemSpacing: Utils.clamp(val('panel.menu.itemSpacing', themeData.panelMenuItemSpacing), 0, 16)
    property int  panelMenuItemHeight: Utils.clamp(val('panel.menu.itemHeight', themeData.panelMenuItemHeight), 16, 64)
    property int  panelMenuSeparatorHeight: Utils.clamp(val('panel.menu.separatorHeight', themeData.panelMenuSeparatorHeight), 1, 16)
    property int  panelMenuDividerMargin: Utils.clamp(val('panel.menu.dividerMargin', themeData.panelMenuDividerMargin), 0, 32)
    property int  panelMenuRadius: Utils.clamp(val('panel.menu.radius', themeData.panelMenuRadius), 0, 32)
    property int  panelMenuHeightExtra: Utils.clamp(val('panel.menu.heightExtra', themeData.panelMenuHeightExtra), 0, 64)
    property int  panelMenuAnchorYOffset: Utils.clamp(val('panel.menu.anchorYOffset', themeData.panelMenuAnchorYOffset), -20, 100)
    property int  panelSubmenuGap: val('panel.menu.submenuGap', themeData.panelSubmenuGap)
    property int  panelMenuChevronSize: val('panel.menu.chevronSize', themeData.panelMenuChevronSize)
    property int  panelMenuIconSize: val('panel.menu.iconSize', themeData.panelMenuIconSize)
    // Side panel exports
    property int sidePanelCornerRadius: val('sidePanel.cornerRadius', themeData.sidePanelCornerRadius)
    property int sidePanelSpacing: val('sidePanel.spacing', themeData.sidePanelSpacing)
    property int sidePanelSpacingTight: val('sidePanel.spacingTight', themeData.sidePanelSpacingTight)
    property int sidePanelSpacingSmall: val('sidePanel.spacingSmall', themeData.sidePanelSpacingSmall)
    property int sidePanelAlbumArtSize: val('sidePanel.albumArtSize', themeData.sidePanelAlbumArtSize)
    property int sidePanelWeatherWidth: val('sidePanel.weather.width', themeData.sidePanelWeatherWidth)
    property int sidePanelWeatherHeight: val('sidePanel.weather.height', themeData.sidePanelWeatherHeight)
    property int uiIconSizeLarge: val('ui.iconSizeLarge', themeData.uiIconSizeLarge)
    // Overlay radius and larger corner
    property int panelOverlayRadius: val('panel.overlayRadius', themeData.panelOverlayRadius)
    property int cornerRadiusLarge: val('shape.cornerRadiusLarge', themeData.cornerRadiusLarge)
    // Generic UI spacings/margins
    property int uiMarginLarge: Utils.clamp(val('ui.margin.large', themeData.uiMarginLarge), 0, 128)
    property int uiMarginMedium: Utils.clamp(val('ui.margin.medium', themeData.uiMarginMedium), 0, 64)
    property int uiPaddingMedium: Utils.clamp(val('ui.padding.medium', themeData.uiPaddingMedium), 0, 64)
    property int uiSpacingLarge: Utils.clamp(val('ui.spacing.large', themeData.uiSpacingLarge), 0, 64)
    property int uiSpacingSmall: Utils.clamp(val('ui.spacing.small', themeData.uiSpacingSmall), 0, 32)
    property int uiSpacingXSmall: Utils.clamp(val('ui.spacing.xsmall', themeData.uiSpacingXSmall), 0, 16)
    property int uiGapTiny: val('ui.gap.tiny', themeData.uiGapTiny)
    property int uiControlHeight: val('ui.control.height', themeData.uiControlHeight)
    // Calendar popup sizing
    property int calendarWidth: Utils.clamp(val('calendar.size.width', themeData.calendarWidth), 200, 800)
    property int calendarHeight: Utils.clamp(val('calendar.size.height', themeData.calendarHeight), 200, 800)
    property int calendarPopupMargin: Utils.clamp(val('calendar.popupMargin', themeData.calendarPopupMargin), 0, 32)
    property int calendarBorderWidth: val('calendar.borderWidth', themeData.calendarBorderWidth)
    property int calendarCellSize: Utils.clamp(val('calendar.cellSize', themeData.calendarCellSize), 16, 64)
    property int calendarHolidayDotSize: val('calendar.holidayDotSize', themeData.calendarHolidayDotSize)
    // Tunable factor for dark accent on calendar highlights (today/selected/hover)
    property real calendarAccentDarken: Utils.clamp(val('calendar.accentDarken', themeData.calendarAccentDarken), 0, 1)
    // Derived accent/surface/border tokens (formula-based)
    // Keep simple and perceptually stable; expose tokens for reuse
    // Each derived token may be overridden by matching *Override property in Theme.json
    property color accentHover: (val('colors.overrides.accentHover', themeData.accentHoverOverride) !== undefined)
        ? val('colors.overrides.accentHover', themeData.accentHoverOverride) : Color.towardsWhite(accentPrimary, 0.2)
    property color accentActive: (val('colors.overrides.accentActive', themeData.accentActiveOverride) !== undefined)
        ? val('colors.overrides.accentActive', themeData.accentActiveOverride) : Color.towardsBlack(accentPrimary, 0.2)
    property color accentDisabled: (val('colors.overrides.accentDisabled', themeData.accentDisabledOverride) !== undefined)
        ? val('colors.overrides.accentDisabled', themeData.accentDisabledOverride) : Color.withAlpha(accentPrimary, 0.4)
    property color accentDarkStrong: (val('colors.overrides.accentDarkStrong', themeData.accentDarkStrongOverride) !== undefined)
        ? val('colors.overrides.accentDarkStrong', themeData.accentDarkStrongOverride) : Color.towardsBlack(accentPrimary, 0.8)
    property color surfaceHover: (val('colors.overrides.surfaceHover', themeData.surfaceHoverOverride) !== undefined)
        ? val('colors.overrides.surfaceHover', themeData.surfaceHoverOverride) : Color.withAlpha(textPrimary, 0.06)
    property color surfaceActive: (val('colors.overrides.surfaceActive', themeData.surfaceActiveOverride) !== undefined)
        ? val('colors.overrides.surfaceActive', themeData.surfaceActiveOverride) : Color.withAlpha(textPrimary, 0.10)
    property color borderSubtle: (val('colors.overrides.borderSubtle', themeData.borderSubtleOverride) !== undefined)
        ? val('colors.overrides.borderSubtle', themeData.borderSubtleOverride) : Color.withAlpha(textPrimary, 0.15)
    property color borderStrong: (val('colors.overrides.borderStrong', themeData.borderStrongOverride) !== undefined)
        ? val('colors.overrides.borderStrong', themeData.borderStrongOverride) : Color.withAlpha(textPrimary, 0.30)
    property color overlayWeak: (val('colors.overrides.overlayWeak', themeData.overlayWeakOverride) !== undefined)
        ? val('colors.overrides.overlayWeak', themeData.overlayWeakOverride) : Color.withAlpha(shadow, 0.08)
    property color overlayStrong: (val('colors.overrides.overlayStrong', themeData.overlayStrongOverride) !== undefined)
        ? val('colors.overrides.overlayStrong', themeData.overlayStrongOverride) : Color.withAlpha(shadow, 0.18)
}
