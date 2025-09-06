import QtQuick
import qs.Settings

// Generic hover/background rectangle driven purely by tokens/inputs.
// - colorToken: color to render (e.g., Theme.surfaceHover)
// - radiusFactor: corner radius as fraction of height (e.g., Theme.sidePanelButtonHoverRadiusFactor)
// - epsToken: minimal visible threshold (e.g., Theme.uiVisibilityEpsilon)
// - intensity: effective opacity (0..1) controlled by caller (e.g., hover/active state)
Rectangle {
    id: hoverRect
    property color colorToken: Theme.surfaceHover
    property real radiusFactor:0.5
    property real epsToken:Theme.uiVisibilityEpsilon
    property real intensity:0.0

    anchors.fill: parent
    color: colorToken
    opacity: intensity
    radius: Math.round(height * radiusFactor)
    visible: intensity > epsToken
    antialiasing: false
}

