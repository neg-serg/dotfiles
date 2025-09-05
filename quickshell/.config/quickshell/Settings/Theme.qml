// Theme.qml
pragma Singleton
import QtQuick
import "../Helpers/Utils.js" as Utils
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
            property string backgroundPrimary:  "#ef000000"
            property string backgroundSecondary: "#12151F"
            property string backgroundTertiary:  "#1B1F2B"
            // Surfaces & Elevation
            property string surface:        "#181C25"
            property string surfaceVariant: "#242A35"
            // Text Colors
            property string textPrimary:   "#CBD6E5"
            property string textSecondary: "#AEB9C8"
            property string textDisabled:  "#6B718A"
            // Accent Colors
            property string accentPrimary:   "#006FCC"
            property string accentSecondary: "#0077DB"
            property string accentTertiary:  "#0064B8"
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
            property int calendarRowSpacing: 12
            property int calendarCellSpacing: 8
            property int calendarSideMargin: 8

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
            property int  calendarWidth: 340
            property int  calendarHeight: 380
            property int  calendarPopupMargin: 4
            property int  calendarBorderWidth: 1
            property int  calendarCellSize: 32
            property int  calendarHolidayDotSize: 4
        }
    }
    
    // Backgrounds
    property color backgroundPrimary: themeData.backgroundPrimary
    property color backgroundSecondary: themeData.backgroundSecondary
    property color backgroundTertiary: themeData.backgroundTertiary
    // Surfaces & Elevation
    property color surface: themeData.surface
    property color surfaceVariant: themeData.surfaceVariant
    // Text Colors
    property color textPrimary: themeData.textPrimary
    property color textSecondary: themeData.textSecondary
    property color textDisabled: themeData.textDisabled
    // Accent Colors
    property color accentPrimary: themeData.accentPrimary
    property color accentSecondary: themeData.accentSecondary
    property color accentTertiary: themeData.accentTertiary
    // Error/Warning
    property color error: themeData.error
    property color warning: themeData.warning
    // Highlights & Focus
    property color highlight: themeData.highlight
    property color rippleEffect: themeData.rippleEffect
    // Additional Theme Properties
    property color onAccent: themeData.onAccent
    property color outline: themeData.outline
    // Shadows & Overlays
    property color shadow: applyOpacity(themeData.shadow, "B3")
    property color overlay: applyOpacity(themeData.overlay, "66")
    property string fontFamily: "Iosevka" // Font Properties
    // Font size multiplier - adjust this in Settings.json to scale all fonts
    property real fontSizeMultiplier: Settings.settings.fontSizeMultiplier || 1.0
    // Base font sizes (multiplied by fontSizeMultiplier)
    property int fontSizeHeader: Math.round(32 * fontSizeMultiplier)     // Headers and titles
    property int fontSizeBody: Math.round(16 * fontSizeMultiplier)       // Body text and general content
    property int fontSizeSmall: Math.round(14 * fontSizeMultiplier)      // Small text like clock, labels
    property int fontSizeCaption: Math.round(12 * fontSizeMultiplier)    // Captions and fine print

    // Panel metrics (logical)
    property int panelHeight: Utils.clamp(themeData.panelHeight, 16, 64)
    property int panelSideMargin: themeData.panelSideMargin
    property int panelWidgetSpacing: themeData.panelWidgetSpacing
    property int panelSepOvershoot: themeData.panelSepOvershoot
    // Panel icon sizing
    property int panelIconSize: themeData.panelIconSize
    property int panelIconSizeSmall: themeData.panelIconSizeSmall
    property int panelGlyphSize: themeData.panelGlyphSize
    // Panel hot-zone
    property int panelHotzoneWidth: Math.max(4, Math.min(64, themeData.panelHotzoneWidth))
    property int panelHotzoneHeight: Math.max(2, Math.min(64, themeData.panelHotzoneHeight))
    property real panelHotzoneRightShift: Math.max(0.5, Math.min(3.0, themeData.panelHotzoneRightShift))
    property int panelModuleHeight: themeData.panelModuleHeight
    property int panelMenuYOffset: themeData.panelMenuYOffset
    // Corners
    property int cornerRadius: themeData.cornerRadius
    property int cornerRadiusSmall: themeData.cornerRadiusSmall
    // Tooltip
    property int tooltipDelayMs: themeData.tooltipDelayMs
    property int tooltipMinSize: themeData.tooltipMinSize
    property int tooltipMargin: themeData.tooltipMargin
    property int tooltipPadding: themeData.tooltipPadding
    property int tooltipBorderWidth: themeData.tooltipBorderWidth
    property int tooltipRadius: themeData.tooltipRadius
    property int tooltipFontPx: themeData.tooltipFontPx
    // Pill indicator defaults
    property int panelPillHeight: themeData.panelPillHeight
    property int panelPillIconSize: themeData.panelPillIconSize
    property int panelPillPaddingH: themeData.panelPillPaddingH
    property int panelPillShowDelayMs: themeData.panelPillShowDelayMs
    property int panelPillAutoHidePauseMs: themeData.panelPillAutoHidePauseMs
    property color panelPillBackground: themeData.panelPillBackground
    // Animation timings
    property int panelAnimStdMs: Math.max(0, Math.min(5000, themeData.panelAnimStdMs))
    property int panelAnimFastMs: Math.max(0, Math.min(5000, themeData.panelAnimFastMs))
    // Tray behavior timings
    property int panelTrayLongHoldMs: Math.max(0, Math.min(10000, themeData.panelTrayLongHoldMs))
    property int panelTrayShortHoldMs: Math.max(0, Math.min(10000, themeData.panelTrayShortHoldMs))
    property int panelTrayGuardMs: Math.max(0, Math.min(2000, themeData.panelTrayGuardMs))
    property int panelTrayOverlayDismissDelayMs: Math.max(0, Math.min(600000, themeData.panelTrayOverlayDismissDelayMs))
    // Generic row spacing
    property int panelRowSpacing: themeData.panelRowSpacing
    property int panelRowSpacingSmall: themeData.panelRowSpacingSmall
    // Volume behavior
    property int panelVolumeFullHideMs: themeData.panelVolumeFullHideMs
    property color panelVolumeLowColor: themeData.panelVolumeLowColor
    property color panelVolumeHighColor: themeData.panelVolumeHighColor
    // Core module timings
    property int timeTickMs: Math.max(100, Math.min(60000, themeData.timeTickMs))
    property int wsRefreshDebounceMs: Math.max(0, Math.min(10000, themeData.wsRefreshDebounceMs))
    property int vpnPollMs: Math.max(500, Math.min(600000, themeData.vpnPollMs))
    property int networkRestartBackoffMs: Math.max(0, Math.min(600000, themeData.networkRestartBackoffMs))
    property int networkLinkPollMs: Math.max(500, Math.min(600000, themeData.networkLinkPollMs))
    property int mediaHoverOpenDelayMs: Math.max(0, Math.min(5000, themeData.mediaHoverOpenDelayMs))
    property int mediaHoverStillThresholdMs: Math.max(0, Math.min(10000, themeData.mediaHoverStillThresholdMs))
    property int spectrumPeakDecayIntervalMs: Math.max(10, Math.min(1000, themeData.spectrumPeakDecayIntervalMs))
    property int spectrumBarAnimMs: Math.max(0, Math.min(5000, themeData.spectrumBarAnimMs))
    property int musicPositionPollMs: Math.max(100, Math.min(600000, themeData.musicPositionPollMs))
    property int musicPlayersPollMs: Math.max(100, Math.min(600000, themeData.musicPlayersPollMs))
    property int musicMetaRecalcDebounceMs: Math.max(0, Math.min(10000, themeData.musicMetaRecalcDebounceMs))
    // Calendar metrics
    property int calendarRowSpacing: themeData.calendarRowSpacing
    property int calendarCellSpacing: themeData.calendarCellSpacing
    property int calendarSideMargin: themeData.calendarSideMargin
    // Side-panel popup timings/margins
    property int  sidePanelPopupSlideMs: themeData.sidePanelPopupSlideMs
    property int  sidePanelPopupAutoHideMs: themeData.sidePanelPopupAutoHideMs
    property int  sidePanelPopupOuterMargin: themeData.sidePanelPopupOuterMargin
    // Side-panel spacing medium
    property int  sidePanelSpacingMedium: themeData.sidePanelSpacingMedium
    // Hover behavior
    property real panelHoverOpacity: themeData.panelHoverOpacity
    property int  panelHoverFadeMs: themeData.panelHoverFadeMs
    // Panel menu metrics
    property int  panelMenuWidth: Utils.clamp(themeData.panelMenuWidth, 100, 600)
    property int  panelSubmenuWidth: themeData.panelSubmenuWidth
    property int  panelMenuPadding: Math.max(0, Math.min(32, themeData.panelMenuPadding))
    property int  panelMenuItemSpacing: Math.max(0, Math.min(16, themeData.panelMenuItemSpacing))
    property int  panelMenuItemHeight: Math.max(16, Math.min(64, themeData.panelMenuItemHeight))
    property int  panelMenuSeparatorHeight: Math.max(1, Math.min(16, themeData.panelMenuSeparatorHeight))
    property int  panelMenuDividerMargin: Math.max(0, Math.min(32, themeData.panelMenuDividerMargin))
    property int  panelMenuRadius: Math.max(0, Math.min(32, themeData.panelMenuRadius))
    property int  panelMenuHeightExtra: Math.max(0, Math.min(64, themeData.panelMenuHeightExtra))
    property int  panelMenuAnchorYOffset: Math.max(-20, Math.min(100, themeData.panelMenuAnchorYOffset))
    property int  panelSubmenuGap: themeData.panelSubmenuGap
    property int  panelMenuChevronSize: themeData.panelMenuChevronSize
    property int  panelMenuIconSize: themeData.panelMenuIconSize
    // Side panel exports
    property int sidePanelCornerRadius: themeData.sidePanelCornerRadius
    property int sidePanelSpacing: themeData.sidePanelSpacing
    property int sidePanelSpacingTight: themeData.sidePanelSpacingTight
    property int sidePanelSpacingSmall: themeData.sidePanelSpacingSmall
    property int sidePanelAlbumArtSize: themeData.sidePanelAlbumArtSize
    property int sidePanelWeatherWidth: themeData.sidePanelWeatherWidth
    property int sidePanelWeatherHeight: themeData.sidePanelWeatherHeight
    property int uiIconSizeLarge: themeData.uiIconSizeLarge
    // Overlay radius and larger corner
    property int panelOverlayRadius: themeData.panelOverlayRadius
    property int cornerRadiusLarge: themeData.cornerRadiusLarge
    // Generic UI spacings/margins
    property int uiMarginLarge: Math.max(0, Math.min(128, themeData.uiMarginLarge))
    property int uiMarginMedium: Math.max(0, Math.min(64, themeData.uiMarginMedium))
    property int uiPaddingMedium: Math.max(0, Math.min(64, themeData.uiPaddingMedium))
    property int uiSpacingLarge: Math.max(0, Math.min(64, themeData.uiSpacingLarge))
    property int uiSpacingSmall: Math.max(0, Math.min(32, themeData.uiSpacingSmall))
    property int uiSpacingXSmall: Math.max(0, Math.min(16, themeData.uiSpacingXSmall))
    property int uiGapTiny: themeData.uiGapTiny
    property int uiControlHeight: themeData.uiControlHeight
    // Calendar popup sizing
    property int calendarWidth: Math.max(200, Math.min(800, themeData.calendarWidth))
    property int calendarHeight: Math.max(200, Math.min(800, themeData.calendarHeight))
    property int calendarPopupMargin: Math.max(0, Math.min(32, themeData.calendarPopupMargin))
    property int calendarBorderWidth: themeData.calendarBorderWidth
    property int calendarCellSize: Math.max(16, Math.min(64, themeData.calendarCellSize))
    property int calendarHolidayDotSize: themeData.calendarHolidayDotSize
}
