import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell
import qs.Components
import qs.Settings
import "../../Helpers/Utils.js" as Utils

Item {
    id: sidebarPopup
    // Reflect window visibility for external checks (buttons, etc.)
    visible: toast.visible

    // External offset (height of your bar/panel). New name:
    property int barMarginPx: 0
    // Backward-compat alias: keep two-way sync with old configs
    property int panelMarginPx: barMarginPx
    onPanelMarginPxChanged: if (panelMarginPx !== barMarginPx) barMarginPx = panelMarginPx
    onBarMarginPxChanged: if (barMarginPx   !== panelMarginPx) panelMarginPx = barMarginPx

    // Anchor: panel/bar window for correct positioning relative to exclusive zones
    property var anchorWindow: null
    // Panel edge: "top" | "bottom" | "left" | "right"
    property string panelEdge: "bottom"

    // Public API
    function showAt()   { toast.showAt(); }
    function hidePopup(){ toast.hidePopup(); }

    PopupWindow {
        id: toast
        // We draw our own rounded background
        color: "transparent"
        visible: false

        // --- Auto-hide with pause on hover/focus and while cursor is on panel
        property int autoHideTotalMs: Theme.sidePanelPopupAutoHideMs
        property int _autoHideRemainingMs: autoHideTotalMs
        property double _autoHideStartedAtMs: 0
        Timer {
            id: autoHideTimer
            interval: toast._autoHideRemainingMs
            repeat: false
            onTriggered: {
                if (!toast._hiding && toast.visible) {
                    // Do not hide if cursor is currently on the panel
                    if (!(sidebarPopup.anchorWindow && sidebarPopup.anchorWindow.panelHovering === true)) {
                        toast.hidePopup();
                    } else {
                        // Stay armed to resume when cursor leaves the panel
                        toast.pauseAutoHide();
                    }
                }
            }
        }
        function startAutoHide(ms) {
            toast._autoHideRemainingMs = (ms !== undefined && ms !== null) ? ms : toast.autoHideTotalMs;
            toast._autoHideStartedAtMs = Date.now();
            autoHideTimer.interval = toast._autoHideRemainingMs;
            autoHideTimer.restart();
        }
            function pauseAutoHide() {
                if (!autoHideTimer.running) return;
            const elapsed = Utils.clamp(Date.now() - toast._autoHideStartedAtMs, 0, 3600000);
            toast._autoHideRemainingMs = Utils.clamp(toast._autoHideRemainingMs - elapsed, 0, 3600000);
                autoHideTimer.stop();
            }
        function resumeAutoHide() {
            if (toast._autoHideRemainingMs <= 0) { toast.hidePopup(); return; }
            toast._autoHideStartedAtMs = Date.now();
            autoHideTimer.interval = toast._autoHideRemainingMs;
            autoHideTimer.restart();
        }
        function cancelAutoHide() {
            autoHideTimer.stop();
            toast._autoHideRemainingMs = toast.autoHideTotalMs;
        }
        onVisibleChanged: {
            if (visible) {
                toast.startAutoHide();
                if (sidebarPopup.anchorWindow && sidebarPopup.anchorWindow.panelHovering === true) {
                    toast.pauseAutoHide();
                }
            } else {
                toast.cancelAutoHide();
            }
        }

        // --- Sizing (scaled by per-screen factor)
        property real computedHeightPx: -1
        property real musicWidthPx: Settings.settings.musicPopupWidth * Theme.scale(Screen)
        property real musicHeightPx: (musicWidget && musicWidget.implicitHeight > 0)
                                     ? Math.round(musicWidget.implicitHeight)
                                     : Math.round(Settings.settings.musicPopupHeight * Theme.scale(Screen))
        property int contentPaddingPx:Math.round(Settings.settings.musicPopupPadding * Theme.scale(Screen))

        implicitWidth: Math.round(musicWidthPx)
        implicitHeight: Math.round((computedHeightPx >= 0) ? computedHeightPx : musicHeightPx)

        // --- Slide animation (animate inner content, not the window)
        property bool _hiding: false
        property real slideX: 0
        NumberFadeBehavior {
            id: slide
            target: toast
            property: "slideX"
            duration: Theme.sidePanelPopupSlideMs
            easing.type: Theme.uiEasingRipple
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
                const outer = Math.round(Theme.sidePanelPopupOuterMargin * scale) + sidebarPopup.barMarginPx;

                // Align to the right edge of the panel window
                const px = sidebarPopup.anchorWindow
                         ? (sidebarPopup.anchorWindow.width - toast.implicitWidth - outer)
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
                    py = -toast.implicitHeight - outer;
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
            ignoreUnknownSignals: true
            function onWidthChanged()  { toast.anchor.updateAnchor(); }
            function onHeightChanged() { toast.anchor.updateAnchor(); }
            function onPanelHoveringChanged() {
                if (!sidebarPopup.anchorWindow) return;
                if (sidebarPopup.anchorWindow.panelHovering) toast.pauseAutoHide();
                else toast.resumeAutoHide();
            }
        }

        // --- Public control
        function showAt() {
            const scale = Theme.scale(Screen);
            if (computedHeightPx < 0) {
                var ih = (musicWidget && musicWidget.implicitHeight > 0)
                         ? musicWidget.implicitHeight
                         : (Settings.settings.musicPopupHeight * scale);
                const guardMax = Utils.clamp(Math.round(Screen.height * 0.7), 1, Screen.height);
                computedHeightPx = Utils.clamp(Math.round(ih), 1, guardMax);
            }

            if (!visible) {
                visible = true;
                slideX = toast.implicitWidth; // start fully to the right
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
            slide.to   = toast.implicitWidth;
            slide.start();
        }

        // --- Content
        // Slide container for both background and content
        Item {
            id: contentRoot
            anchors.fill: parent
            transform: Translate { x: toast.slideX }

            // Rounded background with theme-controlled radius
            Rectangle {
                anchors.fill: parent
                radius: Theme.sidePanelPopupRadius
                color: Theme.overlayStrong
            }

            FocusScope {
                anchors.fill: parent

            // Pause auto-hide while pointer is over popup; resume on exit
            HoverHandler {
                id: hover
                onActiveChanged: {
                    if (active) toast.pauseAutoHide();
                    else toast.resumeAutoHide();
                }
            }

            // Pause while any descendant within this scope has active focus (keyboard interaction)
            onActiveFocusChanged: {
                if (activeFocus) toast.pauseAutoHide();
                else toast.resumeAutoHide();
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: toast.contentPaddingPx
                spacing: Theme.sidePanelPopupSpacing

                RowLayout {
                    spacing: Math.round(Theme.sidePanelSpacingMedium * Theme.scale(Screen))
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
}
