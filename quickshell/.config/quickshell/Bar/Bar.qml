import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Bar.Modules
import qs.Components
import "Modules" as LocalMods
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
                property var modelData // 'modelData' comes from Variants
                PanelWindow {
                    id: panel
                    screen: modelData
                    color: "transparent"

                    // --- Placement / visibility as in your original ---
                    anchors.top:    Settings.settings.panelPosition === "top"
                    anchors.bottom: Settings.settings.panelPosition === "bottom"
                    anchors.left:   true
                    anchors.right:  true
                    visible: Settings.settings.barMonitors.includes(modelData.name)
                             || (Settings.settings.barMonitors.length === 0)
                    // --- Docking: reserve space & push tiled windows ---
                    implicitHeight: barBackground.height
                    exclusionMode: ExclusionMode.Normal
                    exclusiveZone: panel.barHeightPx   // reserve exactly bar height
                    // ---------- Lifted/shared properties ----------
                    // UI scale for this screen
                    property real s: Theme.scale(panel.screen)
                    // Bar metrics
                    property int  barHeightPx: Math.round(28 * s)
                    property int  sideMargin:  Math.round(18 * s)
                    property int  widgetSpacing: Math.round(12 * s)
                    property int  sepOvershoot: 60 // Separator overshoot (kept unscaled to preserve look)
                    property color barBgColor: Theme.backgroundPrimary // Colors

                    // Inline component for repeated diagonal separator
                    component DiagSep: DiagonalSeparatorRect {
                        // extend beyond bar for a nicer cut
                        height: barBackground.height + panel.sepOvershoot
                    }

                    Rectangle { // Bar background
                        id: barBackground
                        width:  parent.width
                        height: panel.barHeightPx
                        color:  panel.barBgColor
                        anchors.top: parent.top
                        anchors.left: parent.left
                    }

                    // Keep rootScope.barHeight in sync with actual bar height
                    Component.onCompleted: rootScope.barHeight = barBackground.height
                    Connections {
                        target: barBackground
                        function onHeightChanged() { rootScope.barHeight = barBackground.height }
                    }

                    Row {
                        id: leftWidgetsRow
                        anchors.verticalCenter: barBackground.verticalCenter
                        anchors.left: barBackground.left
                        anchors.leftMargin: panel.sideMargin
                        spacing: panel.widgetSpacing
                        ClockWidget { anchors.verticalCenter: parent.verticalCenter }
                        // Separator between clock and workspaces: no accent stripe
                        DiagSep { stripeEnabled: false }
                        WsIndicator { id: wsindicator; anchors.verticalCenter: parent.verticalCenter }
                        DiagSep {}
                        KeyboardLayoutHypr { id: kbIndicator; anchors.verticalCenter: wsindicator.verticalCenter; /* deviceMatch: "dygma-defy-keyboard" */ }
                        DiagSep {}
                        NetworkUsage { id: net; anchors.verticalCenter: wsindicator.verticalCenter }
                        DiagSep {}
                        LocalMods.WeatherButton { anchors.verticalCenter: parent.verticalCenter }
                        // Rightmost separator of the left section: no accent stripe
                        DiagSep { stripeEnabled: false }
                    }

                    SystemInfo {
                        anchors.horizontalCenter: barBackground.horizontalCenter
                        anchors.verticalCenter: barBackground.verticalCenter
                        visible: false
                    }

                    Row {
                        id: rightWidgetsRow
                        anchors.verticalCenter: barBackground.verticalCenter
                        anchors.right: barBackground.right
                        anchors.rightMargin: panel.sideMargin
                        spacing: panel.widgetSpacing
                        Media { anchors.verticalCenter: parent.verticalCenter }
                        PanelPopup { id: sidebarPopup; shell: rootScope.shell }
                        Button {
                            barBackground: barBackground
                            anchors.verticalCenter: parent.verticalCenter
                            screen: modelData
                            sidebarPopup: sidebarPopup
                        }
                        SystemTray {
                            id: systemTrayModule
                            shell: rootScope.shell
                            // Avoid anchors inside Row (causes warnings); manual centering instead
                            y: (parent.height - height) / 2
                            trayMenu: externalTrayMenu
                        }
                        CustomTrayMenu { id: externalTrayMenu }
                        Volume {
                            id: widgetsVolume
                            shell: rootScope.shell
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // (Removed overlay layer; inline tray expansion handles layout and stacking)
                }
            }
        }
    }
}
