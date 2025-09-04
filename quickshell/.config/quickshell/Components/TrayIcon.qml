import QtQuick
import QtQuick.Effects
import Quickshell.Widgets

// TrayIcon — wrapper for system tray icons with HiDPI sizing and optional grayscale
Item {
    id: root
    // Original icon string (may contain '?path=...' suffix)
    property string source: ""
    // Icon logical size in px
    property int size: 16
    // Apply grayscale effect (used when overlay is visible)
    property bool grayscale: false
    // Optional screen reference for scaling if needed by parent
    property var screen: null

    width: size
    height: size

    // Expose readiness like Image.Ready predicate
    readonly property bool ready: img.status === Image.Ready

    // Resolve `?path=` pattern seen in tray item icons
    function resolvedSource() {
        var icon = source || "";
        if (!icon) return "";
        if (icon.indexOf("?path=") !== -1) {
            var parts = icon.split("?path=");
            var name = parts[0];
            var path = parts[1] || "";
            var fileName = name.substring(name.lastIndexOf("/") + 1);
            return `file://${path}/${fileName}`;
        }
        return icon;
    }

    IconImage {
        id: img
        anchors.centerIn: parent
        width: root.size
        height: root.size
        smooth: false
        backer.mipmap: false
        asynchronous: true
        backer.fillMode: Image.PreserveAspectFit
        // Request device-pixel-aligned backing texture for crisp rendering
        backer.sourceSize: Qt.size(
            Math.round(width  * Screen.devicePixelRatio),
            Math.round(height * Screen.devicePixelRatio)
        )
        source: root.resolvedSource()

        // Optional grayscale effect (e.g., while overlay is up)
        layer.enabled: root.grayscale
        layer.smooth: false
        layer.samples: 1
        layer.effect: MultiEffect {
            saturation: 0.0
            brightness: 0.0
            contrast: 1.0
        }
    }
}

