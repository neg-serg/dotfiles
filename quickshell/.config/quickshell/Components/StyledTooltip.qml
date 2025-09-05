import QtQuick
import QtQuick.Window 2.15
import qs.Settings
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

    // Static timer instance
    property Timer _timer: Timer {
        interval: tooltipWindow.delay
        onTriggered: tooltipWindow.showNow()
    }

    // Scaling parameters with safe fallbacks
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

    // Unified size calculation
    function updateSize() {
        if (!tooltipText) return;

        var contentWidth = tooltipText.implicitWidth + 2 * padding;
        var contentHeight = tooltipText.implicitHeight + 2 * padding;
        width = Utils.clamp(contentWidth, minSize, contentWidth);
        height = Utils.clamp(contentHeight, minSize, contentHeight);
    }

    function showNow() {
        // Validate target before showing
        if (!targetItem || !targetItem.visible) {
            hideNow();
            return;
        }

        updateSize();

        // Get safe screen geometry
        var screenGeometry = getScreenGeometry();
        if (!screenGeometry) {
            // Use target item's position as fallback
            screenGeometry = getFallbackGeometry();
        }

        var globalPos = targetItem.mapToGlobal(0, 0);
        var targetHeight = targetItem.height;

        // Default: position above target
        var proposedY = globalPos.y - height - margin;
        var finalPositionAbove = true;

        // Check if enough space above target
        if (proposedY < screenGeometry.y) {
            // Not enough space above - position below
            proposedY = globalPos.y + targetHeight + margin;
            finalPositionAbove = false;
        }

        // Horizontal centering
        var proposedX = globalPos.x + (targetItem.width - width) / 2;

        // Horizontal boundary correction
        if (proposedX < screenGeometry.x) {
            proposedX = screenGeometry.x;
        } else if (proposedX + width > screenGeometry.x + screenGeometry.width) {
            proposedX = screenGeometry.x + screenGeometry.width - width;
        }

        // Vertical boundary correction
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

    // Safe screen geometry determination with multiple fallbacks
    function getScreenGeometry() {
        // 1. Try tooltip's own screen
        if (screen && screen.virtualGeometry) {
            return screen.virtualGeometry;
        }

        // 2. Try target item's containing window
        if (targetItem) {
            var parentWindow = targetItem.Window ? targetItem.Window.window : null;
            if (parentWindow && parentWindow.screen && parentWindow.screen.virtualGeometry) {
                return parentWindow.screen.virtualGeometry;
            }

            // 3. Try target item's screen property
            if (targetItem.screen && targetItem.screen.virtualGeometry) {
                return targetItem.screen.virtualGeometry;
            }
        }

        // 4. Try global Screen object
        if (typeof Screen !== "undefined") {
            if (Screen.virtualGeometry) return Screen.virtualGeometry;
            if (Screen.desktopAvailableRect) return Screen.desktopAvailableRect;
            if (Screen.availableGeometry) return Screen.availableGeometry;
        }

        // 5. Try application screens
        if (Qt.application && Qt.application.screens && Qt.application.screens.length > 0) {
            var primaryScreen = Qt.application.screens[0];
            if (primaryScreen.virtualGeometry) return primaryScreen.virtualGeometry;
            if (primaryScreen.desktopAvailableRect) return primaryScreen.desktopAvailableRect;
        }

        // Fallback silently; geometry will be synthesized from target position
        return null;
    }

    // Fallback geometry when screen can't be detected
    function getFallbackGeometry() {
        // Try to get position from target item
        var globalPos = targetItem.mapToGlobal(0, 0);

        // Create safe fallback rectangle
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

    // Handle target item changes
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

    // Tooltip background (use derived tokens)
    Rectangle {
        id: tooltipBg
        anchors.fill: parent
        radius: Theme.tooltipRadius * scaleFactor
        color: Theme.surfaceActive
        border.color: Theme.borderSubtle
        border.width: Theme.tooltipBorderWidth * scaleFactor
        opacity: 0.98
        z: 1
    }

    // Tooltip text content
    Text {
        id: tooltipText
        text: tooltipWindow.text
        color: Color.contrastOn(tooltipBg.color, Theme.textPrimary, Theme.textSecondary, (Settings.settings && Settings.settings.contrastThreshold) ? Settings.settings.contrastThreshold : 0.5)
        font.family: Theme.fontFamily || "Arial"
        font.pixelSize: Theme.tooltipFontPx * scaleFactor
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        padding: padding
        z: 2
    }

    // Mouse area for hover interactions
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

    // Handle screen changes
    onScreenChanged: if (visible) Qt.callLater(showNow)
}
