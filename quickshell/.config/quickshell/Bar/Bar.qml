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
                    // Track if mouse is currently over the panel area
                    property bool panelHovering: false
                    // Namespace for Hyprland layerrules
                    WlrLayershell.namespace: "quickshell-bar"

                    // --- Placement / visibility: bar is fixed at bottom ---
                    anchors.bottom: true
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
                    // Bar metrics (logical values from Theme scaled per-screen)
                    property int  barHeightPx:   Math.round(Theme.panelHeight * s)
                    property int  sideMargin:    Math.round(Theme.panelSideMargin * s)
                    property int  widgetSpacing: Math.round(Theme.panelWidgetSpacing * s)
                    // Separator overshoot kept unscaled by design
                    property int  sepOvershoot:  Theme.panelSepOvershoot
                    property color barBgColor:   Theme.background // Colors

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

                    // Hot zone visual removed; area is invisible

                    // Keep rootScope.barHeight in sync with actual bar height
                    Component.onCompleted: {
                        rootScope.barHeight = barBackground.height
                    }
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
                        // Tighter cluster: VPN + Network usage
                        Row {
                            id: netCluster
                            anchors.verticalCenter: wsindicator.verticalCenter
                            spacing: Math.round(Theme.panelNetClusterSpacing * panel.s)
                            LocalMods.VpnAmneziaIndicator {
                                id: amneziaVpn
                                // Icon only
                                showLabel: false
                                iconRounded: true
                            }
                            NetworkUsage { id: net }
                        }
                        DiagSep { visible: Settings.settings.showWeatherInBar === true }
                        LocalMods.WeatherButton {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: Settings.settings.showWeatherInBar === true
                        }
                        // Rightmost separator of the left section: show only if weather is visible
                        DiagSep { stripeEnabled: false; visible: Settings.settings.showWeatherInBar === true }
                    }

                    // SystemInfo removed from the bar; controlled via dedicated module

                    RowLayout {
                        id: rightWidgetsRow
                        anchors.verticalCenter: barBackground.verticalCenter
                        anchors.right: barBackground.right
                        anchors.rightMargin: panel.sideMargin
                        spacing: panel.widgetSpacing
                        Media {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            // Pass the side panel reference so clicking the track toggles it
                            sidePanelPopup: sidebarPopup
                        }
                        // MPD flags as a dedicated section to the right of media
                        LocalMods.MpdFlags {
                            id: mpdFlagsBar
                            Layout.alignment: Qt.AlignVCenter
                            // Enable only when media is visible and MPD-like player is active
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
                        // Side panel button removed; track click toggles sidebarPopup
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

                    // Music popup lives outside layout (overlay window), anchored to this panel window
                    MusicPopup {
                        id: sidebarPopup
                        barMarginPx: rootScope.barHeight
                        anchorWindow: panel
                        panelEdge: "bottom"
                    }

                    // Auto-show popup when album name changes (and is present)
                    // Store last-shown album here (no binding!)
                    property string _lastAlbum: ""
                    function maybeShowOnAlbumChange() {
                        try {
                            if (!panel.visible) return;
                            if (MusicManager.isStopped) return;
                            const album = String(MusicManager.trackAlbum || "");
                            if (!album || album.length === 0) return; // require album present
                            if (album !== panel._lastAlbum) {
                                if (MusicManager.trackTitle || MusicManager.trackArtist) sidebarPopup.showAt();
                                panel._lastAlbum = album;
                            }
                        } catch (e) { /* ignore */ }
                    }
                    // removed: merged into the Component.onCompleted above
                    Connections {
                        target: MusicManager
                        function onTrackAlbumChanged()  { panel.maybeShowOnAlbumChange(); }
                    }

                    // Hover hot-zone to reveal tray: to the right of music and volume (outside Row to avoid anchor warnings)
                    MouseArea {
                        id: trayHotZone
                        anchors.right: barBackground.right
                        anchors.bottom: barBackground.bottom
                        // Size and offset from Theme metrics (scaled)
                        width: Math.round(Theme.panelHotzoneWidth * panel.s)
                        height: Math.round(Theme.panelHotzoneHeight * panel.s)
                        // Shift left by a factor of its width
                        anchors.rightMargin: Math.round(width * Theme.panelHotzoneRightShift)
                        anchors.bottomMargin: Theme.uiMarginNone
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        // Place above generic bar hover tracker so it receives hover reliably
                        z: 10001
                        onEntered: {
                            systemTrayModule.hotHover = true
                            systemTrayModule.expanded = true
                        }
                        onExited: {
                            systemTrayModule.hotHover = false
                            // Do not collapse here; allow staying open while on panel
                        }
                        cursorShape: Qt.ArrowCursor
                        // No visual here; drawn by trayHotZoneVisual below content
                    }

                    // Bar-wide hover tracker to keep tray open while cursor is anywhere on the bar
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
                        // fully transparent tracker
                        Rectangle { visible: false }
                    }

                    // (Removed overlay layer; inline tray expansion handles layout and stacking)
                }
            }
        }
    }
}
