import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Services
import qs.Settings

Item {
    id: root
    // Public widget state
    property string wsName: "?"
    property int wsId: -1

    // Accent palette (override if needed)
    property color iconColor: "#3b7bb3"
    property color gothicColor: "#D6DFE6"
    property color separatorColor: "#8d9eb2"

    // Icon layout tuning
    property real iconScale: 1.45            // icon size relative to label font
    property int  iconBaselineOffset: 4      // fine baseline tweak for icon (−2..+6 typical)
    property int  iconSpacing: 2             // gap between icon and text

    // Size follows the composed row
    implicitWidth: lineBox.implicitWidth
    implicitHeight: lineBox.implicitHeight

    // Environment helpers
    function hyprSig() { return Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || ""; }
    function runtimeDir() { return Quickshell.env("XDG_RUNTIME_DIR") || ("/run/user/" + Quickshell.env("UID")); }
    function socketPath() { return runtimeDir() + "/hypr/" + hyprSig() + "/.socket2.sock"; }
    function hyprEnvOrNull() {
        const sig = hyprSig();
        return sig ? ["HYPRLAND_INSTANCE_SIGNATURE=" + sig] : null;
    }

    // HTML escape (compatible with older Qt without replaceAll)
    function htmlEscape(s) {
        s = (s === undefined || s === null) ? "" : String(s);
        return s
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
    }

    // Character classifiers
    function isPUA(cp) { return cp >= 0xE000 && cp <= 0xF8FF; }          // Private Use Area (icon fonts)
    function isOldItalic(cp){ return cp >= 0x10300 && cp <= 0x1034F; }   // Old Italic block (e.g., 𐌰)
    function isSeparatorChar(ch){ return [":","·","|","/","-"].indexOf(ch) !== -1; }

    // Wrap one char into colored span by category
    function spanForChar(ch) {
        const cp = ch.codePointAt(0);
        if (isPUA(cp)) {
            return "<span style='color:" + iconColor + "'>" + htmlEscape(ch) + "</span>";
        }
        if (isOldItalic(cp)) {
            return "<span style='color:" + gothicColor + "'>" + htmlEscape(ch) + "</span>";
        }
        if (isSeparatorChar(ch)) {
            return "<span style='color:" + separatorColor + "'>" + htmlEscape(ch) + "</span>";
        }
        return htmlEscape(ch);
    }

    // Decorate whole string while preserving other text
    function decorateName(name) {
        if (!name || typeof name !== "string") return htmlEscape(name || "");
        let out = "";
        for (let i = 0; i < name.length; ) {
            const cp = name.codePointAt(i);
            const ch = String.fromCodePoint(cp);
            out += spanForChar(ch);
            i += (cp > 0xFFFF) ? 2 : 1; // handle surrogate pairs
        }
        return out;
    }

    // Split leading PUA icon from the rest (so we can baseline-align it)
    function leadingIcon(name) {
        if (!name || typeof name !== "string" || name.length === 0) return "";
        const cp = name.codePointAt(0);
        return isPUA(cp) ? String.fromCodePoint(cp) : "";
    }

    function restAfterLeadingIcon(name) {
        if (!name || typeof name !== "string" || name.length === 0) return "";
        const cp = name.codePointAt(0);
        if (!isPUA(cp)) return name;
        const skip = (cp > 0xFFFF) ? 2 : 1; // skip surrogate pair if needed
        return name.substring(skip);
    }

    // Final values for display
    property string iconGlyph: leadingIcon(wsName)
    property string restName: restAfterLeadingIcon(wsName)

    // Fallback to workspace id if name is empty
    property string fallbackText: (wsId >= 0 ? String(wsId) : "?")

    // RichText decoration for the rest of the name (or fallback)
    property string decoratedText: (restName && restName.length > 0)
                                   ? decorateName(restName)
                                   : decorateName(fallbackText)

    // ---------------- UI ----------------
    Row {
        id: lineBox
        spacing: iconGlyph.length ? iconSpacing : 0
        anchors.fill: parent
        // implicit sizes come from children

        // Icon as separate Text with baseline alignment to the label
        Text {
            id: icon
            visible: iconGlyph.length > 0
            text: iconGlyph
            color: iconColor
            renderType: Text.NativeRendering

            // Icon size scales from the label's font size
            font.family: Theme.fontFamily   // replace with your icon font family if needed
            font.pixelSize: Math.round(label.font.pixelSize * iconScale)

            // Baseline alignment (tweak offset for pixel-perfect visual centering)
            anchors.baseline: label.baseline
            anchors.baselineOffset: iconBaselineOffset
            padding: 4
        }

        // Main text remains RichText with soft decoration
        Label {
            id: label
            textFormat: Text.RichText
            renderType: Text.NativeRendering
            text: decoratedText
            font.family: Theme.fontFamily
            font.weight: Font.Medium
            font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
            color: Theme.textPrimary
            padding: 6

            // Optional: lock line box so icon never affects line height
            // lineHeightMode: Text.FixedHeight
            // lineHeight: Math.round(font.pixelSize * 1.1)
        }
    }

    // Live events via Hyprland socket2 (using socat). Replace with ncat -U if desired.
    Process {
        id: eventMonitor
        command: ["socat", "-u", "UNIX-CONNECT:" + socketPath(), "-"]
        running: true
        property int consumed: 0  // cursor into cumulative stdout buffer

        stdout: StdioCollector {
            waitForEnd: false
            onTextChanged: {
                const all = text;
                if (eventMonitor.consumed >= all.length) return;

                const chunk = all.substring(eventMonitor.consumed);
                eventMonitor.consumed = all.length;

                // Split into lines; if last is partial, roll back so it's read next time
                let lines = chunk.split("\n");
                const last = lines.pop();
                if (last && !chunk.endsWith("\n")) {
                    eventMonitor.consumed -= last.length;
                } else if (last) {
                    lines.push(last);
                }

                for (let line of lines) {
                    line = (line || "").trim();
                    if (!line) continue;

                    if (line.startsWith("workspace>>")) {
                        const id = parseInt(line.substring(11).trim());
                        if (!isNaN(id)) { root.wsId = id; root.wsName = ""; }
                    } else if (line.startsWith("workspacev2>>")) {
                        // Format: "workspacev2>><id>,name:<name>"
                        const payload = line.substring(13);
                        const parts = payload.split(",", 2);
                        const id = parseInt(parts[0]);
                        if (!isNaN(id)) root.wsId = id;
                        let name = (parts[1] || "").trim();
                        if (name.startsWith("name:")) name = name.substring(5);
                        root.wsName = name;
                    } else if (line.startsWith("focusedmon>>") || line.startsWith("focusedmonv2>>")) {
                        // Monitor focus changed — refresh current workspace via hyprctl
                        refreshOnce.start();
                    }
                }
            }
        }

        stderr: StdioCollector {
            waitForEnd: false
            onTextChanged: { if (text) console.error("socket2(stderr):", text); }
        }

        onExited: {
            console.warn("socket2 reader exited (code:", exitCode, "), restarting…");
            eventMonitor.consumed = 0;
            running = true;
        }

        Component.onCompleted: running = true
    }

    // One-shot refresh using hyprctl (JSON)
    Process {
        id: getCurrentWS
        command: ["hyprctl", "-j", "activeworkspace"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const obj = JSON.parse(text);
                    root.wsId = obj.id;
                    root.wsName = obj.name;
                    console.log("Workspace updated:", obj.id, obj.name);
                } catch (e) {
                    console.error("activeworkspace parse error:", e, "Raw:", text);
                }
            }
        }
        stderr: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (text && text.length) console.error("hyprctl(activeworkspace) stderr:", text);
            }
        }
        environment: hyprEnvOrNull()
    }

    // Debounce before asking hyprctl again (used on monitor focus change)
    Timer {
        id: refreshOnce
        interval: 120
        onTriggered: getCurrentWS.running = true
    }

    // Initial sync at component creation
    Component.onCompleted: getCurrentWS.running = true
}
