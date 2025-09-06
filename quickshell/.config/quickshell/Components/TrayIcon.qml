import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import qs.Settings
import qs.Components
// QML requires import qualifiers to start with an uppercase letter
import "../Helpers/Url.js" as Url

// TrayIcon — wrapper for system tray icons with HiDPI sizing and optional grayscale
Item {
    id: root
    // Original icon string (may contain '?path=...' suffix)
    property string source: ""
    // Icon logical size in px
    property int size: Theme.panelIconSizeSmall
    // Rotation in degrees (applies to image and fallback)
    property real rotationAngle: 0
    // Apply grayscale effect (used when overlay is visible)
    property bool grayscale: false
    // Optional screen reference for scaling if needed by parent
    property var screen: null
    // Unified color prop (applies to fallback icon)
    property alias color: root.fallbackColor
    // Use Rounded Material family for fallback icon
    property bool rounded: false
    // Custom fallback icon (Material Symbols name). If empty, uses Settings.settings.trayFallbackIcon
    property string fallbackIcon: (Settings.settings && Settings.settings.trayFallbackIcon) ? Settings.settings.trayFallbackIcon : "broken_image"
    // Optional fallback styling overrides
    property color fallbackColor: Theme.textSecondary
    property int fallbackSize:size

    width: size
    height: size
    rotation: rotationAngle
    transformOrigin: Item.Center

    // Expose readiness like Image.Ready predicate
    readonly property bool ready: img.status === Image.Ready

    // Resolve optional query string and support `path` param robustly
    function resolvedSource() {
        try {
            var icon = source || "";
            if (!icon) return "";

            // Remove query and parse lightweight params we care about
            var qIndex = icon.indexOf("?");
            var base = (qIndex === -1) ? icon : icon.slice(0, qIndex);
            var query = (qIndex === -1) ? "" : icon.slice(qIndex);

            // Normalize obvious fallbacks to force our MaterialIcon fallback (avoid noisy warnings)
            if (base === "application-x-executable") return "";

            // Convert file path style icons into theme lookups by basename
            if (base.indexOf('/') !== -1 && !base.startsWith("image://")) {
                var b = base.substring(base.lastIndexOf('/') + 1);
                b = b.replace(/\.(png|svg|xpm)$/i, '');
                return "image://icon/" + b;
            }

            // If icon is reverse-DNS like net.foo.bar, use the last token
            if (base.indexOf('.') !== -1 && !base.startsWith("image://")) {
                var tokens = base.split('.');
                base = tokens[tokens.length - 1];
            }

            // Handle explicit path=? query param (legacy). Convert to file URL
            if (query && query.length > 0) {
                var params = Url.parseQuery(query);
                var path = params["path"];
                if (path && path.length > 0) {
                    var fileName = base.substring(base.lastIndexOf("/") + 1);
                    return Url.buildFileUrl(path, fileName);
                }
            }

            // Pass through image:// and qrc:/
            if (base.startsWith("image://") || base.startsWith("qrc:/") || base.startsWith("file:")) return base;

            // Default: theme icon name
            return base;
        } catch (e) {
            return source || "";
        }
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
        // Enforce a sensible minimum backing size to avoid tiny provider requests (e.g., 2x2)
        backer.sourceSize: (function(){
            var wpx = Math.round(width  * Screen.devicePixelRatio);
            var hpx = Math.round(height * Screen.devicePixelRatio);
            var minPx = Math.max(12, Math.round(Theme.panelIconSizeSmall * Screen.devicePixelRatio));
            return Qt.size(Math.max(minPx, wpx), Math.max(minPx, hpx));
        })()
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

    // Silent fallback when icon source fails to load
    // Render a generic Material icon instead of leaving a blank spot
    MaterialIcon {
        anchors.centerIn: parent
        size: root.fallbackSize
        icon: root.fallbackIcon && root.fallbackIcon.length > 0 ? root.fallbackIcon : "broken_image"
        color: root.fallbackColor
        visible: (img.status === Image.Error) || (!img.source || img.source === "")
        rotationAngle: root.rotationAngle
        rounded: root.rounded
    }

    // Simple rotation animation to match MaterialIcon behavior
    Behavior on rotation { RotateBehavior {} }
}
