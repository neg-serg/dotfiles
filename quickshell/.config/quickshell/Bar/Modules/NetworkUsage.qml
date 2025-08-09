
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Settings

Item {
    id: root
    // Public props
    property var    screen: null
    property int    desiredHeight: 24
    property int    fontPixelSize: 0
    property color  textColor: Theme.textPrimary
    property color  bgColor:   "transparent"
    property int    iconSpacing: 4
    property string deviceMatch: ""
    // NOTE: Process.command expects a string list [exe, arg1, ...]
    property var    cmd: ["rsmetrx"]
    property string displayText: "0/0"
    property bool   useTheme: true

    // Icon tuning (mirrors KeyboardLayoutHypr structure)
    // You can tweak size, spacing, baseline, glyph, and font face.
    property real   iconScale: 0.7
    property color  iconColor: useTheme && Theme.gothicColor ? Theme.gothicColor : "#8d9eb2"
    property int    iconBaselineAdjust: 0          // fine-tune icon vertical alignment (px)
    property string iconText: ""             // FA 'network-wired' (Font Awesome 6)
    property string iconFontFamily: "Font Awesome 6 Free"
    property string iconStyleName: "Solid"         // "Regular" / "Solid" / etc.

    // Sizing
    implicitHeight: desiredHeight
    implicitWidth: lineBox.implicitWidth
    width: implicitWidth
    height: desiredHeight

    // Optional background
    Rectangle {
        anchors.fill: parent
        color: bgColor
        visible: bgColor !== "transparent"
    }

    // Use font metrics to align icon baseline with text baseline
    FontMetrics { id: fmText; font: label.font }
    FontMetrics { id: fmIcon; font: iconLabel.font }

    Row {
        id: lineBox
        spacing: iconSpacing
        anchors.verticalCenter: parent.verticalCenter

        // Left icon (Font Awesome glyph)
        // Keeps visual baseline aligned with the text using metrics.
        Label {
            id: iconLabel
            text: iconText
            color: iconColor
            font.family: iconFontFamily
            font.styleName: iconStyleName
            font.weight: Font.Normal
            font.pixelSize: (fontPixelSize > 0
                             ? fontPixelSize
                             : Theme.fontSizeSmall * Theme.scale(screen)) * iconScale
            verticalAlignment: Text.AlignVCenter
            // Align FA icon's baseline to the text baseline + optional nudge
            y: Math.round((lineBox.height - fmIcon.height) / 2
                          + (fmText.ascent - fmIcon.ascent)
                          + iconBaselineAdjust)
        }

        Label {
            id: label
            text: displayText
            color: textColor
            font.family: Theme.fontFamily
            font.pixelSize: fontPixelSize > 0
                           ? fontPixelSize
                           : Theme.fontSizeSmall * Theme.scale(screen)
            padding: 6
            verticalAlignment: Text.AlignVCenter
            // Center text block in the row via metrics (keeps things tidy)
            y: Math.round((lineBox.height - fmText.height) / 2)
        }
    }

    // External process runner
    Process {
        id: runner
        running: true              // launch immediately
        command: cmd

        // Stream stdout line-by-line
        stdout: SplitParser {
            // Emitted once per line (separator \n by default)
            onRead: (data) => {
                const line = (data || "").trim()
                if (line.length) parseJsonLine(line)
            }
        }

        // If process stops (exits or fails), schedule a restart
        onRunningChanged: {
            if (!running) {
                console.log("Process stopped; scheduling restart…")
                restartTimer.restart()
            }
        }
    }

    // Backoff timer before relaunch (prevents tight loops on failure)
    Timer {
        id: restartTimer
        interval: 1500
        repeat: false
        onTriggered: {
            // Toggle running to relaunch
            runner.running = true
        }
    }

    // Parse one JSON line from rsmetrx
    function parseJsonLine(line) {
        try {
            const data = JSON.parse(line)
            if (typeof data.rx_kib_s === "number" && typeof data.tx_kib_s === "number") {
                root.displayText = formatData(data)
            } else {
                console.warn("Invalid payload:", line)
            }
        } catch (e) {
            console.warn("JSON parse error:", e, "Line:", line)
        }
    }

    // Build compact text like "12.3K/4.5K" or "0"
    function formatData(data) {
        if (data.rx_kib_s === 0 && data.tx_kib_s === 0) return "0"
        return `${fmtKiBps(data.rx_kib_s)}/${fmtKiBps(data.tx_kib_s)}`
    }

    // KiB/s formatter (keep it minimal; extend to MiB/GiB if needed)
    function fmtKiBps(kib) {
        return kib.toFixed(1) + "K"
    }

    Component.onCompleted: {
        // Safe join: cmd is a string list
        console.log("Starting network monitor:", Array.isArray(cmd) ? cmd.join(" ") : String(cmd))
    }
}
