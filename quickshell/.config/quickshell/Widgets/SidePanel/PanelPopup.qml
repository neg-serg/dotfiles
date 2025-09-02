import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Components
import qs.Settings

PanelWithOverlay {
    id: sidebarPopup
    // No global dimming for music info
    showOverlay: false
    // Give the side panel a namespace so Hyprland can apply blur rules
    WlrLayershell.namespace: "quickshell-sidepanel"
    property var shell: null
    function showAt() { sidebarPopupRect.showAt(); }
    function hidePopup() { sidebarPopupRect.hidePopup(); }
    function show() { sidebarPopupRect.showAt(); }
    function dismiss() { sidebarPopupRect.hidePopup(); }
    // Weather prefetch removed; Weather is handled by WeatherButton now

        Rectangle {
            // Access the shell's SettingsWindow instead of creating a new one
            id: sidebarPopupRect
        property real slideOffset: width
        property int  showDuration: 220
        property bool isAnimating: false
        // Minimal margins around content (no vertical padding by request)
        property int leftPadding: 4 * Theme.scale(screen)
        property int bottomPadding: 0
        function showAt() {
            if (!sidebarPopup.visible) {
                // Pre-position off-screen and fade-in to avoid top flicker
                slideOffset = width;
                mainRectangle.opacity = 0;
                sidebarPopup.visible = true;
                forceActiveFocus();
                Qt.callLater(() => {
                    slideAnim.from = width;
                    slideAnim.to = 0;
                    slideAnim.duration = sidebarPopupRect.showDuration;
                    slideAnim.running = true;
                    fadeInAnim.running = true;
                });
            }
        }

        function hidePopup() {
            if (sidebarPopup.visible) {
                slideAnim.from = slideOffset;
                slideAnim.to = width;
                slideAnim.running = true;
            }
        }

        // Size panel to music implicit size (no extra top/bottom)
        property real musicWidthPx: 720 * Theme.scale(screen)
        property real musicHeightPx: musicWidget ? musicWidget.implicitHeight : 0
        width: Math.round(musicWidthPx + leftPadding)
        height: Math.round(musicHeightPx + bottomPadding)
        visible: parent.visible
        color: "transparent"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        MouseArea { anchors.fill: parent; } // Prevent closing when clicking in the panel bg
        NumberAnimation {
            id: slideAnim
            target: sidebarPopupRect
            property: "slideOffset"
            duration: 300
            easing.type: Easing.OutCubic
            onStopped: {
                if (sidebarPopupRect.slideOffset === sidebarPopupRect.width) {
                    sidebarPopup.visible = false;
                }
                sidebarPopupRect.isAnimating = false;
            }
            onStarted: {
                sidebarPopupRect.isAnimating = true;
            }
        }

        NumberAnimation {
            id: fadeInAnim
            target: mainRectangle
            property: "opacity"
            duration: sidebarPopupRect.showDuration
            from: 0
            to: 1
            easing.type: Easing.OutCubic
            running: false
        }

        Rectangle {
            id: mainRectangle
            // anchors.top: sidebarPopupRect.top
            width: sidebarPopupRect.width - sidebarPopupRect.leftPadding
            height: sidebarPopupRect.height - sidebarPopupRect.bottomPadding
            x: sidebarPopupRect.leftPadding + sidebarPopupRect.slideOffset
            // Attach to bottom so panel grows/appears from bottom edge upward
            anchors.bottom: parent.bottom
            // Panel backdrop: very transparent black
            color: Qt.rgba(0, 0, 0, 0.10)
            bottomLeftRadius: 20
            // Cache layer to avoid re-rendering chunks while sliding
            layer.enabled: true
            layer.smooth: true
            clip: true
            opacity: 1

        }

        // Content layer
        Item {
            anchors.fill: mainRectangle
            z: 1
            // Fixed inside the sliding container
            x: 0
            Keys.onEscapePressed: sidebarPopupRect.hidePopup()
            ColumnLayout {
                id: contentCol
                anchors.fill: parent
                spacing: 8 * Theme.scale(screen)
                // Weather widget removed from this panel; available via WeatherButton popup

                RowLayout { // Music only
                    spacing: 8 * Theme.scale(screen)
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter
                    Music {
                        id: musicWidget
                        width: sidebarPopupRect.musicWidthPx
                        // Height from implicit size to avoid extra top/bottom padding
                    }
                }

                // small spacer removed by request

            }

            // No extra animation here; the whole panel slides as one layer
        }

    }
}
