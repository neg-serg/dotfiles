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

    ThemedHoverRect {
        anchors.fill: parent
        colorToken: hoverColor
        radiusFactor: Theme.sidePanelButtonHoverRadiusFactor
        epsToken: Theme.uiVisibilityEpsilon
        intensity: isActive ? 1.0 : hoverOpacity
        z: 0
        visible: (isActive ? Theme.sidePanelButtonActiveVisibleMin : hoverOpacity) > Theme.uiVisibilityEpsilon
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

    Behavior on hoverOpacity { NumberFadeBehavior { duration: Theme.panelHoverFadeMs } }
}
