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

                    // Hot zone visual removed; area is invisible

                    // Keep rootScope.barHeight in sync with actual bar height and init track/cover keys
                    Component.onCompleted: {
                        rootScope.barHeight = barBackground.height
                        panel._lastTrackKey = _trackKey()
                        panel._lastCoverUrl = String(MusicManager.coverUrl || "")
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
                        NetworkUsage { id: net; anchors.verticalCenter: wsindicator.verticalCenter }
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
                            function _isMpd() {
                                try {
                                    const p = MusicManager.currentPlayer; if (!p) return false;
                                    const idStr = String((p.service || p.busName || "")).toLowerCase();
                                    const nameStr = String(p.name || "").toLowerCase();
                                    const identStr = String(p.identity || "").toLowerCase();
                                    return /(mpd|mpdris|mopidy|music\s*player\s*daemon)/.test(idStr)
                                        || /(mpd|mpdris|mopidy|music\s*player\s*daemon)/.test(nameStr)
                                        || /(mpd|mpdris|mopidy|music\s*player\s*daemon)/.test(identStr);
                                } catch (e) { return false; }
                            }
                            enabled: _mediaVisible && _isMpd()
                            iconPx: Math.round(Theme.fontSizeSmall * Theme.scale(panel.screen) * 0.95)
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
                            shell: rootScope.shell
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

                    // Auto-show music popup on track change
                    // Build a composite key to detect actual track changes across metadata
                    property string _lastTrackKey: ""
                    property string _lastCoverUrl: ""
                    function _trackKey() {
                        try {
                            const t = String(MusicManager.trackTitle || "");
                            const a = String(MusicManager.trackArtist || "");
                            const al= String(MusicManager.trackAlbum || "");
                            const lenMs = MusicManager.mprisToMs ? MusicManager.mprisToMs(MusicManager.trackLength || 0) : (MusicManager.trackLength || 0);
                            return [a, t, al, String(lenMs || 0)].join("|");
                        } catch (e) { return ""; }
                    }
                    function _maybeShowOnTrackChange() {
                        try {
                            if (!panel.visible) return;
                            if (!MusicManager.isPlaying) return;
                            const key = _trackKey();
                            if (!key || key === panel._lastTrackKey) return;
                            const cover = String(MusicManager.coverUrl || "");
                            // Do not show if cover art did not change
                            if (cover === panel._lastCoverUrl) {
                                panel._lastTrackKey = key;
                                panel._lastCoverUrl = cover;
                                return;
                            }
                            panel._lastTrackKey = key;
                            panel._lastCoverUrl = cover;
                            if (MusicManager.trackTitle || MusicManager.trackArtist) sidebarPopup.showAt();
                        } catch (e) { /* ignore */ }
                    }
                    // removed: merged into the Component.onCompleted above
                    Connections {
                        target: MusicManager
                        // React when metadata that identifies the track changes
                        function onTrackTitleChanged()  { panel._maybeShowOnTrackChange(); }
                        function onTrackArtistChanged() { panel._maybeShowOnTrackChange(); }
                        function onTrackAlbumChanged()  { panel._maybeShowOnTrackChange(); }
                        function onTrackLengthChanged() { panel._maybeShowOnTrackChange(); }
                    }

                    // Hover hot-zone to reveal tray: to the right of music and volume (outside Row to avoid anchor warnings)
                    MouseArea {
                        id: trayHotZone
                        anchors.right: barBackground.right
                        anchors.bottom: barBackground.bottom
                        // 4x narrower, 2x lower (half height)
                        width: Math.round(16 * panel.s)
                        height: Math.round(9 * panel.s)
                        // Shift left by 115% of its own width (previous position)
                        anchors.rightMargin: Math.round(width * 1.15)
                        anchors.bottomMargin: 0
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
