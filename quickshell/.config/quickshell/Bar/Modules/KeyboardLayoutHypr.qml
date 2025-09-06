import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Components
import qs.Settings
import "../../Helpers/Utils.js" as Utils

Item {
    id: kb

    property string deviceMatch: ""
    property alias  fontPixelSize: label.font.pixelSize
    property int    desiredHeight: Math.round(Theme.keyboardHeight * Theme.scale(Screen))
    property var    screen: null
    property bool   useTheme: true
    property int    yNudge: 0

    property real   iconScale: Theme.keyboardIconScale
    property int    iconSpacing: Theme.keyboardIconSpacing
    property color  iconColor: useTheme ? Theme.keyboardIconColor : Theme.textSecondary

    property int    iconBaselineAdjust: Theme.keyboardIconBaselineOffset
    property int    textBaselineAdjust: Theme.keyboardTextBaselineOffset

    property color  bgColor:      useTheme ? Theme.keyboardBgColor : Theme.background
    property color  textColor:    useTheme ? Theme.keyboardTextColor : Theme.textPrimary
    property color  hoverBgColor: useTheme ? Theme.keyboardHoverBgColor : Theme.surfaceHover

    property string layoutText: "??"
    property string deviceName: ""
    property var    knownKeyboards: []

    function sc() {
        const s = kb.screen || (Quickshell.screens && Quickshell.screens.length ? Quickshell.screens[0] : null)
        return s ? Theme.scale(s) : 1
    }

    readonly property int margin: Math.round(Theme.keyboardMargin * sc())

    implicitWidth:  Math.ceil(row.implicitWidth + 2 * margin)
    implicitHeight: capsule.height

    Rectangle {
        id: capsule
        readonly property bool hovered: ma.containsMouse
        height: Utils.clamp(row.implicitHeight + 2 * kb.margin, kb.desiredHeight, row.implicitHeight + 2 * kb.margin)
        width:  Utils.clamp(row.implicitWidth + 2 * kb.margin, Math.round(Theme.keyboardMinWidth * sc()), row.implicitWidth + 2 * kb.margin)
        color:  hovered ? kb.hoverBgColor : kb.bgColor
        radius: Math.round(Theme.keyboardRadius * sc())
        opacity: hovered ? Theme.keyboardHoverOpacity : Theme.keyboardNormalOpacity
        antialiasing: true

        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: kb.yNudge

        // Metrics used for baseline alignment
        FontMetrics { id: fmText; font: label.font }
        FontMetrics { id: fmIcon; font: iconLabel.font }

        Row {
            id: row
            anchors.fill: parent
            anchors.margins: kb.margin
            spacing: kb.iconSpacing * sc()

            Label {
                id: iconLabel
                text: "\uf11c" // FA "keyboard"
                font.family: "Font Awesome 6 Free"
                font.styleName: "Regular"
                font.weight: Font.Normal
                font.pixelSize: Math.round(kb.fontPixelSize * kb.iconScale * Theme.keyboardFontScale)
                color: kb.iconColor
                verticalAlignment: Text.AlignVCenter
                padding: Math.round(Theme.keyboardIconPadding * sc())
                baselineOffset: fmIcon.ascent + kb.iconBaselineAdjust
            }

            Label {
                id: label
                text: kb.layoutText
                color: kb.textColor
                font.family: Theme.fontFamily
                font.weight: Theme.keyboardTextBold ? Font.DemiBold : Font.Medium
                verticalAlignment: Text.AlignVCenter
                padding: Math.round(Theme.keyboardTextPadding * sc())
                baselineOffset: fmText.ascent + kb.textBaselineAdjust
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                const target = (kb.deviceName && kb.deviceName.length) ? kb.deviceName : "current"
                switchProc.cmd = ["bash", "-lc", `hyprctl switchxkblayout ${target} next`]
                switchProc.start()
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(a, b) {
            // Accept (a,b), a, or object with .data
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

    ProcessRunner {
        id: initProc
        cmd: ["bash", "-lc", "hyprctl -j devices"]
        parseJson: true
        onJson: (obj) => {
            try {
                kb.knownKeyboards = (obj?.keyboards || []).map(k => (k.name || ""))
                const pick = selectKeyboard(obj?.keyboards || [])
                if (pick && deviceAllowed(pick.name || "")) {
                    kb.layoutText = shortenLayout(pick.active_keymap || pick.layout || kb.layoutText)
                }
            } catch (_) { }
        }
    }

    ProcessRunner { id: switchProc; autoStart: false; restartOnExit: false }

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
