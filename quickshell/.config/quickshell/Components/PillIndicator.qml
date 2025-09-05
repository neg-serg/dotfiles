import QtQuick
import QtQuick.Controls
import qs.Settings
import "../Helpers/Utils.js" as Utils

Item {
    id: revealPill

    // External properties
    property string icon: ""
    property string text: ""
    property color pillColor: Theme.surfaceVariant
    property color textColor: Theme.textPrimary
    property color iconCircleColor: Theme.accentPrimary
    property color iconTextColor: Theme.backgroundPrimary
    property color collapsedIconColor: Theme.textPrimary
    property int pillHeight: Math.round(Theme.panelPillHeight * Theme.scale(Screen))
    property int iconSize: Math.round(Theme.panelPillIconSize * Theme.scale(Screen))
    property int pillPaddingHorizontal: Theme.panelPillPaddingH
    property bool autoHide: false

    // Internal state
    property bool showPill: false
    property bool shouldAnimateHide: false

    // Exposed width logic
    readonly property int pillOverlap: iconSize / 2
    readonly property int maxPillWidth: Utils.clamp(textItem.implicitWidth + pillPaddingHorizontal * 2 + pillOverlap, 1, textItem.implicitWidth + pillPaddingHorizontal * 2 + pillOverlap)

    signal shown
    signal hidden

    width: iconSize + (showPill ? maxPillWidth - pillOverlap : 0)
    height: pillHeight

    Rectangle {
        id: pill
        width: showPill ? maxPillWidth : 1
        height: pillHeight
        x: (iconCircle.x + iconCircle.width / 2) - width
        opacity: showPill ? 1 : 0
        color: pillColor
        // Halve the rounding of the pill corners
        topLeftRadius: pillHeight / 4
        bottomLeftRadius: pillHeight / 4
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: textItem
            anchors.centerIn: parent
            text: revealPill.text
            font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
            font.family: Theme.fontFamily
            font.weight: Font.Bold
            color: textColor
            visible: showPill
        }

        Behavior on width {
            enabled: showAnim.running || hideAnim.running
            NumberAnimation { duration: Theme.panelAnimStdMs; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            enabled: showAnim.running || hideAnim.running
            NumberAnimation { duration: Theme.panelAnimStdMs; easing.type: Easing.OutCubic }
        }
    }

    Rectangle {
        id: iconCircle
        width: iconSize
        height: iconSize
        radius: width / 2
        color: showPill ? iconCircleColor : "transparent"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right

        Behavior on color {
            ColorAnimation { duration: Theme.panelAnimFastMs; easing.type: Easing.InOutQuad }
        }

        MaterialIcon {
            anchors.centerIn: parent
            rounded: showPill
            size: Theme.fontSizeSmall * Theme.scale(Screen)
            icon: revealPill.icon
            color: showPill ? iconTextColor : collapsedIconColor
        }
    }

    ParallelAnimation {
        id: showAnim
        running: false
        NumberAnimation { target: pill; property: "width";   from: 1;            to: maxPillWidth; duration: Theme.panelAnimStdMs; easing.type: Easing.OutCubic }
        NumberAnimation { target: pill; property: "opacity"; from: 0;            to: 1;            duration: Theme.panelAnimStdMs; easing.type: Easing.OutCubic }
        onStarted: {
            showPill = true;
        }
        onStopped: {
            delayedHideAnim.start();
            shown();
        }
    }

    SequentialAnimation {
        id: delayedHideAnim
        running: false
        PauseAnimation { duration: Theme.panelPillAutoHidePauseMs }
        ScriptAction {
            script: if (shouldAnimateHide)
                hideAnim.start()
        }
    }

    ParallelAnimation {
        id: hideAnim
        running: false
        NumberAnimation { target: pill; property: "width";   from: maxPillWidth; to: 1; duration: Theme.panelAnimStdMs; easing.type: Easing.InCubic }
        NumberAnimation { target: pill; property: "opacity"; from: 1;            to: 0; duration: Theme.panelAnimStdMs; easing.type: Easing.InCubic }
        onStopped: {
            showPill = false;
            shouldAnimateHide = false;
            hidden();
        }
    }

    function show() {
        if (!showPill) {
            shouldAnimateHide = autoHide;
            showAnim.start();
        } else {
            hideAnim.stop();
            delayedHideAnim.restart();
        }
    }

    function hide() {
        if (showPill) {
            hideAnim.start();
        }
        showTimer.stop();
    }

    function showDelayed() {
        if (!showPill) {
            shouldAnimateHide = autoHide;
            showTimer.start();
        } else {
            hideAnim.stop();
            delayedHideAnim.restart();
        }
    }

    Timer {
        id: showTimer
        interval: Theme.panelPillShowDelayMs
        onTriggered: {
            if (!showPill) {
                showAnim.start();
            }
        }
    }
}
