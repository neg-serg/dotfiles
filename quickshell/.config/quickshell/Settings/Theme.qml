// Theme.qml
pragma Singleton
import QtQuick
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
        return color.replace("#", "#" + opacity);
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
    property int panelHeight: themeData.panelHeight
    property int panelSideMargin: themeData.panelSideMargin
    property int panelWidgetSpacing: themeData.panelWidgetSpacing
    property int panelSepOvershoot: themeData.panelSepOvershoot
    // Panel icon sizing
    property int panelIconSize: themeData.panelIconSize
    property int panelIconSizeSmall: themeData.panelIconSizeSmall
    property int panelGlyphSize: themeData.panelGlyphSize
    // Panel hot-zone
    property int panelHotzoneWidth: themeData.panelHotzoneWidth
    property int panelHotzoneHeight: themeData.panelHotzoneHeight
    property real panelHotzoneRightShift: themeData.panelHotzoneRightShift
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
    property int panelAnimStdMs: themeData.panelAnimStdMs
    property int panelAnimFastMs: themeData.panelAnimFastMs
    // Tray behavior timings
    property int panelTrayLongHoldMs: themeData.panelTrayLongHoldMs
    property int panelTrayShortHoldMs: themeData.panelTrayShortHoldMs
    property int panelTrayGuardMs: themeData.panelTrayGuardMs
    property int panelTrayOverlayDismissDelayMs: themeData.panelTrayOverlayDismissDelayMs
    // Generic row spacing
    property int panelRowSpacing: themeData.panelRowSpacing
    property int panelRowSpacingSmall: themeData.panelRowSpacingSmall
    // Volume behavior
    property int panelVolumeFullHideMs: themeData.panelVolumeFullHideMs
    property color panelVolumeLowColor: themeData.panelVolumeLowColor
    property color panelVolumeHighColor: themeData.panelVolumeHighColor
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
    property int  panelMenuWidth: themeData.panelMenuWidth
    property int  panelSubmenuWidth: themeData.panelSubmenuWidth
    property int  panelMenuPadding: themeData.panelMenuPadding
    property int  panelMenuItemSpacing: themeData.panelMenuItemSpacing
    property int  panelMenuItemHeight: themeData.panelMenuItemHeight
    property int  panelMenuSeparatorHeight: themeData.panelMenuSeparatorHeight
    property int  panelMenuDividerMargin: themeData.panelMenuDividerMargin
    property int  panelMenuRadius: themeData.panelMenuRadius
    property int  panelMenuHeightExtra: themeData.panelMenuHeightExtra
    property int  panelMenuAnchorYOffset: themeData.panelMenuAnchorYOffset
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
}
