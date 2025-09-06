import QtQuick
import qs.Settings
import "../Helpers/Color.js" as Color

// ContrastGuard: chooses a readable foreground color for a given background and logs when contrast is low.
// Props:
// - bg: background color
// - preferLight / preferDark: candidate foreground colors (defaults to Theme.textPrimary/Secondary)
// - threshold: luminance threshold for choosing light/dark (uses Theme.contrastThreshold)
// - warnRatio: minimum acceptable WCAG contrast ratio for logging (defaults to Settings.settings.contrastWarnRatio)
// - label: optional context label used in logs
// Outputs:
// - fg: chosen foreground color
// - ratio: computed contrast ratio between bg and fg
QtObject {
    id: guard
    property color bg: "transparent"
    property color preferLight: Theme.textPrimary
    property color preferDark: Theme.textSecondary
    property real  threshold: Theme.contrastThreshold
    property real  warnRatio: (Settings.settings && Settings.settings.contrastWarnRatio !== undefined)
        ? Settings.settings.contrastWarnRatio : 4.5
    property string label: ""

    readonly property color fg: Color.contrastOn(bg, preferLight, preferDark, threshold)
    readonly property real  ratio: Color.contrastRatio(bg, fg)

    function maybeWarn() {
        try {
            if (!(Settings.settings && Settings.settings.debugContrast)) return;
            // Suppress noisy menu item warnings; menu text color is derived from base background
            if (label === 'MenuItem') return;
            // Compute ratio on demand to avoid ordering issues during initialization
            var r = Color.contrastRatio(bg, fg);
            if (!(r > 0)) return;
            if (r < warnRatio) console.warn('[ContrastGuard]', label || '(unnamed)', 'ratio', r.toFixed(2));
        } catch (e) { /* ignore */ }
    }

    onBgChanged: maybeWarn()
    onFgChanged: maybeWarn()
    Component.onCompleted: maybeWarn()
}
