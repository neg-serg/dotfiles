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
    // Hyprland keyboard submap name (shown to the left of workspace)
    property string submapName: ""
    // Fine-tune vertical alignment of submap icon (px; negative moves up)
    property int submapBaselineAdjust: -5
    // Live-discovered submaps from Hyprland (via hyprctl -j binds)
    property var submapDynamicMap: ({})
    // Map known submaps to clean, geometric Material Symbols
    // Extend as you adopt new submaps.
    readonly property var submapIconMap: ({
        // movement / resizing
        "move":                "open_with",
        "moving":              "open_with",
        "resize":              "open_in_full",
        "swap":                "swap_horiz",
        "swap_ws":             "swap_horiz",
        // launching / apps
        "launcher":            "apps",
        "launch":              "apps",
        // media / volume / brightness
        "media":               "play_circle",
        "volume":              "volume_up",
        "brightness":          "brightness_6",
        // windows / tiling / workspaces / monitors
        "window":              "web_asset",
        "windows":             "web_asset",
        "tile":                "grid_on",
        "tiling":              "grid_on",
        "ws":                  "grid_view",
        "workspace":           "grid_view",
        "monitor":             "monitor",
        "display":             "monitor",
        // tools / system
        "system":              "settings",
        "tools":               "build_circle",
        "gaps":                "crop_square",
        // text / edit / select / clipboard
        "select":              "select_all",
        "edit":                "edit",
        "copy":                "content_copy",
        "paste":               "content_paste",
        // terminals / code / search / screenshot
        "terminal":            "terminal",
        "shell":               "terminal",
        "code":                "code",
        "search":              "search",
        "screenshot":          "screenshot",
        // browsers
        "browser":             "language",
        "web":                 "language",
        // explicit mappings for discovered submaps
        "special":             "view_in_ar",
        "wallpaper":           "wallpaper",
    })
    
    function geometricFallbackIcon(name) {
        const shapes = [
            "crop_square",                // square
            "radio_button_unchecked",    // circle
            "change_history",            // triangle
            "hexagon",                    // hexagon
            "pentagon",                   // pentagon
            "diamond"                     // diamond
        ];
        let h = 0;
        const s = (name || "").toLowerCase();
        for (let i = 0; i < s.length; i++) h = (h * 33 + s.charCodeAt(i)) >>> 0;
        return shapes[h % shapes.length];
    }
    function submapIconName(name) {
        const key = (name || "").toLowerCase().trim();
        // Dynamic mapping from discovered submaps
        if (submapDynamicMap && submapDynamicMap[key]) return submapDynamicMap[key];
        // Static mapping table
        if (submapIconMap[key]) return submapIconMap[key];
        // Heuristics for known patterns
        if (/resiz/.test(key)) return "open_in_full";
        if (/move|drag/.test(key)) return "open_with";
        if (/swap/.test(key)) return "swap_horiz";
        if (/launch|launcher/.test(key)) return "apps";
        if (/media/.test(key)) return "play_circle";
        if (/vol|audio|sound/.test(key)) return "volume_up";
        if (/bright|light/.test(key)) return "brightness_6";
        if (/(^|_)ws|work|desk|tile|grid/.test(key)) return "grid_view";
        if (/mon|display|screen|output/.test(key)) return "monitor";
        if (/term|shell|tty/.test(key)) return "terminal";
        if (/code|dev/.test(key)) return "code";
        if (/search|find/.test(key)) return "search";
        if (/shot|screen.*shot|snap/.test(key)) return "screenshot";
        if (/browser|web|http/.test(key)) return "language";
        if (/select|sel/.test(key)) return "select_all";
        if (/edit/.test(key)) return "edit";
        if (/copy|yank/.test(key)) return "content_copy";
        if (/paste/.test(key)) return "content_paste";
        if (/sys|system|cfg|conf/.test(key)) return "settings";
        if (/gap/.test(key)) return "crop_square";
        return geometricFallbackIcon(key);
    }

    // Accent palette (override if needed)
    property color iconColor: "#3b7bb3"
    property color gothicColor: "#D6DFE6"
    property color separatorColor: "#8d9eb2"

    // Icon layout tuning
    property real iconScale: 1.45            // icon size relative to label font
    property int  iconBaselineOffset: 4      // fine baseline tweak for icon (−2..+6 typical)
    property int  iconSpacing: 1             // gap between items (tighter)

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
    function isSeparatorChar(ch){ return [":","·","|","/","-"] .indexOf(ch) !== -1; }

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
            // Replace centered dot with a plain space; keep others as-is (no blue tint)
            if (ch === "·") return " ";
            // For other separators, just echo the character without special coloring
            return htmlEscape(ch);
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
        // Trim any whitespace immediately following the icon to keep spacing consistent
        return name.substring(skip).replace(/^\s+/, "");
    }

    // Final values for display
    property string iconGlyph: leadingIcon(wsName)
    property string restName: restAfterLeadingIcon(wsName)

    // Detect terminal workspace (common PUA glyphs or name prefix)
    readonly property var _terminalIcons: ["\uf120", "\ue795", "\ue7a2"]
    property bool isTerminalWs: (function(){
        const rn = (restName || "").toLowerCase().trim();
        if (iconGlyph && _terminalIcons.indexOf(iconGlyph) !== -1) return true;
        if (rn.startsWith("term")) return true;
        if (rn.endsWith("term")) return true; // e.g., names like "dev-term"
        return false;
    })()

    // Fallback to workspace id if name is empty
    property string fallbackText: (wsId >= 0 ? String(wsId) : "?")

    // RichText decoration for the rest of the name (or fallback)
    property string decoratedText: (restName && restName.length > 0)
                                   ? decorateName(restName)
                                   : decorateName(fallbackText)

    // ---------------- UI ----------------
    Row {
        id: lineBox
        // Use a small spacing regardless; individual items add their own padding
        spacing: iconSpacing
        anchors.fill: parent
        // implicit sizes come from children

        // Metrics to compute consistent baseline offsets across fonts
        FontMetrics { id: fmIcon; font: icon.font }
        FontMetrics { id: fmSub;  font: submapIcon.font }

        // Submap icon aligned to the same baseline family as the workspace icon
        Text {
            id: submapIcon
            visible: root.submapName && root.submapName.length > 0
            text: submapIconName(root.submapName)
            color: Theme.accentPrimary
            renderType: Text.NativeRendering
            font.family: "Material Symbols Outlined"
            font.weight: Font.Medium
            font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
            // Align to label baseline like the workspace icon does,
            // then compensate for font ascent differences + fine adjust
            anchors.baseline: label.baseline
            anchors.baselineOffset: Math.round(iconBaselineOffset + (fmIcon.ascent - fmSub.ascent) + submapBaselineAdjust)
            padding: 1
        }

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
            padding: (root.isTerminalWs ? 0 : 1)
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
            // Reduce left padding to tighten gap next to icon
            leftPadding: (root.isTerminalWs ? -2 : 2)

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
                    } else if (line.startsWith("submap>>")) {
                        // Keyboard submap changed
                        const name = line.substring(8).trim();
                        if (!name || name === "default" || name === "reset") {
                            root.submapName = "";
                        } else {
                            root.submapName = name;
                        }
                    } else if (line.startsWith("submapv2>>")) {
                        // In case Hyprland emits v2 for submap as well: "submapv2>><name>"
                        const name = line.substring(10).trim();
                        if (!name || name === "default" || name === "reset") {
                            root.submapName = "";
                        } else {
                            root.submapName = name;
                        }
                    } else if (line.startsWith("focusedmon>>") || line.startsWith("focusedmonv2>>")) {
                        // Monitor focus changed — refresh current workspace via hyprctl
                        refreshOnce.start();
                    }
                }
            }
        }

        stderr: StdioCollector { waitForEnd: false }

        onExited: { eventMonitor.consumed = 0; running = true }

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
                } catch (e) { }
            }
        }
        stderr: StdioCollector { waitForEnd: true }
        environment: hyprEnvOrNull()
    }

    // Debounce before asking hyprctl again (used on monitor focus change)
    Timer {
        id: refreshOnce
        interval: 120
        onTriggered: getCurrentWS.running = true
    }

    // Discover submaps used in binds and derive icon mapping
    Process {
        id: getBinds
        command: ["bash", "-lc", "hyprctl -j binds"]
        environment: hyprEnvOrNull()
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const arr = JSON.parse(text);
                    const dyn = {};
                    for (let i = 0; i < arr.length; i++) {
                        const sub = (arr[i] && arr[i].submap) ? String(arr[i].submap) : "";
                        const n = sub.toLowerCase().trim();
                        if (!n || n === "default" || n === "reset") continue;
                        // Assign via heuristics so it's stable across restarts
                        dyn[n] = submapIconName(n);
                    }
                    submapDynamicMap = dyn;
                    try { const _ = Object.keys(dyn); } catch (_) {}
                } catch (e) { }
            }
        }
        stderr: StdioCollector { waitForEnd: true }
    }

    // Initial sync at component creation
    Component.onCompleted: {
        getCurrentWS.running = true;
        getBinds.running = true;
    }
}
