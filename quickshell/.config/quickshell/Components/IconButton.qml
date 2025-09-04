import QtQuick
import qs.Settings

MouseArea {
    id: root
    property string icon
    property bool enabled: true
    property bool hovering: false
    property real size: 32
    // Rotation for the icon glyph (degrees). Useful for directional toggles.
    property real iconRotation: 0
    // Corner radius (allows per-usage override)
    property int cornerRadius: 8
    // Customizable colors
    property color accentColor: Theme.accentPrimary
    property color iconNormalColor: Theme.textPrimary
    property color iconHoverColor: Theme.onAccent
    cursorShape: Qt.PointingHandCursor
    implicitWidth: size
    implicitHeight: size

    hoverEnabled: true
    onEntered: hovering = true
    onExited: hovering = false

    Rectangle {
        anchors.fill: parent
        radius: cornerRadius
        color: root.hovering ? root.accentColor : "transparent"
    }
    MaterialIcon {
        id: iconText
        anchors.centerIn: parent
        icon: root.icon
        size: 24 * Theme.scale(Screen)
        color: root.hovering ? root.iconHoverColor : root.iconNormalColor
        opacity: root.enabled ? 1.0 : 0.5
        rotationAngle: root.iconRotation
    }
}
