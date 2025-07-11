import QtQuick
import Quickshell.Services.Notifications
import "../"

BarBlock {
    id: root
    property bool showNotification: false

    text: "  " + notifServer.trackedNotifications.values.length
    onClicked: function() {
      showNotification = !showNotification
    }

    NotificationServer {
        id: notifServer
        onNotification: (notification) => {
            notification.tracked = true
        }
    }

    NotificationPanel {
        text_color: root.color
        visible: showNotification

        anchors {
            top: parent.top
        }

        margins {
            top: 10
        }
    }
}

