
import QtQuick
import qs.Components
import qs.Settings
import qs.Widgets.SidePanel

Item {
    id: root
    property bool expanded: false

    height: 24 * Theme.scale(Screen)
    width: 24 * Theme.scale(Screen)

    IconButton {
        id: weatherBtn
        anchors.centerIn: parent
        size: 24 * Theme.scale(Screen)
        icon: "cloud"
        cornerRadius: 4
        accentColor: Theme.accentPrimary
        iconNormalColor: Theme.textPrimary
        iconHoverColor: Theme.onAccent
        onClicked: root.toggle()
    }

    function toggle() {
        expanded = !expanded;
        if (expanded) {
            weatherOverlay.show();
        } else {
            weatherOverlay.dismiss();
        }
    }

    PanelWithOverlay {
        id: weatherOverlay
        visible: false
        onVisibleChanged: {
            if (visible) {
                try { weather.startWeatherFetch(); } catch (e) {}
            } else {
                try { weather.stopWeatherFetch(); } catch (e) {}
            }
        }
        Rectangle {
            id: popup
            radius: 9 * Theme.scale(Screen)
            color: Qt.rgba(0, 0, 0, 0.10)
            border.color: Theme.backgroundTertiary
            border.width: 1
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 8 * Theme.scale(Screen)
            anchors.leftMargin: 18 * Theme.scale(Screen)

            Weather {
                id: weather
                width: 420 * Theme.scale(Screen)
                height: 180 * Theme.scale(Screen)
            }
        }
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: { root.expanded = false; weatherOverlay.dismiss(); }
        }
    }
}
