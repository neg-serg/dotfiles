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
    // Public state exposed by the widget
    property string wsName: "?"
    property int wsId: -1

    // Sizing follows the label content
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    // Environment helpers
    function hyprSig() {
        // Hyprland instance signature; empty if not present
        return Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || "";
    }
    function runtimeDir() {
        // Fallback to /run/user/$UID if XDG_RUNTIME_DIR is missing
        return Quickshell.env("XDG_RUNTIME_DIR") || ("/run/user/" + Quickshell.env("UID"));
    }
    function socketPath() {
        // $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock
        return runtimeDir() + "/hypr/" + hyprSig() + "/.socket2.sock";
    }
    function hyprEnvOrNull() {
        // Pass signature to hyprctl only when it exists
        const sig = hyprSig();
        return sig ? ["HYPRLAND_INSTANCE_SIGNATURE=" + sig] : null;
    }

    // Accent palette (safe defaults; override if needed)
    property color iconColor: "#3b7bb3"       // very light cool grey-blue
    property color gothicColor: "#D6DFE6"     // almost airy grey-blue
    property color separatorColor: "#8d9eb2"

    // htmlEscape fixed for older Qt/QML (no replaceAll)
    function htmlEscape(s) {
        s = (s === undefined || s === null) ? "" : String(s);
        return s
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
    }

    function isPUA(cp) { return cp >= 0xE000 && cp <= 0xF8FF; }          // icons / symbols in PUA
    function isOldItalic(cp){ return cp >= 0x10300 && cp <= 0x1034F; }   // Old Italic block (sample: 𐌰)
    function isSeparatorChar(ch){ return [":","·","|","/","-"].indexOf(ch) !== -1; }

    // Wraps a single character into a colored span based on its category
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

    // Converts a whole string to softly decorated HTML; preserves all other text
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

    // Final display text (HTML if wsName is present, plain fallback to id)
    property string displayText: (wsName && wsName.length > 0)
        ? decorateName(wsName)
        : (wsId >= 0 ? String(wsId) : "?")

    // UI
    Label {
        id: label
        textFormat: Text.RichText
        renderType: Text.NativeRendering
        text: displayText
        font.family: Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
        color: Theme.textPrimary // base color for non-decorated text
        padding: 6
    }

    // Live events via socket2
    // Uses `socat` to stream events; replace with `ncat -U` if you prefer.
    Process {
        id: eventMonitor
        command: ["socat", "-u", "UNIX-CONNECT:" + socketPath(), "-"]
        running: true

        // Cursor into cumulative stdout buffer to avoid re-processing
        property int consumed: 0

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
                        // Monitor focus changed: refresh current workspace via hyprctl
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

    // Small debounce before asking hyprctl again (used on monitor focus change)
    Timer {
        id: refreshOnce
        interval: 120
        onTriggered: getCurrentWS.running = true
    }

    // Initial sync at component creation
    Component.onCompleted: getCurrentWS.running = true
}
