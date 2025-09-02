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
}
