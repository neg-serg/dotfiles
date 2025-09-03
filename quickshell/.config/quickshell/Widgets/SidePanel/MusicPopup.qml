import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import qs.Components
import qs.Settings

Item {
    id: sidebarPopup
    // External offset from bar height (renamed)
    // New name
    property int barMarginPx: 0
    // Backwards-compat alias (kept temporarily)
    // Keeps two-way sync to support old configs assigning panelMarginPx
    property int panelMarginPx: barMarginPx
    onPanelMarginPxChanged: { if (panelMarginPx !== barMarginPx) barMarginPx = panelMarginPx }
    onBarMarginPxChanged: { if (barMarginPx !== panelMarginPx) panelMarginPx = barMarginPx }
    // Public API for toggling
    function showAt() { toast.showAt(); }
    function hidePopup() { toast.hidePopup(); }

    Window {
        id: toast
        color: "transparent"
        visible: false
        flags: Qt.FramelessWindowHint | Qt.ToolTip | Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput

        // Horizontal position is computed to align at right edge

        // Sizing for the music popup container (configurable via Settings)
        property real computedHeightPx: -1
        // Logical base values from Settings, scaled per-screen
        property real musicWidthPx: Settings.settings.musicPopupWidth * Theme.scale(toast.screen ? toast.screen : Screen)
        property real musicHeightPx: (musicWidget && musicWidget.implicitHeight > 0)
                                     ? Math.round(musicWidget.implicitHeight)
                                     : Math.round(Settings.settings.musicPopupHeight * Theme.scale(toast.screen ? toast.screen : Screen))
        // Inner padding around content
        property int contentPaddingPx: Math.round(Settings.settings.musicPopupPadding * Theme.scale(toast.screen ? toast.screen : Screen))
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
            const margin = Math.round(4 * Theme.scale(toast.screen ? toast.screen : Screen));
            targetX = Math.max(g.x, g.x + g.width - toast.width - margin);
            // Shift higher: subtract 8x the bar height instead of 1x
            targetY = 0;
            offX = g.x + g.width + margin + toast.width; // fully off to the right
        }

        // Programmatic slide animation (animate inner content, not window position)
        property real slideX: 0
        NumberAnimation { id: slide; target: toast; property: "slideX"; duration: 220; easing.type: Easing.InOutCubic
            onStopped: { if (toast._hiding) { toast.visible = false; toast._hiding = false; } }
        }

        function showAt() {
            if (computedHeightPx < 0) {
                var ih = (musicWidget && musicWidget.implicitHeight > 0)
                    ? musicWidget.implicitHeight
                    : (Settings.settings.musicPopupHeight * Theme.scale(toast.screen ? toast.screen : Screen));
                computedHeightPx = Math.round(ih);
            }
            _computePositions();
            y = targetY;
            // Align popup with the right edge of the screen
            x = targetX;
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

        // Content (music widget)
        Item {
            anchors.fill: parent
            transform: Translate { x: toast.slideX }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: toast.contentPaddingPx
                spacing: 0
                RowLayout {
                    spacing: 8 * Theme.scale(toast.screen ? toast.screen : Screen)
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
