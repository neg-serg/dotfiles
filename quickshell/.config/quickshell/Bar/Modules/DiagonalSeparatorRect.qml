import QtQuick

Item {
    id: root
    property color color: "#BFC8D0"
    property real alpha: 0.7
    property real thickness: 1.5
    property real angleDeg: 60
    property real inset: 4

    implicitWidth: 10
    implicitHeight: 28

    Rectangle {
        id: line
        width: thickness
        height: Math.hypot(root.width, root.height) - inset*2
        radius: width/2
        color: root.color
        opacity: root.alpha
        anchors.centerIn: parent
        rotation: angleDeg
        antialiasing: true
        layer.enabled: true
        layer.smooth: true
    }
}
