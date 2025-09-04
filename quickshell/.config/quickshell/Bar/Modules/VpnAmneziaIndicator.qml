import QtQuick
import QtQuick.Controls
import Quickshell.Io
import qs.Components
import qs.Settings

// Amnezia VPN status indicator (basic)
// - Polls `ip -j -br a` and considers VPN connected if any interface
//   name contains "awg" or "amnez" and has at least one address.
Item {
    id: root

    // Public API
    property int   desiredHeight: 28
    property int   fontPixelSize: 0
    property bool  useTheme: true
    property bool  showLabel: false
    property int   iconSpacing: 4
    property int   textPadding: 4
    property int   iconVAdjust: 0
    property real  iconScale: 1.0
    property color bgColor: "transparent"
    // Material Symbols icon
    property string iconName: "verified_user"
    property bool   iconRounded: false

    // Colors
    property color onColor:  useTheme ? Theme.accentPrimary : "#4CAF50"
    property color offColor: useTheme ? Theme.textDisabled  : "#6B718A"

    // Internal state
    property bool connected: false
    property string matchedIf: ""

    // Size
    implicitHeight: desiredHeight
    width: row.implicitWidth
    height: desiredHeight

    // Background (optional)
    Rectangle { anchors.fill: parent; color: bgColor; visible: bgColor !== "transparent" }

    // Computed font size tied to height
    readonly property int computedFontPx: fontPixelSize > 0
        ? fontPixelSize
        : Math.max(16, Math.round((desiredHeight - 2 * textPadding) * 0.6))

    Row {
        id: row
        spacing: iconSpacing
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        // Icon container
        Item {
            id: iconBox
            implicitHeight: root.desiredHeight
            implicitWidth: iconGlyph.implicitWidth
            MaterialIcon {
                id: iconGlyph
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: iconVAdjust
                icon: root.iconName
                rounded: root.iconRounded
                size: Math.max(8, Math.round(root.computedFontPx * iconScale))
                color: root.connected ? root.onColor : root.offColor
            }
        }

        Label {
            id: label
            visible: root.showLabel
            text: "VPN"
            color: root.connected ? root.onColor : root.offColor
            font.family: Theme.fontFamily
            font.pixelSize: root.computedFontPx
            padding: textPadding
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Poll every few seconds
    Timer {
        id: poll
        interval: 2500
        repeat: true
        running: true
        onTriggered: if (!runner.running) runner.running = true
    }

    Process {
        id: runner
        command: ["bash", "-lc", "ip -j -br a"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const arr = JSON.parse(text)
                    checkInterfaces(arr)
                } catch (e) {
                    root.connected = false
                    root.matchedIf = ""
                }
                runner.running = false
            }
        }
    }

    function checkInterfaces(arr) {
        if (!Array.isArray(arr)) { root.connected = false; root.matchedIf = ""; return }
        let found = false
        let name = ""
        for (let it of arr) {
            const ifname = (it && it.ifname) ? String(it.ifname) : ""
            const nlow = ifname.toLowerCase()
            const looksAmnezia = nlow.includes("awg") || nlow.includes("amnez")
            if (!looksAmnezia) continue
            const addrs = Array.isArray(it.addr_info) ? it.addr_info : []
            if (addrs.length > 0) { found = true; name = ifname; break }
        }
        root.connected = found
        root.matchedIf = name
    }

    Component.onCompleted: runner.running = true
}
