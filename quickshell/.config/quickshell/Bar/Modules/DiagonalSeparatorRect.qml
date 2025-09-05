import QtQuick
import qs.Components
import qs.Settings
import "../../Helpers/Color.js" as Color

// Backward-compatible wrapper around ThemedSeparator with kind: 'diagonal'.
// Keeps the existing API (alpha/thickness/angleDeg/inset/stripe* props).
Item {
    id: root
    // Expose legacy properties
    property color color: Theme.borderSubtle
    property real alpha: Theme.uiSeparatorDiagonalAlpha
    property real thickness: Theme.uiSeparatorDiagonalThickness
    property real angleDeg: Theme.uiSeparatorDiagonalAngleDeg
    property real inset: Theme.uiSeparatorDiagonalInset
    property bool stripeEnabled: true
    property real stripeBrightness: Theme.uiSeparatorDiagonalStripeBrightness
    property color stripeColor: Color.towardsBlack(Theme.accentPrimary, 1 - stripeBrightness)
    property real stripeOpacity: Theme.uiSeparatorStripeOpacity
    property real stripeRatio: Theme.uiSeparatorDiagonalStripeRatio
    property bool stripeOnRight: true

    // Keep same implicit size defaults
    implicitWidth: Theme.uiDiagonalSeparatorImplicitWidth
    implicitHeight: Theme.uiDiagonalSeparatorImplicitHeight

    ThemedSeparator {
        id: sep
        anchors.fill: parent
        kind: "diagonal"
        // Pass the panel screen if available on a parent chain
        screen: (typeof panel !== 'undefined') ? panel.screen : undefined
        color: root.color
        sepOpacity: root.alpha
        thickness: root.thickness
        angleDeg: root.angleDeg
        inset: root.inset
        stripeEnabled: root.stripeEnabled
        // Allow explicit stripeColor override via wrapper property
        stripeBrightness: root.stripeBrightness
        stripeColor: root.stripeColor
        stripeOpacity: root.stripeOpacity
        stripeRatio: root.stripeRatio
        stripeOnRight: root.stripeOnRight
    }
}
