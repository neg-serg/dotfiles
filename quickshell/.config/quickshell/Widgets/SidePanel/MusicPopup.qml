import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import qs.Components
import qs.Settings

Item {
    id: sidebarPopup

    // External offset (height of your bar/panel). New name:
    property int barMarginPx: 0
    // Backward-compat alias: keep two-way sync with old configs
    property int panelMarginPx: barMarginPx
    onPanelMarginPxChanged: if (panelMarginPx !== barMarginPx) barMarginPx = panelMarginPx
    onBarMarginPxChanged:   if (barMarginPx   !== panelMarginPx) panelMarginPx = barMarginPx

    // Public API
    function showAt()   { toast.showAt(); }
    function hidePopup(){ toast.hidePopup(); }

    Window {
        id: toast
        color: "transparent"
        visible: false
        flags: Qt.FramelessWindowHint
             | Qt.ToolTip
             | Qt.WindowStaysOnTopHint
             | Qt.WindowTransparentForInput

        // --- Sizing (scaled by per-screen factor)
        property real computedHeightPx: -1
        property real musicWidthPx: Settings.settings.musicPopupWidth
                                    * Theme.scale(toast.screen ? toast.screen : Screen)
        property real musicHeightPx: (musicWidget && musicWidget.implicitHeight > 0)
                                     ? Math.round(musicWidget.implicitHeight)
                                     : Math.round(Settings.settings.musicPopupHeight
                                                  * Theme.scale(toast.screen ? toast.screen : Screen))
        property int  contentPaddingPx: Math.round(Settings.settings.musicPopupPadding
                                                  * Theme.scale(toast.screen ? toast.screen : Screen))

        width:  Math.round(musicWidthPx)
        height: Math.round((computedHeightPx >= 0) ? computedHeightPx : musicHeightPx)

        // --- Position targets
        property int  targetX: 0
        property int  targetY: 0
        property int  offX: 0
        property bool _hiding: false

        // --- Slide animation (animate inner content, not the window)
        property real slideX: 0
        NumberAnimation {
            id: slide
            target: toast
            property: "slideX"
            duration: 220
            easing.type: Easing.InOutCubic
            onStopped: {
                if (toast._hiding) {
                    toast.visible = false;
                    toast._hiding = false;
                }
            }
        }

        // --- Workarea helpers
        function _availableRect() {
            // Prefer per-screen available geometry if compositor/WM exposes it
            var s = toast.screen;
            if (s && s.availableGeometry
                && s.availableGeometry.width  > 0
                && s.availableGeometry.height > 0) {
                return s.availableGeometry; // excludes panels/docks when supported
            }
            // Fallback to virtual desktop available area
            var aw = Screen.desktopAvailableWidth  || Screen.width;
            var ah = Screen.desktopAvailableHeight || Screen.height;
            var vx = Screen.virtualX || 0;
            var vy = Screen.virtualY || 0;
            return Qt.rect(vx, vy, aw, ah);
        }

        function _computePositions() {
            const ag = _availableRect();
            const scaleTarget = toast.screen ? toast.screen : Screen;
            const margin = Math.round(4 * Theme.scale(scaleTarget));

            // Right-top corner of available area
            targetX = Math.max(ag.x, ag.x + ag.width  - toast.width  - margin);
            targetY =          ag.y + sidebarPopup.barMarginPx + margin;

            // Fully off-screen to the right (for slide-out)
            offX = ag.x + ag.width + margin + toast.width;

            // Clamp height to available region (avoids covering the bar/panel)
            const maxH = Math.max(1, ag.height - (sidebarPopup.barMarginPx + 2 * margin));
            if (toast.computedHeightPx >= 0) {
                toast.computedHeightPx = Math.min(toast.computedHeightPx, maxH);
            }
        }

        // Keep positions updated on screen/workarea changes
        onScreenChanged: _computePositions()
        Component.onCompleted: _computePositions()
        Connections {
            target: toast.screen
            // Some scenes/compositors may not expose availableGeometryChanged;
            // suppress noisy warnings while still reacting when present.
            ignoreUnknownSignals: true
            function onAvailableGeometryChanged() {
                toast._computePositions();
                if (toast.visible && !toast._hiding) {
                    toast.x = toast.targetX;
                    toast.y = toast.targetY;
                }
            }
        }

        // --- Public control
        function showAt() {
            const ag = _availableRect();
            const scaleTarget = toast.screen ? toast.screen : Screen;
            const margin = Math.round(4 * Theme.scale(scaleTarget));

            if (computedHeightPx < 0) {
                var ih = (musicWidget && musicWidget.implicitHeight > 0)
                         ? musicWidget.implicitHeight
                         : (Settings.settings.musicPopupHeight * Theme.scale(scaleTarget));
                const maxH = Math.max(1, ag.height - (sidebarPopup.barMarginPx + 2 * margin));
                computedHeightPx = Math.round(Math.min(ih, maxH));
            }

            _computePositions();
            y = targetY;   // move the WINDOW vertically (prevents clipping)
            x = targetX;

            if (!visible) {
                visible = true;
                slideX = toast.width; // start off-screen to the right
            }
            slide.stop();
            _hiding = false;
            slide.from = slideX;
            slide.to   = 0;
            slide.start();
        }

        function hidePopup() {
            _computePositions();
            slide.stop();
            _hiding = true;
            slide.from = slideX;
            slide.to   = toast.width;
            slide.start();
        }

        // --- Content
        Item {
            anchors.fill: parent
            // Horizontal slide only; window position handles vertical offset
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
                        width:  toast.musicWidthPx
                        height: toast.musicHeightPx
                    }
                }
            }
        }
    }
}
