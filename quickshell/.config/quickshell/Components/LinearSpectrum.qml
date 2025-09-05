import QtQuick
import qs.Settings
import "../Helpers/Utils.js" as Utils

Item {
    id: root
    clip: true
    // Input values (0..1) from CAVA
    property var values: []
    // Visual tuning
    property real amplitudeScale: 1.0        // scales value height
    property real barGap: Math.round(Theme.spectrumBarGap * Theme.scale(Screen))
    property real minBarWidth: Math.round(Theme.spectrumMinBarWidth * Theme.scale(Screen))
    property bool mirror: true               // draw above and below center
    property real fillOpacity: 0.85
    property real peakOpacity: 1.0
    // Simpler look by default: no peak caps
    property bool showPeaks: false
    // Coloring: default to a neutral/darker theme color (no gradient)
    property bool useGradient: false
    property color barColor: Theme.outline
    property color colorStart: Theme.accentPrimary
    property color colorMid: Theme.accentPrimary
    property color colorEnd: Theme.highlight
    // Selective halves
    property bool drawTop: true
    property bool drawBottom: true

    readonly property int barCount: values.length
    readonly property real halfH: mirror ? height / 2 : height

    function lerp(a, b, t) { return a + (b - a) * t; }
    function mixColor(c1, c2, t) { return Qt.rgba(lerp(c1.r, c2.r, t), lerp(c1.g, c2.g, t), lerp(c1.b, c2.b, t), 1); }
    function colorAt(i) {
        if (!useGradient) return barColor;
        if (barCount <= 1) return colorMid;
        const t = i / (barCount - 1);
        // 2-stop gradient: start -> mid -> end
        return t < 0.5
            ? mixColor(colorStart, colorMid, t * 2)
            : mixColor(colorMid, colorEnd, (t - 0.5) * 2);
    }

    // Computed bar width
    property real computedBarWidth: {
        const n = Utils.clamp(barCount, 1, barCount || 1);
        const w = (width - (n - 1) * barGap) / n;
        return Utils.clamp(w, minBarWidth, w);
    }

    Repeater {
        id: rep
        model: root.barCount
        delegate: Item {
            width: root.computedBarWidth
            height: parent.height
            x: index * (root.computedBarWidth + root.barGap)

            // Bar value and peak with simple decay
            property real v: (root.values[index] || 0) * root.amplitudeScale
            property real peak: 0
            onVChanged: if (root.showPeaks && v > peak) peak = v;
            Timer {
                interval: Theme.spectrumPeakDecayIntervalMs; running: root.showPeaks; repeat: true
                onTriggered: parent.peak = Utils.clamp(parent.peak - 0.04, 0, 1)
            }

            // Base bar (bottom half)
            Rectangle {
                visible: root.drawBottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                radius: width / 3
                height: Utils.clamp(parent.v * root.halfH, 1, root.halfH)
                y: root.mirror ? root.halfH : root.halfH - height
                color: Qt.rgba(root.colorAt(index).r, root.colorAt(index).g, root.colorAt(index).b, root.fillOpacity)
                antialiasing: true
                Behavior on height { SmoothedAnimation { duration: Theme.spectrumBarAnimMs } }
            }

            // Mirrored bar (top half)
            Rectangle {
                visible: root.mirror && root.drawTop
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                radius: width / 3
                height: Utils.clamp(parent.v * root.halfH, 1, root.halfH)
                y: root.halfH - height
                color: Qt.rgba(root.colorAt(index).r, root.colorAt(index).g, root.colorAt(index).b, root.fillOpacity)
                antialiasing: true
                Behavior on height { SmoothedAnimation { duration: Theme.spectrumBarAnimMs } }
            }

            // Peak indicator (optional)
            Rectangle {
                visible: root.showPeaks && root.mirror && root.drawTop
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: Theme.spectrumPeakThickness
                radius: height / 2
                y: root.halfH - Utils.clamp(parent.peak * root.halfH, 0, root.halfH) - height
                color: Qt.rgba(root.colorAt(index).r, root.colorAt(index).g, root.colorAt(index).b, root.peakOpacity)
                antialiasing: true
            }
        }
    }
}
