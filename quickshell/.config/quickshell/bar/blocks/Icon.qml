import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../"
import "root:/"

BarBlock {
  id: root
  Layout.preferredWidth: 20

  content: BarText {
    text: "󰣇"
    pointSize: 24
    anchors.horizontalCenterOffset: 4
    anchors.verticalCenterOffset: 3
  }

  color: "transparent"

  Process {
    id: appListProc
    command: ["sh", "-c", "for f in /usr/share/applications/*.desktop; do if ! grep -qi 'terminal=true' \"$f\"; then name=$(grep -i '^Name=' \"$f\" | head -n1 | cut -d= -f2); basename=$(basename \"$f\" .desktop); echo \"$name|$basename|$f\"; fi; done"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        const [appName, launchName, desktopFile] = data.trim().split("|")
        if (appName && launchName && desktopFile) {
          appListModel.append({ name: appName, launchName: launchName, path: desktopFile })
        }
      }
    }
  }

  Process {
    id: appLauncher
    running: false
    command: ["gtk-launch"]
  }

  ListModel {
    id: appListModel
  }

  PopupWindow {
    id: menuWindow
    width: 300
    height: 400
    visible: false

    anchor {
      window: root.QsWindow?.window
      edges: Edges.Bottom
      gravity: Edges.Top
    }

    FocusScope {
      anchors.fill: parent
      focus: true

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: {
          if (!containsMouse) {
            closeTimer.start()
          }
        }
        onEntered: closeTimer.stop()

        Timer {
          id: closeTimer
          interval: 500
          onTriggered: menuWindow.visible = false
        }

        Rectangle {
          anchors.fill: parent
          color: "#2E3440"  // Using Nord theme color
          border.color: "#4C566A"
          border.width: 1
          radius: 4

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            ListView {
              id: appListView
              Layout.fillWidth: true
              Layout.fillHeight: true
              clip: true
              model: appListModel
              delegate: Rectangle {
                width: parent.width
                height: 35
                color: mouseArea.containsMouse ? "#4C566A" : "transparent"
                radius: 4

                Text {
                  anchors.fill: parent
                  anchors.leftMargin: 10
                  text: model.name
                  color: "white"
                  font.pixelSize: 12
                  verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                  id: mouseArea
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: {
                    console.log("Launching:", model.launchName, "from", model.path)
                    appLauncher.command = ["gtk-launch", model.launchName]
                    appLauncher.running = true
                    menuWindow.visible = false
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  function filterApps() {
    const searchText = searchField.text.toLowerCase()
    for (let i = 0; i < appListModel.count; i++) {
      const item = appListModel.get(i)
      item.visible = item.name.toLowerCase().includes(searchText)
    }
  }
  onClicked: function() {
    if (!menuWindow.visible) {
      appListModel.clear()
      appListProc.running = true
    }
    menuWindow.visible = !menuWindow.visible
  }
}