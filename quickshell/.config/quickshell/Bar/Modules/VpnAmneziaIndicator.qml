import QtQuick
import QtQuick.Controls
import Quickshell.Io
import qs.Components
import qs.Settings
import "../../Helpers/Utils.js" as Utils

// Amnezia VPN status indicator (basic)
// - Polls `ip -j -br a` and considers VPN connected if any interface
//   name contains "awg" or "amnez" and has at least one address.
Item {
    id: root

    // Public API
    property int   desiredHeight: Math.round(Theme.panelHeight * Theme.scale(Screen))
    property int   fontPixelSize: 0
    property bool  useTheme: true
    property bool  showLabel: true
    property int   iconSpacing: Theme.panelRowSpacingSmall
    property int   textPadding: Theme.panelRowSpacingSmall
    property int   iconVAdjust: 0
    property real  iconScale: 1.0
    property color bgColor: "transparent"
    // Material Symbols icon
    property string iconName: "verified_user"
    property bool   iconRounded: false

    // Colors
    property color onColor:  useTheme ? Theme.accentPrimary : "#4CAF50"
    property color offColor: useTheme ? Theme.textDisabled  : "#6B718A"
    // Accent derived from Theme; desaturated for subtle look
    property real  desaturateAmount: 0.45   // 0..1, higher = less saturated
    property color accentBase: Theme.accentSecondary
    property color accentColor: desaturateColor(accentBase, desaturateAmount)

    // Internal state
    property bool connected: false
    property string matchedIf: ""

    // Size / visibility
    visible: connected
    implicitHeight: desiredHeight
    width: row.implicitWidth
    height: desiredHeight

    // Background (optional)
    Rectangle { anchors.fill: parent; color: bgColor; visible: bgColor !== "transparent" }

    // Computed font size tied to height
    readonly property int computedFontPx: fontPixelSize > 0
        ? fontPixelSize
        : Utils.clamp(Math.round((desiredHeight - 2 * textPadding) * 0.6), 16, 4096)

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
                size: Utils.clamp(Math.round(root.computedFontPx * iconScale), 8, 2048)
                color: iconColor()
            }
        }

        Label {
            id: label
            visible: root.showLabel
            text: "VPN"
            color: iconColor()
            font.family: Theme.fontFamily
            font.pixelSize: root.computedFontPx
            padding: textPadding
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Poll every few seconds
    Timer {
        id: poll
        interval: Theme.vpnPollMs
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

    // --- Color helpers ---
    function mixColor(a, b, t) {
        // a,b: colors; t in [0,1]
        return Qt.rgba(
            a.r * (1 - t) + b.r * t,
            a.g * (1 - t) + b.g * t,
            a.b * (1 - t) + b.b * t,
            a.a * (1 - t) + b.a * t
        )
    }
    function grayOf(c) {
        const y = 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
        return Qt.rgba(y, y, y, c.a)
    }
    function desaturateColor(c, amount) {
        amount = Utils.clamp(amount || 0, 0, 1)
        return mixColor(c, grayOf(c), amount)
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

    // Subtle styling
    property bool  muted: true
    property bool  hovered: false
    property real  connectedOpacity: 0.8
    property real  disconnectedOpacity: 0.45
    opacity: hovered ? 1.0 : (connected ? connectedOpacity : disconnectedOpacity)
    function iconColor() {
        if (!connected) return offColor
        // Use workspace accent blue when connected (subtle); hover only affects opacity
        return accentColor
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onEntered:  root.hovered = true
        onExited:   root.hovered = false
        cursorShape: Qt.ArrowCursor
    }

    Component.onCompleted: runner.running = true
}
