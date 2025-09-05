import QtQuick
import qs.Settings

MouseArea {
    id: root
    property string icon
    property bool enabled: true
    property bool hovering: false
    property var screen: null
    property real size: Math.round(Theme.panelIconSize * Theme.scale(screen || Screen))
    // Rotation for the icon glyph (degrees).
    property real iconRotation: 0
    // Unified alias for API parity
    property alias rotationAngle: root.iconRotation
    // Corner radius (allows per-usage override)
    property int cornerRadius: Theme.cornerRadiusSmall
    // Customizable colors
    property color accentColor: Theme.accentPrimary
    property color iconNormalColor: Theme.textPrimary
    property color iconHoverColor: Theme.onAccent
    // Rounded Material symbol family (forwarded)
    property bool rounded: false
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
        size: root.size
        color: root.hovering ? root.iconHoverColor : root.iconNormalColor
        opacity: root.enabled ? 1.0 : 0.5
        rotationAngle: root.iconRotation
        rounded: root.rounded
        screen: root.screen
    }
}
