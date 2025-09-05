import QtQuick
import qs.Settings
import qs.Components

Rectangle {
    id: clockWidget
    property var screen: (typeof modelData !== 'undefined' ? modelData : null)
    width: textItem.paintedWidth
    height: textItem.paintedHeight
    color: "transparent"

    Text {
        id: textItem
        text: Time.time
        font.family: Theme.fontFamily
        font.weight: Theme.timeFontWeight
        font.pixelSize: Math.round(Theme.fontSizeSmall * Theme.timeFontScale * Theme.scale(screen))
        color: Theme.timeTextColor
        anchors.centerIn: parent
    }

    MouseArea {
        id: clockMouseArea
        anchors.fill: parent
        hoverEnabled: false
        cursorShape: Qt.PointingHandCursor
        onClicked: function() {
            calendar.visible = !calendar.visible
        }
    }

    Calendar {
        id: calendar
        screen: clockWidget.screen
        visible: false
    }

    // Tooltip removed as requested
}
