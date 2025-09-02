import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Components
import qs.Settings

PanelWithOverlay {
    id: sidebarPopup
    // Do not dim background for music popup
    showOverlay: false
    // Stick to panel edges without overlay margins
    topMargin: 0
    bottomMargin: 0
    // Bottom offset equal to bar height (bound by parent on instantiation)
    property int panelMarginPx: 0
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
        property bool isAnimating: false
        // Freeze height on first show to avoid drift as content settles
        property real computedHeightPx: -1
        // No extra margins: stick to the panel edges
        property int leftPadding: 0
        property int bottomPadding: 0
        function showAt() {
            if (!sidebarPopup.visible) {
                if (computedHeightPx < 0) {
                    var ih = (musicWidget && musicWidget.implicitHeight > 0) ? musicWidget.implicitHeight : (250 * Theme.scale(screen));
                    computedHeightPx = Math.round(ih);
                }
                sidebarPopup.visible = true;
                forceActiveFocus();
            }
        }

        function hidePopup() { if (sidebarPopup.visible) sidebarPopup.visible = false }

        // Double width; height follows the music widget's implicit size (with safe minimum)
        property real musicWidthPx: 840 * Theme.scale(screen)
        property real musicHeightPx: (musicWidget && musicWidget.implicitHeight > 0)
                                     ? Math.round(musicWidget.implicitHeight)
                                     : Math.round(250 * Theme.scale(screen))
        width: Math.round(musicWidthPx + leftPadding)
        height: Math.round(((computedHeightPx >= 0) ? computedHeightPx : musicHeightPx) + bottomPadding)
        visible: parent.visible
        color: "transparent"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        MouseArea { anchors.fill: parent; } // Prevent closing when clicking in the panel bg

        Rectangle {
            id: mainRectangle
            width: sidebarPopupRect.width - sidebarPopupRect.leftPadding
            height: sidebarPopupRect.height - sidebarPopupRect.bottomPadding
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 4 * Theme.scale(screen)
            anchors.bottomMargin: sidebarPopup.panelMarginPx
            // Panel backdrop: very transparent black
            color: "transparent"
            bottomLeftRadius: 0
            // No animation behaviors

        }

        // Content layer
        Item {
            anchors.fill: mainRectangle
            z: 1
            Keys.onEscapePressed: sidebarPopupRect.hidePopup()
            ColumnLayout {
                id: contentCol
                anchors.fill: parent
                spacing: 0
                // Weather widget removed from this panel; available via WeatherButton popup

                RowLayout { // Music only
                    spacing: 8 * Theme.scale(screen)
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter
                    Music {
                        id: musicWidget
                        width: sidebarPopupRect.musicWidthPx
                        height: sidebarPopupRect.musicHeightPx
                    }
                }

            }

            // No animation behaviors
        }

    }
}
