import QtQuick
import qs.Components
import qs.Settings
import "../../Helpers/Color.js" as Color

// Wrapper around ThemedSeparator (kind: 'diagonal'); preserves legacy props
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

    implicitWidth: Theme.uiDiagonalSeparatorImplicitWidth
    implicitHeight: Theme.uiDiagonalSeparatorImplicitHeight

    ThemedSeparator {
        id: sep
        anchors.fill: parent
        kind: "diagonal"
        screen: (typeof panel !== 'undefined') ? panel.screen : undefined
        color: root.color
        sepOpacity: root.alpha
        thickness: root.thickness
        angleDeg: root.angleDeg
        inset: root.inset
        stripeEnabled: root.stripeEnabled
        stripeBrightness: root.stripeBrightness
        stripeColor: root.stripeColor
        stripeOpacity: root.stripeOpacity
        stripeRatio: root.stripeRatio
        stripeOnRight: root.stripeOnRight
    }
}
