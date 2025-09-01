import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Settings

Item {
    id: root
    // Public props
    property var    screen: null
    property int    desiredHeight: 28
    property int    fontPixelSize: 0
    property color  textColor: Theme.textPrimary
    // Match media separators color (same blue as workspace accents)
    property color  separatorColor: "#3b7bb3"
    property color  bgColor:   "transparent"
    property int    iconSpacing: 4
    property string deviceMatch: ""
    property var    cmd: ["rsmetrx"]
    property string displayText: "0/0K"
    property bool   useTheme: true

    // Icon tuning
    property real   iconScale: 0.7
    property color  iconColor: useTheme && Theme.gothicColor ? Theme.gothicColor : "#8d9eb2"
    property int    iconVAdjust: 0                 // vertical nudge (px) for the icon
    property string iconText: ""                  // Font Awesome: network-wired
    property string iconFontFamily: "Font Awesome 6 Free"
    property string iconStyleName: "Solid"

    // Text padding
    property int    textPadding: 4

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
        : Math.max(16, Math.round((desiredHeight - 2 * textPadding) * 0.6))

    // Font metrics for text (not icon)
    FontMetrics { id: fmText; font: label.font }

    // Content row
    Row {
        id: lineBox
        spacing: iconSpacing
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        // Icon container: forces vertical centering of the glyph
        Item {
            id: iconBox
            implicitHeight: root.desiredHeight
            implicitWidth: iconGlyph.implicitWidth
            // The actual glyph
            Text {
                id: iconGlyph
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: iconVAdjust
                text: iconText
                color: iconColor
                font.family: iconFontFamily
                font.styleName: iconStyleName
                font.weight: Font.Normal
                font.pixelSize: Math.max(8, Math.round(root.computedFontPx * iconScale))
                renderType: Text.NativeRendering
            }
        }

        Label {
            id: label
            // Render slash with colored separator like in media widget
            textFormat: Text.RichText
            text: displayText && displayText.indexOf('/') !== -1
                    ? displayText.replace('/', "<span style='color:" + root.separatorColor + "'>/</span>")
                    : displayText
            color: textColor
            font.family: Theme.fontFamily
            font.pixelSize: root.computedFontPx
            padding: textPadding
            verticalAlignment: Text.AlignVCenter
        }
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
        interval: 1500
        repeat: false
        onTriggered: runner.running = true
    }

    // JSON parsing from rsmetrx
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

    // "12.3/4.5K" (single K suffix) or "0"
    function formatData(data) {
        if (data.rx_kib_s === 0 && data.tx_kib_s === 0) return "0"
        return `${fmtKiBps(data.rx_kib_s)}/${fmtKiBps(data.tx_kib_s)}K`
    }

    function fmtKiBps(kib) { return kib.toFixed(1) }

    Component.onCompleted: {
        console.log("Starting network monitor:", Array.isArray(cmd) ? cmd.join(" ") : String(cmd))
    }
}
