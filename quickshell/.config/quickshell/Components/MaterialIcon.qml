import QtQuick
import qs.Settings

// Simple Material Symbols icon wrapper with sane defaults
// Usage: MaterialIcon { icon: "play_arrow"; size: 16 * Theme.scale(screen) }
Text {
    id: root
    // Icon name (maps to Material Symbols glyph)
    property alias icon: root.text
    // Use Rounded family when true; otherwise Outlined
    property bool rounded: false
    // Optional screen for Theme.scale() callers
    property var screen: null
    // Pixel size; defaults to small text size scaled for the screen
    property int size: Math.round(Theme.fontSizeSmall * Theme.scale(screen || Screen))
    // Rotation in degrees
    property real rotationAngle: 0

    // Font family selection
    readonly property string _outlined: "Material Symbols Outlined"
    readonly property string _rounded: "Material Symbols Rounded"

    font.family: rounded ? _rounded : _outlined
    font.pixelSize: size
    color: Theme.textPrimary
    renderType: Text.NativeRendering
    transformOrigin: Item.Center
    rotation: rotationAngle
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

Behavior on rotation { RotateBehavior {} }
}
