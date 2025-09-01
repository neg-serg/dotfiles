import QtQuick
import qs.Components
import qs.Settings

Item {
    id: root
    property int innerRadius: 34 * Theme.scale(Screen)
    property int outerRadius: 48 * Theme.scale(Screen)
    // Visual style
    // Accepts: "radial", "diamond", "fire", "roundedSquare"
    property string visualizerType: Settings.settings.visualizerType
    // Squircle power for rounded square (m=4 ~ rounded square)
    property real superellipsePower: 4.0
    // Scale of bar height (0..1)
    property real amplitudeScale: 1.0
    property color fillColor: "#fff"
    property real  fillOpacity: 0.5
    property color strokeColor: "#fff"
    property real  strokeOpacity: 0.5
    property int strokeWidth: 0 * Theme.scale(Screen)
    property var values: []
    property int usableOuter: 48
    width: usableOuter * 2
    height: usableOuter * 2

    onOuterRadiusChanged: () => {
        usableOuter = root.visualizerType === "fire" ? outerRadius * 0.85 : outerRadius;
    }

    Repeater {
        model: root.values.length
        Rectangle {
            property real value: root.values[index]
            property real angle: (index / root.values.length) * 360
            width: Math.max(2 * Theme.scale(Screen), (root.innerRadius * 2 * Math.PI) / root.values.length - 4 * Theme.scale(Screen))
            height: root.visualizerType === "diamond"
                    ? value * 2 * root.amplitudeScale * (usableOuter - root.innerRadius)
                    : value * root.amplitudeScale * (usableOuter - root.innerRadius)
            radius: width / 2
            color: Qt.rgba(root.fillColor.r, root.fillColor.g, root.fillColor.b, root.fillOpacity)
            border.color: Qt.rgba(root.strokeColor.r, root.strokeColor.g, root.strokeColor.b, root.strokeOpacity)
            border.width: root.strokeWidth
            antialiasing: true
            // Position along shape
            x: (function(){
                    if (root.visualizerType === "radial") {
                        return root.width / 2 - width / 2;
                    }
                    if (root.visualizerType === "roundedSquare") {
                        const theta = 2 * Math.PI * index / root.values.length;
                        const c = Math.cos(theta), s = Math.sin(theta);
                        const p = root.superellipsePower;
                        const px = root.innerRadius * Math.sign(c) * Math.pow(Math.abs(c), 2 / p);
                        return root.width / 2 + px - width / 2;
                    }
                    // Default circular placement
                    return root.width / 2 + root.innerRadius * Math.cos(Math.PI / 2 + 2 * Math.PI * index / root.values.length) - width / 2;
                })()
            y: (function(){
                    if (root.visualizerType === "radial") {
                        return root.height / 2 - height;
                    }
                    if (root.visualizerType === "roundedSquare") {
                        const theta = 2 * Math.PI * index / root.values.length;
                        const c = Math.cos(theta), s = Math.sin(theta);
                        const p = root.superellipsePower;
                        const py = root.innerRadius * Math.sign(s) * Math.pow(Math.abs(s), 2 / p);
                        return root.height / 2 - py - height;
                    }
                    // Diamond/Fire/Circle default
                    return root.height / 2 - root.innerRadius * Math.sin(Math.PI / 2 + 2 * Math.PI * index / root.values.length) - height;
                })()
            transform: [
                Rotation {
                    origin.x: width / 2
                    origin.y: root.visualizerType === "diamond" ? height / 2 : height
                    angle: (function(){
                            if (root.visualizerType === "radial") {
                                return (index / root.values.length) * 360;
                            }
                            if (root.visualizerType === "fire") {
                                return 0;
                            }
                            if (root.visualizerType === "roundedSquare") {
                                const theta = 2 * Math.PI * index / root.values.length;
                                const c = Math.cos(theta), s = Math.sin(theta);
                                const p = root.superellipsePower;
                                const px = root.innerRadius * Math.sign(c) * Math.pow(Math.abs(c), 2 / p);
                                const py = root.innerRadius * Math.sign(s) * Math.pow(Math.abs(s), 2 / p);
                                // Radial angle from center to point, minus 90 to orient outward
                                return Math.atan2(py, px) * 180 / Math.PI - 90;
                            }
                            // diamond/circle default
                            return (index / root.values.length) * 360 - 90;
                        })()
                },
                Translate {
                    x: root.visualizerType === "radial" ? root.innerRadius * Math.cos(2 * Math.PI * index / root.values.length) : 0
                    y: root.visualizerType === "radial" ? root.innerRadius * Math.sin(2 * Math.PI * index / root.values.length) : 0
                }
            ]

            Behavior on height {
                SmoothedAnimation {
                    duration: 120
                }
            }
        }
    }
}
