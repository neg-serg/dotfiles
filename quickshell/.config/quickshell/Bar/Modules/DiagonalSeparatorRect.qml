import QtQuick
import qs.Settings

Item {
    id: root
    property color color: "#BFC8D0"
    property real alpha: 0.05
    property real thickness: 7.0
    property real angleDeg: 30
    property real inset: 4
    // Accent stripe options
    property bool  stripeEnabled: true
    // Darken accent strongly towards black to reduce brightness
    property real  stripeBrightness: 0.2 // 0..1, lower = closer to black
    property color stripeColor: Qt.rgba(
        Theme.accentPrimary.r * stripeBrightness,
        Theme.accentPrimary.g * stripeBrightness,
        Theme.accentPrimary.b * stripeBrightness,
        1
    )
    property real  stripeOpacity: 0.9
    // Portion of thickness used by the accent stripe (0..1)
    property real  stripeRatio: 0.35
    // Which side to draw the stripe on: true = right edge, false = left edge
    property bool  stripeOnRight: true

    implicitWidth: 10
    implicitHeight: 28

    Rectangle {
        id: line
        width: Math.round(thickness * Theme.scale(panel.screen))
        height: Math.hypot(root.width, root.height) - inset*2
        radius: 0
        // Apply alpha in color so children (accent stripe) are not faded
        color: Qt.rgba(root.color.r, root.color.g, root.color.b, root.alpha)
        anchors.centerIn: parent
        anchors.verticalCenter: parent.verticalCenter
        rotation: angleDeg
        antialiasing: true
        layer.enabled: true
        layer.smooth: true

        // Accent stripe along one edge of the diagonal line
        Rectangle {
            id: stripe
            visible: root.stripeEnabled && root.stripeRatio > 0
            width: Math.max(1, Math.round(line.width * Math.min(1, Math.max(0, root.stripeRatio))))
            height: parent.height
            color: root.stripeColor
            opacity: root.stripeOpacity
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: root.stripeOnRight ? undefined : parent.left
            anchors.right: root.stripeOnRight ? parent.right : undefined
            antialiasing: true
        }
    }
}
