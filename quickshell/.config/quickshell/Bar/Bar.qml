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
import qs.Widgets.Notification
import qs.Widgets.SidePanel

Scope {
    id: rootScope
    property var shell
    property alias visible: barRootItem.visible

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
                    anchors.bottom: true
                    anchors.left: true
                    anchors.right: true
                    visible: Settings.settings.barMonitors.includes(modelData.name) || (Settings.settings.barMonitors.length === 0)

                    Rectangle {
                        id: barBackground
                        width: parent.width
                        height: 36 * Theme.scale(panel.screen)
                        color: Theme.backgroundPrimary
                        anchors.top: parent.top
                        anchors.left: parent.left
                    }


                    Row {
                        id: leftWidgetsRow
                        anchors.verticalCenter: barBackground.verticalCenter
                        anchors.left: barBackground.left
                        anchors.leftMargin: 18 * Theme.scale(panel.screen)
                        spacing: 12 * Theme.scale(panel.screen)

                        ClockWidget {
                            screen: modelData
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        SystemInfo {
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Workspace {
                        id: workspace
                        screen: modelData
                        anchors.horizontalCenter: barBackground.horizontalCenter
                        anchors.verticalCenter: barBackground.verticalCenter
                    }

                    Row {
                        id: rightWidgetsRow
                        anchors.verticalCenter: barBackground.verticalCenter
                        anchors.right: barBackground.right
                        anchors.rightMargin: 18 * Theme.scale(panel.screen)
                        spacing: 12 * Theme.scale(panel.screen)

                        SystemTray {
                            id: systemTrayModule
                            shell: rootScope.shell
                            anchors.verticalCenter: parent.verticalCenter
                            bar: panel
                            trayMenu: externalTrayMenu
                        }

                        CustomTrayMenu {
                            id: externalTrayMenu
                        }

                        NotificationIcon {
                            shell: rootScope.shell
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Wifi {
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Bluetooth {
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Battery {
                            id: widgetsBattery
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Volume {
                            id: widgetsVolume
                            shell: rootScope.shell
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        PanelPopup {
                            id: sidebarPopup
                            shell: rootScope.shell
                        }

                        Button {
                            barBackground: barBackground
                            anchors.verticalCenter: parent.verticalCenter
                            screen: modelData
                            sidebarPopup: sidebarPopup
                        }

                        Media {
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                }

                Loader {
                    active: (Settings.settings.barMonitors.length === 0)
                    sourceComponent: Item {
                        PanelWindow {
                            id: topLeftPanel
                            anchors.top: true
                            anchors.left: true
                            color: "transparent"
                            screen: modelData
                            margins.top: 36 * Theme.scale(screen) - 1
                            WlrLayershell.exclusionMode: ExclusionMode.Ignore
                            WlrLayershell.layer: WlrLayer.Top
                            WlrLayershell.namespace: "swww-daemon"
                            aboveWindows: false
                            implicitHeight: 24
                        }

                        PanelWindow {
                            id: topRightPanel
                            anchors.top: true
                            anchors.right: true
                            color: "transparent"
                            screen: modelData
                            margins.top: 36 * Theme.scale(screen) - 1
                            WlrLayershell.exclusionMode: ExclusionMode.Ignore
                            WlrLayershell.layer: WlrLayer.Top
                            WlrLayershell.namespace: "swww-daemon"
                            aboveWindows: false
                            implicitHeight: 24
                        }

                        PanelWindow {
                            id: bottomLeftPanel
                            anchors.bottom: true
                            anchors.left: true
                            color: "transparent"
                            screen: modelData
                            WlrLayershell.exclusionMode: ExclusionMode.Ignore
                            WlrLayershell.layer: WlrLayer.Top
                            WlrLayershell.namespace: "swww-daemon"
                            aboveWindows: false
                            implicitHeight: 24
                        }

                        PanelWindow {
                            id: bottomRightPanel
                            anchors.bottom: true
                            anchors.right: true
                            color: "transparent"
                            screen: modelData
                            WlrLayershell.exclusionMode: ExclusionMode.Ignore
                            WlrLayershell.layer: WlrLayer.Top
                            WlrLayershell.namespace: "swww-daemon"
                            aboveWindows: false
                            implicitHeight: 24
                        }
                    }
                }
            }
        }
    }
}
