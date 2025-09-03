import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell
import qs.Components
import qs.Settings

Item {
    id: sidebarPopup
    // Reflect window visibility for external checks (buttons, etc.)
    visible: toast.visible

    // External offset (height of your bar/panel). New name:
    property int barMarginPx: 0
    // Backward-compat alias: keep two-way sync with old configs
    property int panelMarginPx: barMarginPx
    onPanelMarginPxChanged: if (panelMarginPx !== barMarginPx) barMarginPx = panelMarginPx
    onBarMarginPxChanged:   if (barMarginPx   !== panelMarginPx) panelMarginPx = barMarginPx

    // Anchor: panel/bar window for correct positioning relative to exclusive zones
    property var anchorWindow: null
    // Panel edge: "top" | "bottom" | "left" | "right"
    property string panelEdge: "bottom"

    // Public API
    function showAt()   { toast.showAt(); }
    function hidePopup(){ toast.hidePopup(); }

    PopupWindow {
        id: toast
        color: "transparent"
        visible: false

        // --- Sizing (scaled by per-screen factor)
        property real computedHeightPx: -1
        property real musicWidthPx: Settings.settings.musicPopupWidth * Theme.scale(Screen)
        property real musicHeightPx: (musicWidget && musicWidget.implicitHeight > 0)
                                     ? Math.round(musicWidget.implicitHeight)
                                     : Math.round(Settings.settings.musicPopupHeight * Theme.scale(Screen))
        property int  contentPaddingPx: Math.round(Settings.settings.musicPopupPadding * Theme.scale(Screen))

        width:  Math.round(musicWidthPx)
        height: Math.round((computedHeightPx >= 0) ? computedHeightPx : musicHeightPx)

        // --- Slide animation (animate inner content, not the window)
        property bool _hiding: false
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

        // --- Anchor to panel window for robust positioning
        anchor.window: sidebarPopup.anchorWindow
        Connections {
            // Recalculate anchor rect before each placement
            target: toast.anchor
            function onAnchoring() {
                const scale = Theme.scale(Screen);
                const outer = Math.round(4 * scale) + sidebarPopup.barMarginPx;

                // Align to the right edge of the panel window
                const px = sidebarPopup.anchorWindow
                         ? (sidebarPopup.anchorWindow.width - toast.width - outer)
                         : 0;

                // Vertical offset depending on panel edge
                var py;
                switch (String(sidebarPopup.panelEdge || "bottom").toLowerCase()) {
                case "top":
                    // Panel at top → popup below it
                    py = (sidebarPopup.anchorWindow ? sidebarPopup.anchorWindow.height : 0) + outer;
                    break;
                case "bottom":
                    // Panel at bottom → popup above it
                    py = -toast.height - outer;
                    break;
                case "left":
                    py = outer;
                    break;
                case "right":
                    py = outer;
                    break;
                default:
                    py = outer;
                }

                toast.anchor.rect.x = px;
                toast.anchor.rect.y = py;
            }
        }
        // Keep anchor in sync with panel window changes
        Connections {
            target: sidebarPopup.anchorWindow
            function onWidthChanged()  { toast.anchor.updateAnchor(); }
            function onHeightChanged() { toast.anchor.updateAnchor(); }
            function onXChanged()      { toast.anchor.updateAnchor(); }
            function onYChanged()      { toast.anchor.updateAnchor(); }
        }

        // --- Public control
        function showAt() {
            const scale = Theme.scale(Screen);
            if (computedHeightPx < 0) {
                var ih = (musicWidget && musicWidget.implicitHeight > 0)
                         ? musicWidget.implicitHeight
                         : (Settings.settings.musicPopupHeight * scale);
                const guardMax = Math.max(1, Math.round(Screen.height * 0.7));
                computedHeightPx = Math.round(Math.min(ih, guardMax));
            }

            if (!visible) {
                visible = true;
                slideX = toast.width; // start fully to the right
            }
            slide.stop();
            _hiding = false;
            slide.from = slideX;
            slide.to   = 0;
            slide.start();
        }

        function hidePopup() {
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
                    spacing: 8 * Theme.scale(Screen)
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
