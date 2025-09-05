import QtQuick
import qs.Settings
import qs.Components

Item {
    id: buttonRoot
    property Item barBackground
    property var screen
    width: iconText.implicitWidth + 0
    height: iconText.implicitHeight + 0

    property color hoverColor: Theme.surfaceHover
    property real hoverOpacity: 0.0
    property bool isActive: mouseArea.containsMouse || (sidebarPopup && sidebarPopup.visible)

    property var sidebarPopup

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (sidebarPopup.visible) {
                sidebarPopup.hidePopup();
            } else {
                sidebarPopup.showAt();
            }
        }
        onEntered: buttonRoot.hoverOpacity = 1.0
        onExited: buttonRoot.hoverOpacity = 0.0
    }

    Rectangle {
        anchors.fill: parent
        color: hoverColor
        // Use color alpha directly; animate opacity for hover
        opacity: isActive ? 1.0 : hoverOpacity
        radius: height / 2
        z: 0
        visible: (isActive ? 0.18 : hoverOpacity) > 0.01
    }

    MaterialIcon {
        id: iconText
        icon: "dashboard"
        rounded: isActive
        size: Math.round(Theme.panelIconSizeSmall * Theme.scale(screen))
        color: sidebarPopup.visible ? Theme.accentPrimary : Theme.textPrimary
        anchors.centerIn: parent
        z: 1
    }

    Behavior on hoverOpacity {
        NumberAnimation { duration: Theme.panelHoverFadeMs; easing.type: Easing.OutQuad }
    }
}
