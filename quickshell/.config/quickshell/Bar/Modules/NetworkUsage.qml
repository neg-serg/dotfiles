import QtQuick
import QtQuick.Controls
import Quickshell.Io
import qs.Settings
import "../../Helpers/Format.js" as Format
import "../../Helpers/Utils.js" as Utils
import qs.Components

Item {
    id: root
    // Public props
    property var    screen: null
    property int    desiredHeight: Math.round(Theme.panelHeight * Theme.scale(Screen))
    property int    fontPixelSize: 0
    property color  textColor: Theme.textPrimary
    // Match media separators color (same blue as workspace accents)
    property color  separatorColor: Theme.accentHover
    property color  bgColor:   "transparent"
    property int    iconSpacing: Theme.panelRowSpacingSmall
    property string deviceMatch: ""
    property var    cmd: ["rsmetrx"]
    property string displayText: "0/0K"
    property bool   useTheme: true
    // Connectivity state
    property bool   hasLink: true
    property bool   hasInternet: true

    // Icon tuning (from Theme tokens)
    property real   iconScale: Theme.networkIconScale
    // Base icon color (used when link+internet are OK)
    property color  iconColor: useTheme ? Theme.textSecondary : Theme.textSecondary
    property int    iconVAdjust: Theme.networkIconVAdjust   // vertical nudge (px) for the icon
    property string iconText: ""                  // Font Awesome: network-wired
    property string iconFontFamily: "Font Awesome 6 Free"
    property string iconStyleName: "Solid"

    // Text padding
    property int    textPadding: Theme.panelRowSpacingSmall

    // Sizing
    implicitHeight: desiredHeight
    width: lineBox.implicitWidth
    height: desiredHeight

    // Background (optional)
    Rectangle {
        anchors.fill: parent
        color: bgColor
        visible: bgColor !== "transparent"
    }

    // Computed font size tied to height
    readonly property int computedFontPx: fontPixelSize > 0
        ? fontPixelSize
        : Utils.clamp(Math.round((desiredHeight - 2 * textPadding) * Theme.panelComputedFontScale), 16, 4096)

    // Font metrics for text (not icon)
    FontMetrics { id: fmText; font: label.font }

    SmallInlineStat {
        id: inlineView
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        desiredHeight: root.desiredHeight
        fontPixelSize: root.fontPixelSize
        textPadding: root.textPadding
        iconSpacing: root.iconSpacing
        iconMode: "glyph"
        iconGlyph: iconText
        iconFontFamily: iconFontFamily
        iconStyleName: iconStyleName
        iconScale: root.iconScale
        iconVAdjust: root.iconVAdjust
        iconColor: currentIconColor()
        labelIsRichText: true
        labelText: displayText && displayText.indexOf('/') !== -1
                   ? displayText.replace('/', Format.sepSpan(separatorColor, '/'))
                   : displayText
        labelColor: textColor
        labelFontFamily: Theme.fontFamily
    }

    // External process runner
    Process {
        id: runner
        running: true
        command: cmd
        stdout: SplitParser {
            onRead: (data) => {
                const line = (data || "").trim()
                if (line.length) parseJsonLine(line)
            }
        }
        onRunningChanged: if (!running) restartTimer.restart()
    }

    // Backoff before restart
    Timer {
        id: restartTimer
        interval: Theme.networkRestartBackoffMs
        repeat: false
        onTriggered: runner.running = true
    }

    // --- Link detection: parse `ip -j -br a` ---
    Timer {
        id: linkPoll
        interval: Theme.networkLinkPollMs
        repeat: true
        running: true
        onTriggered: if (!linkProbe.running) linkProbe.running = true
    }
    Process {
        id: linkProbe
        command: ["bash", "-lc", "ip -j -br a"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const arr = JSON.parse(text)
                    let up = false
                    for (let it of arr) {
                        const name = (it && it.ifname) ? String(it.ifname) : ""
                        if (!name || name === "lo") continue
                        const state = (it && it.operstate) ? String(it.operstate) : ""
                        const addrs = Array.isArray(it?.addr_info) ? it.addr_info : []
                        // Treat as "link present" if operstate UP, or UNKNOWN but has an address (e.g., VPN)
                        if (state === "UP" || (state === "UNKNOWN" && addrs.length > 0)) { up = true; break }
                    }
                    root.hasLink = up
                } catch (e) {
                    // On parse error, assume unknown link (keep previous)
                }
                linkProbe.running = false
            }
        }
    }

    // --- Internet reachability: ping a well-known IP (1.1.1.1) ---
    Timer {
        id: inetPoll
        interval: (function(){ var v = Utils.coerceInt(Settings.settings.networkPingIntervalMs, 30000); return Utils.clamp(v, 1000, 600000); })()
        repeat: true
        running: true
        onTriggered: {
            if (!root.hasLink) { root.hasInternet = false; return }
            if (!inetProbe.running) inetProbe.running = true
        }
    }
    Process {
        id: inetProbe
        command: ["bash", "-lc", "ping -n -c1 -W1 1.1.1.1 >/dev/null && echo OK || echo FAIL"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const result = (text || "").trim()
                root.hasInternet = (result.indexOf("OK") !== -1)
                inetProbe.running = false
            }
        }
    }

    // JSON parsing from rsmetrx
    function parseJsonLine(line) {
        try {
            const data = JSON.parse(line)
            if (typeof data.rx_kib_s === "number" && typeof data.tx_kib_s === "number") {
                root.displayText = formatData(data)
            } else {
                // ignore invalid line silently
            }
        } catch (e) {
            // ignore parse errors
        }
    }

    // "12.3/4.5K" (single K suffix) or "0"
    function formatData(data) {
        if (data.rx_kib_s === 0 && data.tx_kib_s === 0) return "0"
        return `${fmtKiBps(data.rx_kib_s)}/${fmtKiBps(data.tx_kib_s)}K`
    }

    function fmtKiBps(kib) { return kib.toFixed(1) }

    Component.onCompleted: {}

    // Current icon color based on connectivity
    function currentIconColor() {
        if (!root.hasLink) return (Settings.settings.networkNoLinkColor || Theme.error)
        if (!root.hasInternet) return (Settings.settings.networkNoInternetColor || Theme.warning)
        return root.iconColor
    }
}
