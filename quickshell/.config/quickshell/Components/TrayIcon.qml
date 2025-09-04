import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import "../Helpers/Url.js" as url

// TrayIcon — wrapper for system tray icons with HiDPI sizing and optional grayscale
Item {
    id: root
    // Original icon string (may contain '?path=...' suffix)
    property string source: ""
    // Icon logical size in px
    property int size: Theme.panelIconSizeSmall
    // Apply grayscale effect (used when overlay is visible)
    property bool grayscale: false
    // Optional screen reference for scaling if needed by parent
    property var screen: null

    width: size
    height: size

    // Expose readiness like Image.Ready predicate
    readonly property bool ready: img.status === Image.Ready

    // Resolve optional query string and support `path` param robustly
    function resolvedSource() {
        var icon = source || "";
        if (!icon) return "";

        var qIndex = icon.indexOf("?");
        if (qIndex === -1) {
            return icon;
        }

        var base = icon.slice(0, qIndex);
        var query = icon.slice(qIndex);

        // Parse via shared helper
        var params = url.parseQuery(query);

        var path = params["path"];
        if (path && path.length > 0) {
            var fileName = base.substring(base.lastIndexOf("/") + 1);
            // Build file URL via helper
            return url.buildFileUrl(path, fileName);
        }

        // Fallback: return original icon (including query)
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
