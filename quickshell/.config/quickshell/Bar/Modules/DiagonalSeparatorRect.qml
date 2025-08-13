import QtQuick
import qs.Settings

Item {
    id: root
    property color color: "#BFC8D0"
    property real alpha: 0.05
    property real thickness: 7.0
    property real angleDeg: 30
    property real inset: 4

    implicitWidth: 10
    implicitHeight: 28

    Rectangle {
        id: line
        width: Math.round(thickness * Theme.scale(panel.screen))
        height: Math.hypot(root.width, root.height) - inset*2
        radius: 0
        color: root.color
        opacity: root.alpha
        anchors.centerIn: parent
        anchors.verticalCenter: parent.verticalCenter
        rotation: angleDeg
        antialiasing: true
        layer.enabled: true
        layer.smooth: true
    }
}
