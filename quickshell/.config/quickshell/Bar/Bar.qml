import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Bar.Modules
import qs.Components
import qs.Helpers
import qs.Services
import qs.Settings
import qs.Widgets
import qs.Widgets.SidePanel

Scope {
    id: rootScope
    property var shell
    property alias visible: barRootItem.visible
    property real barHeight: 0 // Expose current bar height for other components (e.g. window mirroring)

    Item {
        id: barRootItem
        anchors.fill: parent

        Variants {
            model: Quickshell.screens
            Item {
                property var modelData
                PanelWindow {
                    id: panel
                    screen: modelData
                    color: "transparent"
                    implicitHeight: barBackground.height
                    anchors.top: Settings.settings.panelPosition === "top"
                    anchors.bottom: Settings.settings.panelPosition === "bottom"
                    anchors.left: true
                    anchors.right: true
                    visible: Settings.settings.barMonitors.includes(modelData.name) || (Settings.settings.barMonitors.length === 0)

                    Rectangle { // Bar itself
                        id: barBackground
                        width: parent.width
                        height: 28 * Theme.scale(panel.screen)
                        color: Theme.backgroundPrimary
                        anchors.top: parent.top
                        anchors.left: parent.left
                    }

                    Component.onCompleted: rootScope.barHeight = barBackground.height
                    Row {
                        id: leftWidgetsRow
                        anchors.verticalCenter: barBackground.verticalCenter
                        anchors.left: barBackground.left
                        anchors.leftMargin: 18 * Theme.scale(panel.screen)
                        spacing: 12 * Theme.scale(panel.screen)
                        ClockWidget { anchors.verticalCenter: parent.verticalCenter }
                        DiagonalSeparatorRect { height: barBackground.height + 60 }
                        WsIndicator { id: wsindicator; anchors.verticalCenter: parent.verticalCenter }
                        DiagonalSeparatorRect { height: barBackground.height + 60 }
                        KeyboardLayoutHypr { id: kbIndicator; anchors.verticalCenter: wsindicator.verticalCenter; /* deviceMatch: "dygma-defy-keyboard" */ }
                        NetworkUsage { id: net; anchors.verticalCenter: wsindicator.verticalCenter; }
                        DiagonalSeparatorRect { height: barBackground.height + 60 }
                    }

                    SystemInfo {
                        anchors.horizontalCenter: barBackground.horizontalCenter
                        anchors.verticalCenter: barBackground.verticalCenter
                        visible: true
                    }

                    Row {
                        id: rightWidgetsRow
                        anchors.verticalCenter: barBackground.verticalCenter
                        anchors.right: barBackground.right
                        anchors.rightMargin: 18 * Theme.scale(panel.screen)
                        spacing: 12 * Theme.scale(panel.screen)
                        SystemTray { id: systemTrayModule; shell: rootScope.shell; anchors.verticalCenter: parent.verticalCenter; bar: panel; trayMenu: externalTrayMenu; }
                        CustomTrayMenu { id: externalTrayMenu }
                        Volume { id: widgetsVolume; shell: rootScope.shell; anchors.verticalCenter: parent.verticalCenter; }
                        Media { anchors.verticalCenter: parent.verticalCenter; }
                        PanelPopup { id: sidebarPopup; shell: rootScope.shell; }
                        Button { barBackground: barBackground; anchors.verticalCenter: parent.verticalCenter; screen: modelData; sidebarPopup: sidebarPopup; }
                    }
                }
            }
        }
    }
}
