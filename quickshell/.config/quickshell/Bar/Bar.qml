import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Bar.Modules
import qs.Components
import "Modules" as LocalMods
import qs.Services
import qs.Settings
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
                    property bool panelHovering: false
                    WlrLayershell.namespace: "quickshell-bar"
                    anchors.bottom: true
                    anchors.left: true
                    anchors.right: true
                    visible: Settings.settings.barMonitors.includes(modelData.name)
                             || (Settings.settings.barMonitors.length === 0)
                    implicitHeight: barBackground.height
                    exclusionMode: ExclusionMode.Normal
                    exclusiveZone: panel.barHeightPx   // reserve exactly bar height
                    property real s: Theme.scale(panel.screen)
                    property int barHeightPx:Math.round(Theme.panelHeight * s)
                    property int sideMargin:Math.round(Theme.panelSideMargin * s)
                    property int widgetSpacing:Math.round(Theme.panelWidgetSpacing * s)
                    property int sepOvershoot:Theme.panelSepOvershoot
                    property color barBgColor: Theme.background // Colors

                    // Inline component for repeated diagonal separator
                    component DiagSep: ThemedSeparator {
                        kind: "diagonal"
                        // For layouts: provide preferred height so RowLayout sizes correctly
                        Layout.preferredHeight: barBackground.height + panel.sepOvershoot
                        // Also set height for non-layout contexts (defensive)
                        height: Layout.preferredHeight
                    }

                    Rectangle { // Bar background
                        id: barBackground
                        width: parent.width
                        height: panel.barHeightPx
                        color: panel.barBgColor
                        anchors.top: parent.top
                        anchors.left: parent.left
                    }

                    

                    Component.onCompleted: {
                        rootScope.barHeight = barBackground.height
                    }
                    Connections {
                        target: barBackground
                        function onHeightChanged() { rootScope.barHeight = barBackground.height }
                    }

                    RowLayout {
                        id: leftWidgetsRow
                        anchors.verticalCenter: barBackground.verticalCenter
                        anchors.left: barBackground.left
                        anchors.leftMargin: panel.sideMargin
                        spacing: panel.widgetSpacing
                        ClockWidget { Layout.alignment: Qt.AlignVCenter }
                        DiagSep { stripeEnabled: false; Layout.alignment: Qt.AlignVCenter }
                        WsIndicator { id: wsindicator; Layout.alignment: Qt.AlignVCenter }
                        DiagSep { Layout.alignment: Qt.AlignVCenter }
                        KeyboardLayoutHypr { id: kbIndicator; /* deviceMatch: "dygma-defy-keyboard" */ Layout.alignment: Qt.AlignVCenter }
                        DiagSep { Layout.alignment: Qt.AlignVCenter }
                        Row {
                            id: netCluster
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Math.round(Theme.panelNetClusterSpacing * panel.s)
                            LocalMods.VpnAmneziaIndicator {
                                id: amneziaVpn
                                showLabel: false
                                iconRounded: true
                            }
                            NetworkUsage { id: net }
                        }
                        DiagSep { visible: Settings.settings.showWeatherInBar === true; Layout.alignment: Qt.AlignVCenter }
                        LocalMods.WeatherButton { visible: Settings.settings.showWeatherInBar === true; Layout.alignment: Qt.AlignVCenter }
                        // Rightmost separator of the left section: show only if weather is visible
                        DiagSep { stripeEnabled: false; visible: Settings.settings.showWeatherInBar === true; Layout.alignment: Qt.AlignVCenter }
                    }

                    

                    RowLayout {
                        id: rightWidgetsRow
                        anchors.verticalCenter: barBackground.verticalCenter
                        anchors.right: barBackground.right
                        anchors.rightMargin: panel.sideMargin
                        spacing: panel.widgetSpacing
                        Media {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            sidePanelPopup: sidebarPopup
                        }
                        LocalMods.MpdFlags {
                            id: mpdFlagsBar
                            Layout.alignment: Qt.AlignVCenter
                            property bool _mediaVisible: (
                                Settings.settings.showMediaInBar
                                && MusicManager.currentPlayer
                                && !MusicManager.isStopped
                                && (MusicManager.isPlaying || MusicManager.isPaused || (MusicManager.trackTitle && MusicManager.trackTitle.length > 0))
                            )
                            enabled: _mediaVisible && MusicManager.isCurrentMpdPlayer()
                            iconPx: Math.round(Theme.fontSizeSmall * Theme.scale(panel.screen) * Theme.mpdFlagsIconScale)
                            iconColor: Theme.textPrimary
                        }
                        
                        SystemTray {
                            id: systemTrayModule
                            shell: rootScope.shell
                            screen: modelData
                            Layout.alignment: Qt.AlignVCenter
                            trayMenu: externalTrayMenu
                        }
                        CustomTrayMenu { id: externalTrayMenu }
                        Volume {
                            id: widgetsVolume
                            Layout.alignment: Qt.AlignVCenter
                        }

                    }

                    MusicPopup {
                        id: sidebarPopup
                        barMarginPx: rootScope.barHeight
                        anchorWindow: panel
                        panelEdge: "bottom"
                    }

                    property string _lastAlbum: ""
                    function maybeShowOnAlbumChange() {
                        try {
                            if (!panel.visible) return;
                            if (MusicManager.isStopped) return;
                            const album = String(MusicManager.trackAlbum || "");
                            if (!album || album.length === 0) return;
                            if (album !== panel._lastAlbum) {
                                if (MusicManager.trackTitle || MusicManager.trackArtist) sidebarPopup.showAt();
                                panel._lastAlbum = album;
                            }
                        } catch (e) { /* ignore */ }
                    }
                    
                    Connections {
                        target: MusicManager
                        function onTrackAlbumChanged()  { panel.maybeShowOnAlbumChange(); }
                    }

                    MouseArea {
                        id: trayHotZone
                        anchors.right: barBackground.right
                        anchors.bottom: barBackground.bottom
                        width: Math.round(Theme.panelHotzoneWidth * panel.s)
                        height: Math.round(Theme.panelHotzoneHeight * panel.s)
                        anchors.rightMargin: Math.round(width * Theme.panelHotzoneRightShift)
                        anchors.bottomMargin: Theme.uiMarginNone
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        z: 10001
                        onEntered: {
                            systemTrayModule.hotHover = true
                            systemTrayModule.expanded = true
                        }
                        onExited: {
                            systemTrayModule.hotHover = false
                        }
                        cursorShape: Qt.ArrowCursor
                    }

                    MouseArea {
                        id: barHoverTracker
                        anchors.fill: barBackground
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        propagateComposedEvents: true
                        z: 10000
                        onEntered: { systemTrayModule.panelHover = true; panel.panelHovering = true }
                            onExited: {
                                systemTrayModule.panelHover = false
                                panel.panelHovering = false
                                const menuOpen = systemTrayModule.trayMenu && systemTrayModule.trayMenu.visible
                                if (!systemTrayModule.hotHover && !systemTrayModule.holdOpen && !systemTrayModule.shortHoldActive && !menuOpen) {
                                    systemTrayModule.expanded = false
                                }
                            }
                        visible: true
                        Rectangle { visible: false }
                    }

                }
            }
        }
    }
}
