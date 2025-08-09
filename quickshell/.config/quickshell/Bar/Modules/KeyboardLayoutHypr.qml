// - Listens to raw Hyprland events and updates on "deviceName,Layout" strings.
// - On click, switches the keyboard layout via `hyprctl switchxkblayout`.
// - Supports theme colors via Theme.*, or custom colors if useTheme = false.
// - Optional `screen` property for proper scaling with Theme.scale(screen).
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Settings

Item {
    id: kb
    // === Public API ===
    property string deviceMatch: ""   // substring to match keyboard device name
    property alias  fontPixelSize: label.font.pixelSize
    property int    desiredHeight: 24 // outer capsule height
    property var    screen: null      // pass panel.screen for Theme scaling
    property bool   useTheme: true    // use Theme.* colors if true
    // === Color properties (can be overridden externally) ===
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
    implicitWidth:  Math.ceil(label.implicitWidth  + 10 * sc())
    implicitHeight: Math.ceil(label.implicitHeight + 6  * sc())

    // === Capsule UI ===
    Rectangle {
        id: capsule
        readonly property bool hovered: ma.containsMouse
        width:  Math.max(kb.implicitWidth,  40 * sc())
        height: Math.max(20 * sc(), kb.desiredHeight)
        radius: Math.round(height / 2)
        color:  hovered ? hoverBgColor : bgColor
        border.color: borderColor
        border.width: 1
        antialiasing: true
        anchors.verticalCenter: parent.verticalCenter

        Label {
            id: label
            anchors.centerIn: parent
            text: kb.layoutText
            color: textColor
            font.family: Theme.fontFamily
            font.weight: Font.Medium
            padding: 1.5 * sc()
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

    // === Hyprland raw event listener ===
    Connections {
        target: Hyprland
        function onRawEvent(a, b) {
            let payload =
                (typeof a === "string" && typeof b === "string") ? b :
                (typeof a === "string" && b === undefined)       ? a :
                (a && typeof a === "object")                     ? a.data :
                null
            if (!payload) return

            const i = payload.indexOf(",")
            if (i < 0) return

            const kbd    = payload.slice(0, i)
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
                } catch (_) { /* ignore parse errors */ }
            }
        }
    }

    // Process for switching layouts
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
