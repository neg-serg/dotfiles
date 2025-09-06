import QtQuick
import QtQuick.Window 2.15
import qs.Settings
import qs.Components
import "../Helpers/Utils.js" as Utils
import "../Helpers/Color.js" as Color

Window {
    id: tooltipWindow
    property string text: ""
    property bool tooltipVisible: false
    property Item targetItem: null
    property int delay: Theme.tooltipDelayMs
    property bool positionAbove: true

    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false

    property Timer _timer: Timer {
        interval: tooltipWindow.delay
        onTriggered: tooltipWindow.showNow()
    }

    property real minSize: Theme.tooltipMinSize * scaleFactor
    property real scaleFactor: Theme.scale ? Theme.scale(screen) : 1
    property real margin: Theme.tooltipMargin * scaleFactor
    property real padding: Theme.tooltipPadding * scaleFactor

    onTooltipVisibleChanged: {
        if (tooltipVisible) {
            if (delay > 0) {
                _timer.restart();
            } else {
                showNow();
            }
        } else {
            hideNow();
        }
    }

    function updateSize() {
        if (!tooltipText) return;

        var contentWidth = tooltipText.implicitWidth + 2 * padding;
        var contentHeight = tooltipText.implicitHeight + 2 * padding;
        width = Utils.clamp(contentWidth, minSize, contentWidth);
        height = Utils.clamp(contentHeight, minSize, contentHeight);
    }

    function showNow() {
        if (!targetItem || !targetItem.visible) {
            hideNow();
            return;
        }

        updateSize();
        var screenGeometry = getScreenGeometry();
        if (!screenGeometry) screenGeometry = getFallbackGeometry();

        var globalPos = targetItem.mapToGlobal(0, 0);
        var targetHeight = targetItem.height;

        var proposedY = globalPos.y - height - margin;
        var finalPositionAbove = true;

        if (proposedY < screenGeometry.y) {
            proposedY = globalPos.y + targetHeight + margin;
            finalPositionAbove = false;
        }

        // Horizontal centering
        var proposedX = globalPos.x + (targetItem.width - width) / 2;

        if (proposedX < screenGeometry.x) {
            proposedX = screenGeometry.x;
        } else if (proposedX + width > screenGeometry.x + screenGeometry.width) {
            proposedX = screenGeometry.x + screenGeometry.width - width;
        }

        if (finalPositionAbove) {
            proposedY = Utils.clamp(proposedY, screenGeometry.y, proposedY);
        } else {
            if (proposedY + height > screenGeometry.y + screenGeometry.height) {
                proposedY = globalPos.y - height - margin;
                finalPositionAbove = true;
                proposedY = Utils.clamp(proposedY, screenGeometry.y, proposedY);
            }
        }

        x = proposedX;
        y = proposedY;
        positionAbove = finalPositionAbove;
        visible = true;
    }

    function getScreenGeometry() {
        if (screen && screen.virtualGeometry) {
            return screen.virtualGeometry;
        }
        if (targetItem) {
            var parentWindow = targetItem.Window ? targetItem.Window.window : null;
            if (parentWindow && parentWindow.screen && parentWindow.screen.virtualGeometry) {
                return parentWindow.screen.virtualGeometry;
            }
            if (targetItem.screen && targetItem.screen.virtualGeometry) {
                return targetItem.screen.virtualGeometry;
            }
        }
        if (typeof Screen !== "undefined") {
            if (Screen.virtualGeometry) return Screen.virtualGeometry;
            if (Screen.desktopAvailableRect) return Screen.desktopAvailableRect;
            if (Screen.availableGeometry) return Screen.availableGeometry;
        }
        if (Qt.application && Qt.application.screens && Qt.application.screens.length > 0) {
            var primaryScreen = Qt.application.screens[0];
            if (primaryScreen.virtualGeometry) return primaryScreen.virtualGeometry;
            if (primaryScreen.desktopAvailableRect) return primaryScreen.desktopAvailableRect;
        }
        return null;
    }

    function getFallbackGeometry() {
        var globalPos = targetItem.mapToGlobal(0, 0);
        return Qt.rect(
            globalPos.x - 500,
            globalPos.y - 500,
            1000,  // width
            1000   // height
        );
    }

    function hideNow() {
        visible = false;
        _timer.stop();
    }

    Connections {
        target: tooltipWindow.targetItem
        ignoreUnknownSignals: true

        function onXChanged() { if (visible) showNow(); }
        function onYChanged() { if (visible) showNow(); }
        function onWidthChanged() { if (visible) showNow(); }
        function onHeightChanged() { if (visible) showNow(); }
        function onVisibleChanged() { if (!targetItem.visible) hideNow(); }
        function onDestroyed() {
            tooltipWindow.targetItem = null;
            tooltipWindow.tooltipVisible = false;
        }
    }

    Rectangle {
        id: tooltipBg
        anchors.fill: parent
        radius: Theme.tooltipRadius * scaleFactor
        color: Theme.surfaceActive
        border.color: Theme.borderSubtle
        border.width: Theme.tooltipBorderWidth * scaleFactor
        opacity: Theme.tooltipOpacity
        z: 1
    }

    ContrastGuard { id: ttContrast; bg: tooltipBg.color; label: 'Tooltip' }

    Text {
        id: tooltipText
        text: tooltipWindow.text
        color: ttContrast.fg
        font.family: Theme.fontFamily || "Arial"
        font.pixelSize: Theme.tooltipFontPx * scaleFactor
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        padding: padding
        z: 2
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: tooltipWindow.tooltipVisible = false
        cursorShape: Qt.ArrowCursor
    }

    // Update when text changes
    onTextChanged: {
        updateSize();
        if (visible) showNow();
    }

    onScreenChanged: if (visible) Qt.callLater(showNow)
}
