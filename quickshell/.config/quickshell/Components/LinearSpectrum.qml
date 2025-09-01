import QtQuick
import qs.Settings

Item {
    id: root
    // Input values (0..1) from CAVA
    property var values: []
    // Visual tuning
    property real amplitudeScale: 1.0        // scales value height
    property real barGap: 2 * Theme.scale(Screen)
    property real minBarWidth: 2 * Theme.scale(Screen)
    property bool mirror: true               // draw above and below center
    property real fillOpacity: 0.85
    property real peakOpacity: 1.0
    // Coloring: default to a neutral/darker theme color (no gradient)
    property bool useGradient: false
    property color barColor: Theme.outline
    property color colorStart: Theme.accentSecondary
    property color colorMid: Theme.accentPrimary
    property color colorEnd: Theme.highlight

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
        const n = Math.max(1, barCount);
        const w = (width - (n - 1) * barGap) / n;
        return Math.max(minBarWidth, w);
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
            onVChanged: {
                if (v > peak) peak = v;
            }
            Timer {
                interval: 50; running: true; repeat: true
                onTriggered: parent.peak = Math.max(0, parent.peak - 0.04)
            }

            // Base bar (bottom half)
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                radius: width / 3
                height: Math.max(1, Math.min(root.halfH, parent.v * root.halfH))
                y: root.mirror ? root.halfH : root.halfH - height
                color: Qt.rgba(root.colorAt(index).r, root.colorAt(index).g, root.colorAt(index).b, root.fillOpacity)
                antialiasing: true
                Behavior on height { SmoothedAnimation { duration: 100 } }
            }

            // Mirrored bar (top half)
            Rectangle {
                visible: root.mirror
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                radius: width / 3
                height: Math.max(1, Math.min(root.halfH, parent.v * root.halfH))
                y: root.halfH - height
                color: Qt.rgba(root.colorAt(index).r, root.colorAt(index).g, root.colorAt(index).b, root.fillOpacity)
                antialiasing: true
                Behavior on height { SmoothedAnimation { duration: 100 } }
            }

            // Peak indicator
            Rectangle {
                visible: root.mirror
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 2
                radius: height / 2
                y: root.halfH - Math.min(root.halfH, parent.peak * root.halfH) - height
                color: Qt.rgba(root.colorAt(index).r, root.colorAt(index).g, root.colorAt(index).b, root.peakOpacity)
                antialiasing: true
            }
        }
    }
}
