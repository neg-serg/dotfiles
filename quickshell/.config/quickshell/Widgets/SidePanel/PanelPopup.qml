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
    // Exposed from Bar: whether cursor is over the bar panel
    property bool barHover: false
    // Track last global pointer move timestamp while popup is visible
    property real lastMoveTs: 0
    // Avoid any top/bottom margin shifts from global panel position to prevent initial jump
    topMargin: 0
    bottomMargin: 0
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
                // Show immediately in final horizontal position (no vertical animation)
                slideOffset = 0;
                sidebarPopup.visible = true;
                forceActiveFocus();
                sidebarPopup.lastMoveTs = Date.now();
            }
        }

        function hidePopup() {
            if (sidebarPopup.visible) {
                slideAnim.from = slideOffset;
                slideAnim.to = width;
                slideAnim.running = true;
            }
        }

        // Use fixed size (like calendar) to avoid reflow that can shift content
        property real musicWidthPx: 420 * Theme.scale(screen)
        property real musicHeightPx: 380 * Theme.scale(screen)
        width: Math.round(musicWidthPx + leftPadding)
        height: Math.round(musicHeightPx + bottomPadding)
        visible: parent.visible
        color: "transparent"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        // Global hover tracker over the entire overlay to detect pointer idleness
        MouseArea {
            id: overlayHover
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: true
            z: 100000
            onPositionChanged: sidebarPopup.lastMoveTs = Date.now()
        }
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

        // No vertical show animation; only horizontal slide used on hide

        Rectangle {
            id: mainRectangle
            // anchors.top: sidebarPopupRect.top
            width: sidebarPopupRect.width - sidebarPopupRect.leftPadding
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
            // Fixed full height; anchored to bottom for stable appearance
            height: sidebarPopupRect.height - sidebarPopupRect.bottomPadding

        }

        // Content layer
        Item {
            anchors.fill: mainRectangle
            z: 1
            // Fixed inside the sliding container
            x: 0
            Keys.onEscapePressed: sidebarPopupRect.hidePopup()
            // Detect hover over the popup content to avoid auto-close while interacting
            MouseArea {
                id: panelHoverArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                propagateComposedEvents: true
                z: -1
            }
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
            }
            
            // No extra animation hooks inside this content layer

        // Auto-close when cursor is outside bar and popup, and idle for 0.5s
        Timer {
            id: autoCloseTimer
            interval: 500
            repeat: true
            running: sidebarPopup.visible
            onTriggered: {
                if (!sidebarPopup.visible || sidebarPopupRect.isAnimating) return;
                if (sidebarPopup.barHover) return;
                if (panelHoverArea.containsMouse) return;
                if (Date.now() - sidebarPopup.lastMoveTs >= 500) sidebarPopupRect.hidePopup();
            }
        }

    }
}
