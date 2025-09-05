import QtQuick
import qs.Settings

// OverlayFade: simple color value with a themed fade animation.
// Usage: OverlayFade { id: fade }
//        fade.value: showOverlay ? Theme.overlayStrong : "transparent"
//        color: fade.value
QtObject {
    id: fade
    property color value: "transparent"
    Behavior on value { ColorRippleBehavior {} }
}
