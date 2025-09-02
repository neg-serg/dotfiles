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
        // Bottom-up reveal height for show animation
        property real revealHeight: 0
        // Minimal margins around content (no vertical padding by request)
        property int leftPadding: 4 * Theme.scale(screen)
        property int bottomPadding: 0
        function showAt() {
            if (!sidebarPopup.visible) {
                // Show immediately in final horizontal position; reveal vertically from bottom
                slideOffset = 0;
                revealHeight = 0;
                sidebarPopup.visible = true;
                forceActiveFocus();
                revealAnim.from = 0;
                revealAnim.to = mainRectangle.height;
                revealAnim.duration = sidebarPopupRect.showDuration;
                revealAnim.restart();
            }
        }

        function hidePopup() {
            if (sidebarPopup.visible) {
                slideAnim.from = slideOffset;
                slideAnim.to = width;
                slideAnim.running = true;
            }
        }

        // Use stable, precomputed size to avoid initial reflow/flicker
        property real musicWidthPx: 720 * Theme.scale(screen)
        property real musicHeightPx: 250 * Theme.scale(screen)
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
            id: revealAnim
            target: sidebarPopupRect
            property: "revealHeight"
            duration: sidebarPopupRect.showDuration
            from: 0
            to: 0
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
            // Clip that reveals bottom-up on show
            Item {
                id: revealClip
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: Math.max(0, Math.min(parent.height, sidebarPopupRect.revealHeight))
                clip: true
                // Flip vertically so height growth reveals from bottom; re-flip content back
                transform: Scale { yScale: -1; origin.y: revealClip.height / 2 }
                ColumnLayout {
                    id: contentCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    // Reverse flip to keep content upright
                    transform: Scale { yScale: -1; origin.y: 0 }
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
            // Close revealClip item explicitly to ensure proper nesting
            }

            // No extra animation here; the whole panel slides as one layer
        }

    }
}
