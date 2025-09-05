import QtQuick
import qs.Settings
import "../../Helpers/Color.js" as Color
import "../../Helpers/Utils.js" as Utils

Item {
    id: root
    property color color: Theme.borderSubtle
    property real alpha: 0.05
    property real thickness: 7.0
    property real angleDeg: 30
    property real inset: 4
    // Accent stripe options
    property bool  stripeEnabled: true
    // Darken accent strongly towards black to reduce brightness
    property real  stripeBrightness: 0.4 // 0..1, lower = closer to black
    property color stripeColor: Color.towardsBlack(Theme.accentPrimary, 1 - stripeBrightness)
    property real  stripeOpacity: Theme.uiSeparatorStripeOpacity
    // Portion of thickness used by the accent stripe (0..1)
    property real  stripeRatio: 0.35
    // Which side to draw the stripe on: true = right edge, false = left edge
    property bool  stripeOnRight: true

    implicitWidth: 10
    implicitHeight: 28

    Rectangle {
        id: line
        width: Math.round(thickness * Theme.scale(panel.screen))
        // Snap height to whole pixels to avoid subpixel blur when rotated
        height: Math.round(Math.hypot(root.width, root.height) - inset*2)
        radius: Theme.uiSeparatorRadius
        // Apply alpha in color so children (accent stripe) are not faded
        color: Qt.rgba(root.color.r, root.color.g, root.color.b, root.alpha)
        anchors.centerIn: parent
        anchors.verticalCenter: parent.verticalCenter
        rotation: angleDeg
        transformOrigin: Item.Center
        // Make edges crisper by avoiding smoothing/antialiasing on rotated texture
        antialiasing: false
        layer.enabled: true
        layer.smooth: false

        // Accent stripe along one edge of the diagonal line
        Rectangle {
            id: stripe
            visible: root.stripeEnabled && root.stripeRatio > 0
            width: Math.max(1, Math.round(line.width * Utils.clamp(root.stripeRatio, 0, 1)))
            height: parent.height
            color: root.stripeColor
            opacity: root.stripeOpacity
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: root.stripeOnRight ? undefined : parent.left
            anchors.right: root.stripeOnRight ? parent.right : undefined
            antialiasing: false
        }
    }
}
