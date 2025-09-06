import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Services
import qs.Settings
import "../../Helpers/Format.js" as Format
import "../../Helpers/WsIconMap.js" as WsMap

Item {
    id: root
    property string wsName: "?"
    property int wsId: -1
    property string submapName: ""
    // Vertical alignment of submap icon (px; negative moves up)
    property int submapBaselineAdjust: Theme.wsSubmapIconBaselineOffset
    property var submapDynamicMap: ({})
    // Map submap name to icon via helper + overrides + dynamic mapping
    function submapIconName(name) {
        const key = (name || "").toLowerCase().trim();
        if (submapDynamicMap && submapDynamicMap[key]) return submapDynamicMap[key];
        return WsMap.submapIcon(key, Theme.wsSubmapIconOverrides);
    }

    property color iconColor: Theme.accentHover
    property color gothicColor: Theme.textPrimary
    property color separatorColor: Theme.textSecondary

    // Icon layout
    property int  iconBaselineOffset: Theme.wsIconBaselineOffset
    property int  iconSpacing: Theme.wsIconSpacing

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

    function htmlEscape(s) {
        s = (s === undefined || s === null) ? "" : String(s);
        return s
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
    }

    function isPUA(cp) { return cp >= 0xE000 && cp <= 0xF8FF; }          // Private Use Area (icon fonts)
    function isOldItalic(cp){ return cp >= 0x10300 && cp <= 0x1034F; }
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
        spacing: iconSpacing
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        BaselineAlignedIcon {
            visible: root.submapName && root.submapName.length > 0
            mode: "material"
            labelRef: label
            anchors.verticalCenter: lineBox.verticalCenter
            scale: 0.88
            baselineOffsetToken: submapBaselineAdjust
            alignMode: "baseline"
            alignTarget: wsIcon
            icon: submapIconName(root.submapName)
            color: Theme.wsSubmapIconColor
            screen: Screen
        }

        BaselineAlignedIcon {
            id: wsIcon
            visible: iconGlyph.length > 0
            mode: "text"
            labelRef: label
            anchors.verticalCenter: lineBox.verticalCenter
            scale: 1.40
            baselineOffsetToken: iconBaselineOffset
            alignMode: "baseline"
            text: iconGlyph
            fontFamily: Theme.fontFamily
            color: iconColor
            padding: (root.isTerminalWs ? Theme.uiSpacingNone : Theme.wsIconInnerPadding)
        }

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
            leftPadding: (root.isTerminalWs ? Theme.wsLabelLeftPaddingTerminal : Theme.wsLabelLeftPadding)
            anchors.verticalCenter: lineBox.verticalCenter
            anchors.verticalCenterOffset: (wsIcon && wsIcon.currentOffset !== undefined) ? wsIcon.currentOffset : 0
        }
    }

    // Hyprland socket2 events (socat)
    ProcessRunner {
        id: eventMonitor
        cmd: ["socat", "-u", "UNIX-CONNECT:" + socketPath(), "-"]
        backoffMs: Theme.networkRestartBackoffMs
        onLine: (lineRaw) => {
            let line = String(lineRaw || "").trim();
            if (!line) return;
            if (line.startsWith("workspace>>")) {
                const id = parseInt(line.substring(11).trim());
                if (!isNaN(id)) { root.wsId = id; root.wsName = ""; }
            } else if (line.startsWith("workspacev2>>")) {
                const payload = line.substring(13);
                const parts = payload.split(",", 2);
                const id = parseInt(parts[0]);
                if (!isNaN(id)) root.wsId = id;
                let name = (parts[1] || "").trim();
                if (name.startsWith("name:")) name = name.substring(5);
                root.wsName = name;
            } else if (line.startsWith("submap>>")) {
                const name = line.substring(8).trim();
                root.submapName = (!name || name === "default" || name === "reset") ? "" : name;
            } else if (line.startsWith("submapv2>>")) {
                const name = line.substring(10).trim();
                root.submapName = (!name || name === "default" || name === "reset") ? "" : name;
            } else if (line.startsWith("focusedmon>>") || line.startsWith("focusedmonv2>>")) {
                refreshOnce.start();
            }
        }
    }

    // One-shot refresh using hyprctl (JSON)
    ProcessRunner {
        id: getCurrentWS
        cmd: ["hyprctl", "-j", "activeworkspace"]
        env: hyprEnvOrNull()
        parseJson: true
        autoStart: false
        onJson: (obj) => { try { root.wsId = obj.id; root.wsName = obj.name; } catch (e) {} }
    }

    // Debounce before asking hyprctl again (used on monitor focus change)
    Timer {
        id: refreshOnce
        interval: Theme.wsRefreshDebounceMs
        onTriggered: getCurrentWS.start()
    }

    // Discover submaps used in binds and derive icon mapping
    ProcessRunner {
        id: getBinds
        cmd: ["bash", "-lc", "hyprctl -j binds"]
        env: hyprEnvOrNull()
        parseJson: true
        onJson: (arr) => {
            try {
                const dyn = {};
                for (let i = 0; i < arr.length; i++) {
                    const sub = (arr[i] && arr[i].submap) ? String(arr[i].submap) : "";
                    const n = sub.toLowerCase().trim();
                    if (!n || n === "default" || n === "reset") continue;
                    dyn[n] = submapIconName(n);
                }
                submapDynamicMap = dyn;
                try { const _ = Object.keys(dyn); } catch (_) {}
            } catch (e) { }
        }
    }

    // Initial sync at component creation
    Component.onCompleted: {
        getCurrentWS.start();
        getBinds.start();
    }
}
