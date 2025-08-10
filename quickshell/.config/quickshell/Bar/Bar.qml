import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
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
    // Expose current bar height for other components (e.g. window mirroring)
    property real barHeight: 0
    // Track native tray menu visibility globally
    property bool trayMenuOpen: false

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

                    Rectangle {
                        id: barBackground
                        width: parent.width
                        height: 28 * Theme.scale(panel.screen)
                        color: Theme.backgroundPrimary
                        anchors.top: parent.top
                        anchors.left: parent.left
                    }

                    // Update exposed bar height once the bar is created
                    Component.onCompleted: rootScope.barHeight = barBackground.height

                    // ── Tray menu + focus grab coordination ───────────────────────────
                    QsMenuAnchor {
                        id: trayMenuAnchor
                        anchor.window: panel
                        // When native tray menu opens, disable focus grab to avoid instant close
                        onOpened:  { rootScope.trayMenuOpen = true;  focusGrab.active = false }
                        // When it closes, re-enable focus grab for your custom popups
                        onClosed:  { rootScope.trayMenuOpen = false; focusGrab.active = true  }
                    }

                    HyprlandFocusGrab {
                        id: focusGrab
                        windows: [ panel ]
                        onCleared: {
                            // Don't auto-close native tray menu; it handles outside clicks itself
                            if (rootScope.trayMenuOpen) return
                            // Close ONLY your custom popups here, if needed, e.g.:
                            // sidebarPopup.close()
                        }
                    }
                    // ─────────────────────────────────────────────────────────────────

                    Row {
                        id: leftWidgetsRow
                        anchors.verticalCenter: barBackground.verticalCenter
                        anchors.left: barBackground.left
                        anchors.leftMargin: 18 * Theme.scale(panel.screen)
                        spacing: 12 * Theme.scale(panel.screen)

                        ClockWidget {
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        DiagonalSeparatorRect {
                            width: Math.round(15 * Theme.scale(panel.screen))
                            height: barBackground.height + 60
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#BFC8D0"
                            alpha: 0.05
                            thickness: 7.0
                            angleDeg: 30
                        }

                        WsIndicator {
                            id: wsindicator
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        DiagonalSeparatorRect {
                            width: Math.round(15 * Theme.scale(panel.screen))
                            height: barBackground.height + 60
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#BFC8D0"
                            alpha: 0.05
                            thickness: 7.0
                            angleDeg: 30
                        }

                        KeyboardLayoutHypr {
                            id: kbIndicator
                            deviceMatch: "dygma-defy-keyboard"
                            fontPixelSize: Theme.fontSizeSmall * Theme.scale(panel.screen)
                            desiredHeight: Math.max(20, barBackground.height - 4)
                            screen: panel.screen
                            anchors.verticalCenter: wsindicator.verticalCenter
                            yNudge: -1
                            iconScale: 0.95
                            iconSpacing: Math.round(4 * Theme.scale(panel.screen))
                        }

                        NetworkUsage {
                            id: net
                            anchors.verticalCenter: parent.verticalCenter
                            desiredHeight: barBackground.height
                            fontPixelSize: Theme.fontSizeSmall * Theme.scale(panel.screen)
                            height: barBackground.height
                            iconSpacing: 6
                            screen: panel.screen
                            useTheme: false
                        }

                        DiagonalSeparatorRect {
                            width: Math.round(15 * Theme.scale(panel.screen))
                            height: barBackground.height + 60
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#BFC8D0"
                            alpha: 0.05
                            thickness: 7.0
                            angleDeg: 30
                        }
                    }

                    SystemInfo {
                        id: center
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
                            trayMenu: trayMenuAnchor
                        }

                        NotificationIcon {
                            shell: rootScope.shell
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Bluetooth {
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
