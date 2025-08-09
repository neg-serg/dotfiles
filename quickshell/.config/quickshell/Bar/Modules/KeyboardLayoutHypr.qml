// Bar/Modules/KeyboardLayoutHypr.qml — keyboard layout indicator (QS-only, themed)
// - Listens to Hyprland raw events and updates on "deviceName,Layout" strings.
// - Click toggles layout via `hyprctl switchxkblayout` (runs via bash -lc for NixOS PATH).
// - Soft FA icon color (matches workspace look), precise baseline alignment via FontMetrics.
// - Tunable spacing/scale and vertical nudge to match your workspace widget 1:1.
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Settings

Item {
    id: kb

    // === Public API ===
    property string deviceMatch: ""       // substring to match keyboard device name
    property alias  fontPixelSize: label.font.pixelSize
    property int    desiredHeight: 24     // capsule visual height
    property var    screen: null          // pass panel.screen for Theme scaling
    property bool   useTheme: true
    property int    yNudge: 0             // ±px vertical tweak for the whole pill

    // Icon (match workspace look)
    property real   iconScale: 1.0
    property int    iconSpacing: 4
    property color  iconColor: "#8d9eb2"

    // Colors
    property color  bgColor:      useTheme ? Theme.backgroundPrimary : "#1e293b"
    property color  textColor:    useTheme ? Theme.textPrimary : "white"
    property color  hoverBgColor: useTheme ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.06) : "#223043"

    // === Internal state ===
    property string layoutText: "??"
    property string deviceName: ""
    property var    knownKeyboards: []

    // Theme scaling helper
    function sc() {
        const s = kb.screen || (Quickshell.screens && Quickshell.screens.length ? Quickshell.screens[0] : null)
        return s ? Theme.scale(s) : 1
    }

    // Size hints
    implicitWidth:  Math.ceil(row.implicitWidth  + 10 * sc())
    implicitHeight: Math.ceil(row.implicitHeight + 6  * sc())

    // === Capsule UI ===
    Rectangle {
        id: capsule
        readonly property bool hovered: ma.containsMouse
        width:  Math.max(kb.implicitWidth,  40 * sc())
        height: Math.max(20 * sc(), kb.desiredHeight)
        radius: Math.round(height / 2)
        color:  hovered ? kb.hoverBgColor : kb.bgColor
        border.width: 1
        antialiasing: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: kb.yNudge

        // Use metrics to align FA icon baseline with text baseline
        FontMetrics { id: fmText; font: label.font }
        FontMetrics { id: fmIcon; font: iconLabel.font }

        Row {
            id: row
            anchors.fill: parent
            anchors.margins: Math.round(4 * sc())
            spacing: kb.iconSpacing * sc()

            // Keyboard icon (Font Awesome Regular; soft color)
            Label {
                id: iconLabel
                text: "\uf11c"                         // FA "keyboard" glyph
                font.family: "Font Awesome 6 Free"
                font.styleName: "Regular"              // ensure Regular face is installed
                font.weight: Font.Normal
                font.pixelSize: kb.fontPixelSize * kb.iconScale * 0.9
                color: kb.iconColor
                verticalAlignment: Text.AlignVCenter
                // Align FA icon's baseline to text baseline using metrics:
                y: Math.round((row.height - fmIcon.height)/2 + (fmText.ascent - fmIcon.ascent))
            }

            Label {
                id: label
                text: kb.layoutText
                color: kb.textColor
                font.family: Theme.fontFamily
                font.weight: Font.Medium
                verticalAlignment: Text.AlignVCenter
                padding: 1.5 * sc()
                // Center text block in the row via metrics:
                y: Math.round((row.height - fmText.height)/2)
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                const target = (kb.deviceName && kb.deviceName.length) ? kb.deviceName : "current"
                switchProc.command = ["bash", "-lc", `hyprctl switchxkblayout ${target} next`]
                switchProc.running = false
                switchProc.running = true
            }
        }
    }

    // === Hyprland raw events ===
    Connections {
        target: Hyprland
        function onRawEvent(a, b) {
            let payload =
                (typeof a === "string" && typeof b === "string") ? b :
                (typeof a === "string" && b === undefined)       ? a :
                (a && typeof a === "object")                     ? a.data :
                null
            if (!payload) return

            const i = payload.indexOf(","); if (i < 0) return
            const kbd = payload.slice(0, i)
            const layout = payload.slice(i + 1)

            const byMatch = deviceAllowed(kbd)
            const byKnown = kb.knownKeyboards.length ? kb.knownKeyboards.some(n => n === kbd) : true
            if (!(byMatch && byKnown)) return

            if (kbd && kb.deviceName !== kbd) kb.deviceName = kbd
            const txt = shortenLayout(layout || "")
            if (txt && txt !== kb.layoutText) kb.layoutText = txt
        }
    }

    // === Initial snapshot before first event ===
    Process {
        id: initProc
        command: ["bash", "-lc", "hyprctl -j devices"]
        running: true
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const obj = JSON.parse(text)
                    kb.knownKeyboards = (obj?.keyboards || []).map(k => (k.name || ""))
                    const pick = selectKeyboard(obj?.keyboards || [])
                    if (pick && deviceAllowed(pick.name || "")) {
                        kb.layoutText = shortenLayout(pick.active_keymap || pick.layout || kb.layoutText)
                    }
                } catch (_) { /* ignore */ }
            }
        }
    }

    // Runner for click
    Process { id: switchProc }

    // === Helpers ===
    function deviceAllowed(name) {
        const needle = (kb.deviceMatch || "").toLowerCase().trim()
        if (!needle) return true
        return (name || "").toLowerCase().includes(needle)
    }
    function selectKeyboard(list) {
        if (!Array.isArray(list) || list.length === 0) return null
        const needle = (kb.deviceMatch || "").toLowerCase().trim()
        if (needle) {
            for (let k of list) {
                if ((k.name || "").toLowerCase().includes(needle) ||
                    (k.identifier || "").toLowerCase().includes(needle))
                    return k
            }
        }
        for (let k of list) {
            const n = (k.name || "").toLowerCase()
            if (!n.includes("virtual") && (k.active_keymap || k.layout))
                return k
        }
        return list[0]
    }
    function shortenLayout(s) {
        if (!s) return "??"
        const map = {
            "English (US)": "en", "Russian": "ru",
            "English (UK)": "en-uk", "German": "de",
            "French": "fr", "Finnish": "fi"
        }
        if (map[s]) return map[s]
        const m = s.match(/\(([^)]+)\)/)
        if (m && m[1] && m[1].length <= 3) return m[1].toUpperCase()
        return s.split(/\s+/)[0].toUpperCase().slice(0, 3)
    }
}
