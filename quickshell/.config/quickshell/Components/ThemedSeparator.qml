import QtQuick
import qs.Settings
import "../Helpers/Color.js" as Color
import "../Helpers/Utils.js" as Utils

Item {
    id: root
    // Kind can be: "diagonal", "vertical", "horizontal"
    // Use string for simplicity and readability.
    property string kind: "diagonal"

    // DPI awareness: pass screen if available to scale thickness
    property var screen

    // Visual tokens
    property color color: Theme.borderSubtle
    // Generic opacity applied via color alpha (renamed to avoid clashing with Item.opacity)
    property real sepOpacity: Theme.uiSeparatorOpacity
    // Logical thickness before scaling (defaults vary per kind)
    property real thickness: (kind === "diagonal") ? Theme.uiSeparatorDiagonalThickness : Theme.uiSeparatorThickness
    property int radius: Theme.uiSeparatorRadius

    // Diagonal-only tuning
    property real angleDeg: Theme.uiSeparatorDiagonalAngleDeg
    property int  inset: Theme.uiSeparatorDiagonalInset

    // Stripe sub-settings (generic)
    property bool  stripeEnabled: true
    // 0..1, lower = closer to black
    property real  stripeBrightness: Theme.uiSeparatorStripeBrightness
    property color stripeColor: Color.towardsBlack(Theme.accentPrimary, 1 - stripeBrightness)
    property real  stripeOpacity: Theme.uiSeparatorStripeOpacity
    // Portion of thickness used by the accent stripe (0..1)
    property real  stripeRatio: Utils.clamp(Theme.uiSeparatorStripeRatio, 0, 1)
    // Edge placement for stripe
    // For diagonal/vertical: true = right edge, false = left edge
    property bool  stripeOnRight: true
    // For horizontal: true = bottom edge, false = top edge
    property bool  stripeOnBottom: true

    // Back-compat alias: allow using 'alpha' like DiagonalSeparatorRect
    property alias alpha: root.sepOpacity

    // Implicit sizing defaults per kind
    implicitWidth: (kind === "diagonal") ? Theme.uiDiagonalSeparatorImplicitWidth
                  : (kind === "vertical") ? Math.max(1, Math.round(thickness * Theme.scale(root.screen)))
                  : 12
    implicitHeight: (kind === "diagonal") ? Theme.uiDiagonalSeparatorImplicitHeight
                   : (kind === "horizontal") ? Math.max(1, Math.round(thickness * Theme.scale(root.screen)))
                   : 12

    // --- Diagonal ---
    Rectangle {
        id: diag
        visible: root.kind === "diagonal"
        anchors.centerIn: parent
        width: Math.max(1, Math.round(root.thickness * Theme.scale(root.screen)))
        height: Math.max(1, Math.round(Math.hypot(root.width, root.height) - root.inset * 2))
        radius: root.radius
        color: Qt.rgba(root.color.r, root.color.g, root.color.b, root.sepOpacity)
        rotation: root.angleDeg
        transformOrigin: Item.Center
        antialiasing: false
        layer.enabled: true
        layer.smooth: false

        Rectangle {
            id: diagStripe
            visible: root.stripeEnabled && root.stripeRatio > 0
            width: Math.max(1, Math.round(diag.width * Utils.clamp(root.stripeRatio, 0, 1)))
            height: parent.height
            color: root.stripeColor
            opacity: root.stripeOpacity
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: root.stripeOnRight ? undefined : parent.left
            anchors.right: root.stripeOnRight ? parent.right : undefined
            antialiasing: false
        }
    }

    // --- Vertical ---
    Rectangle {
        id: vert
        visible: root.kind === "vertical"
        anchors.fill: parent
        width: Math.max(1, Math.round(root.thickness * Theme.scale(root.screen)))
        radius: root.radius
        color: Qt.rgba(root.color.r, root.color.g, root.color.b, root.sepOpacity)
        antialiasing: false
        layer.enabled: false

        Rectangle {
            id: vertStripe
            visible: root.stripeEnabled && root.stripeRatio > 0
            width: Math.max(1, Math.round(vert.width * Utils.clamp(root.stripeRatio, 0, 1)))
            height: parent.height
            color: root.stripeColor
            opacity: root.stripeOpacity
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: root.stripeOnRight ? undefined : parent.left
            anchors.right: root.stripeOnRight ? parent.right : undefined
            antialiasing: false
        }
    }

    // --- Horizontal ---
    Rectangle {
        id: hori
        visible: root.kind === "horizontal"
        anchors.fill: parent
        height: Math.max(1, Math.round(root.thickness * Theme.scale(root.screen)))
        radius: root.radius
        color: Qt.rgba(root.color.r, root.color.g, root.color.b, root.sepOpacity)
        antialiasing: false
        layer.enabled: false

        Rectangle {
            id: horiStripe
            visible: root.stripeEnabled && root.stripeRatio > 0
            height: Math.max(1, Math.round(hori.height * Utils.clamp(root.stripeRatio, 0, 1)))
            width: parent.width
            color: root.stripeColor
            opacity: root.stripeOpacity
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: root.stripeOnBottom ? undefined : parent.top
            anchors.bottom: root.stripeOnBottom ? parent.bottom : undefined
            antialiasing: false
        }
    }
}
