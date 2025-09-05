import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Services
import qs.Settings
import "../../Helpers/Format.js" as Format

Item {
    id: root
    // Public widget state
    property string wsName: "?"
    property int wsId: -1
    // Hyprland keyboard submap (left of workspace)
    property string submapName: ""
    // Fine-tune vertical alignment of submap icon (px; negative moves up)
    property int submapBaselineAdjust: Theme.wsSubmapIconBaselineOffset
    // Live-discovered submaps from Hyprland (via hyprctl -j binds)
    property var submapDynamicMap: ({})
    // Known submaps → Material Symbols
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
            "crop_square", "radio_button_unchecked", "change_history",
            "hexagon", "pentagon", "diamond"
        ];
        let h = 0;
        const s = (name || "").toLowerCase();
        for (let i = 0; i < s.length; i++) h = (h * 33 + s.charCodeAt(i)) >>> 0;
        return shapes[h % shapes.length];
    }
    function submapIconName(name) {
        const key = (name || "").toLowerCase().trim();
        // Dynamic mapping first
        if (submapDynamicMap && submapDynamicMap[key]) return submapDynamicMap[key];
        // Then static table
        if (submapIconMap[key]) return submapIconMap[key];
        // Heuristics
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
    property color iconColor: Theme.accentHover
    property color gothicColor: Theme.textPrimary
    property color separatorColor: Theme.textSecondary

    // Icon layout
    property int  iconBaselineOffset: Theme.wsIconBaselineOffset
    property int  iconSpacing: Theme.wsIconSpacing

    // Size follows the composed row
    implicitWidth: lineBox.implicitWidth
    implicitHeight: lineBox.implicitHeight

    // Hyprland environment
    function hyprSig() { return Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || ""; }
    function runtimeDir() { return Quickshell.env("XDG_RUNTIME_DIR") || ("/run/user/" + Quickshell.env("UID")); }
    function socketPath() { return runtimeDir() + "/hypr/" + hyprSig() + "/.socket2.sock"; }
    function hyprEnvOrNull() {
        const sig = hyprSig();
        return sig ? ["HYPRLAND_INSTANCE_SIGNATURE=" + sig] : null;
    }

    // HTML escape
    function htmlEscape(s) {
        s = (s === undefined || s === null) ? "" : String(s);
        return s
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
    }

    // Char classifiers
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
            if (ch === "·") return " ";
            // Use accentHover for separators
            return Format.sepSpan(Theme.accentHover, ch);
        }
        return htmlEscape(ch);
    }

    // Decorate string with category spans
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

    // Split leading PUA icon
    function leadingIcon(name) {
        if (!name || typeof name !== "string" || name.length === 0) return "";
        const cp = name.codePointAt(0);
        return isPUA(cp) ? String.fromCodePoint(cp) : "";
    }

    function restAfterLeadingIcon(name) {
        if (!name || typeof name !== "string" || name.length === 0) return "";
        const cp = name.codePointAt(0);
        if (!isPUA(cp)) return name;
        const skip = (cp > 0xFFFF) ? 2 : 1;
        // Trim immediate whitespace after icon
        return name.substring(skip).replace(/^\s+/, "");
    }

    // Final values for display
    property string iconGlyph: leadingIcon(wsName)
    property string restName: restAfterLeadingIcon(wsName)

    // Detect terminal workspace
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

    // RichText decoration
    property string decoratedText: (restName && restName.length > 0)
                                   ? decorateName(restName)
                                   : decorateName(fallbackText)

    // UI
    Row {
        id: lineBox
        // Small spacing; children add padding
        spacing: iconSpacing
        // Center the whole row vertically so label doesn't appear to move
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        // implicit sizes come from children

        // Submap icon aligned to label baseline
        BaselineAlignedIcon {
            visible: root.submapName && root.submapName.length > 0
            mode: "material"
            labelRef: label
            // Token-style API
            baselineOffsetToken: submapBaselineAdjust
            alignMode: "baseline"
            icon: submapIconName(root.submapName)
            color: Theme.wsSubmapIconColor
        }

        // Workspace icon (PUA)
        BaselineAlignedIcon {
            visible: iconGlyph.length > 0
            mode: "text"
            labelRef: label
            // Slightly larger than label for better prominence
            scale: 1.15
            // Token-style API
            baselineOffsetToken: iconBaselineOffset
            alignMode: "baseline"
            text: iconGlyph
            fontFamily: Theme.fontFamily
            color: iconColor
            padding: (root.isTerminalWs ? Theme.uiSpacingNone : Theme.wsIconInnerPadding)
        }

        // Label (RichText)
        Label {
            id: label
            textFormat: Text.RichText
            renderType: Text.NativeRendering
            text: decoratedText
            font.family: Theme.fontFamily
            font.weight: Font.Medium
            font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
            color: Theme.textPrimary
            padding: Theme.wsLabelPadding
            // Tighter left gap next to icon
            leftPadding: (root.isTerminalWs ? Theme.wsLabelLeftPaddingTerminal : Theme.wsLabelLeftPadding)

            
        }
    }

    // Hyprland socket2 events (socat)
    Process {
        id: eventMonitor
        command: ["socat", "-u", "UNIX-CONNECT:" + socketPath(), "-"]
        running: true
        property int consumed: 0

        stdout: StdioCollector {
            waitForEnd: false
            onTextChanged: {
                const all = text;
                if (eventMonitor.consumed >= all.length) return;

                const chunk = all.substring(eventMonitor.consumed);
                eventMonitor.consumed = all.length;

                // Split lines; carry partial to next tick
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
                        const name = line.substring(10).trim();
                        if (!name || name === "default" || name === "reset") {
                            root.submapName = "";
                        } else {
                            root.submapName = name;
                        }
                    } else if (line.startsWith("focusedmon>>") || line.startsWith("focusedmonv2>>")) {
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
        interval: Theme.wsRefreshDebounceMs
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
