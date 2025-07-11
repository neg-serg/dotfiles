import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

PanelWindow {
    // required property font custom_font
    required property color text_color
    property list<QtObject> notification_objects

    width: 500
    height: 600

    color: "#171a18"

    WlrLayershell.layer: WlrLayer.Overlay

    Rectangle {
        border.width: 5
        border.color: "#8ec07c"
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            id: content
            anchors {
                left: parent.left
                leftMargin: 10
                right: parent.right
                rightMargin: 10
                top: parent.top
                topMargin: 10
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "Notifications:"
                    // font: custom_font
                    color: text_color
                }

                Text {
                    text: "clear"
                    // font: custom_font
                    color: text_color

                    TapHandler {
                        id: tapHandler
                        gesturePolicy: TapHandler.ReleaseWithinBounds
                        onTapped: {
                            server.trackedNotifications.values.forEach((notification) => {
                                notification.tracked = false
                            })
                            notification_objects.forEach((object) => {
                                object.destroy();
                            })
                            notification_objects = [];
                        }
                    }

                    HoverHandler {
                        id: mouse
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }

    NotificationServer {
        id: server
        onNotification: (notification) => {
            notification.tracked = true
            console.log(JSON.stringify(notification));
            var notification_component = Qt.createComponent("Notification.qml");
            var notification_object = notification_component
            .createObject(content, 
                {
                    id: notification.id,
                    body: notification.body,
                    summary: notification.summary,
                    // font: custom_font,
                    color: text_color,
                    margin: 10
                }
            )
            if (notification_object == null) {
                console.log("Error creating notification")
            } else {
                notification_objects.push(notification_object);
            }
        }
    }
}

