import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import qs.Components
import qs.Settings

Item {
    id: sidebarPopup
    // external offset from bar height
    property int panelMarginPx: 0
    // keep external API
    function showAt() { toast.showAt(); }
    function hidePopup() { toast.hidePopup(); }

    Window {
        id: toast
        color: "transparent"
        visible: false
        flags: Qt.FramelessWindowHint | Qt.ToolTip | Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput

        // Sizing similar to previous layer popup
        property real computedHeightPx: -1
        property real musicWidthPx: 840 * Theme.scale(screen)
        property real musicHeightPx: (musicWidget && musicWidget.implicitHeight > 0)
                                     ? Math.round(musicWidget.implicitHeight)
                                     : Math.round(250 * Theme.scale(screen))
        width: Math.round(musicWidthPx)
        height: Math.round(((computedHeightPx >= 0) ? computedHeightPx : musicHeightPx))

        // Target/offscreen positions
        property int targetX: 0
        property int targetY: 0
        property int offX: 0
        property bool _hiding: false

        function _computePositions() {
            const scr = toast.screen ? toast.screen : Screen;
            const g = scr && scr.geometry ? scr.geometry : Qt.rect(0, 0, Screen.width, Screen.height);
            const margin = Math.round(4 * Theme.scale(screen));
            targetX = Math.max(g.x, g.x + g.width - toast.width - margin);
            targetY = Math.max(g.y, g.y + g.height - toast.height - sidebarPopup.panelMarginPx - margin);
            offX = g.x + g.width + margin + toast.width; // fully off to the right
        }

        // Programmatic slide animation (animate inner content, not window position)
        property real slideX: 0
        NumberAnimation { id: slide; target: toast; property: "slideX"; duration: 220; easing.type: Easing.InOutCubic
            onStopped: { if (toast._hiding) { toast.visible = false; toast._hiding = false; } }
        }

        function showAt() {
            if (computedHeightPx < 0) {
                var ih = (musicWidget && musicWidget.implicitHeight > 0) ? musicWidget.implicitHeight : (250 * Theme.scale(screen));
                computedHeightPx = Math.round(ih);
            }
            _computePositions();
            y = targetY;
            if (!visible) {
                visible = true;
                slideX = toast.width; // start off-screen to the right
            }
            slide.stop();
            _hiding = false;
            slide.from = slideX;
            slide.to = 0;
            slide.start();
        }

        function hidePopup() {
            _computePositions();
            slide.stop();
            _hiding = true;
            slide.from = slideX;
            slide.to = toast.width;
            slide.start();
        }

        // Content (includes cover)
        Item {
            anchors.fill: parent
            transform: Translate { x: toast.slideX }
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                RowLayout {
                    spacing: 8 * Theme.scale(screen)
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter
                    Music {
                        id: musicWidget
                        width: toast.musicWidthPx
                        height: toast.musicHeightPx
                    }
                }
            }
        }
    }
}
