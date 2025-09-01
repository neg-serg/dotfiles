import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Components
import qs.Settings

PanelWithOverlay {
    id: sidebarPopup
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
        property bool isAnimating: false
        // Minimal margins around content
        property int leftPadding: 4 * Theme.scale(screen)
        property int bottomPadding: 4 * Theme.scale(screen)
        function showAt() {
            if (!sidebarPopup.visible) {
                sidebarPopup.visible = true;
                forceActiveFocus();
                slideAnim.from = width;
                slideAnim.to = 0;
                slideAnim.running = true;
            }
        }

        function hidePopup() {
            if (sidebarPopup.visible) {
                slideAnim.from = 0;
                slideAnim.to = width;
                slideAnim.running = true;
            }
        }

        // Size panel close to music module size (compact, no excess space)
        property real musicWidthPx: 420 * Theme.scale(screen)
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

        Rectangle {
            id: mainRectangle
            // anchors.top: sidebarPopupRect.top
            width: sidebarPopupRect.width - sidebarPopupRect.leftPadding
            height: sidebarPopupRect.height - sidebarPopupRect.bottomPadding
            x: sidebarPopupRect.leftPadding + sidebarPopupRect.slideOffset
            y: 0
            // Panel backdrop: very transparent black
            color: Qt.rgba(0, 0, 0, 0.10)
            bottomLeftRadius: 20
            Behavior on x {
                enabled: !sidebarPopupRect.isAnimating
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }

            }

        }

        // Content layer
        Item {
            anchors.fill: mainRectangle
            z: 1
            x: sidebarPopupRect.slideOffset
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
                        width: sidebarPopupRect.musicWidthPx
                        height: sidebarPopupRect.musicHeightPx
                    }
                }

                // small spacer
                Rectangle { height: 4 * Theme.scale(screen); color: "transparent" }

            }

            Behavior on x {
                enabled: !sidebarPopupRect.isAnimating
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
        }

    }
}
