import QtQuick
import qs.Settings
import qs.Components
import qs.Bar.Modules

Item {
    id: volumeDisplay
    property var shell
    property int volume: 0
    property bool firstChange: true
    visible: false
    // Pleasant endpoint colors: raspberry (low) -> spruce green (high)
    // You can tweak these to your taste
    property color volLowColor: "#D62E6E"   // raspberry
    property color volHighColor: "#0E6B4D"  // spruce green
    // Stub ioSelector to avoid reference errors if advanced UI isn't present
    Item {
        id: ioSelector
        visible: false
        function show() { visible = true }
        function dismiss() { visible = false }
    }

    // Collapse size when hidden so it doesn't leave a gap
    width: visible ? pillIndicator.width : 0
    height: visible ? pillIndicator.height : 0

    // Hide the pill after ~800ms when volume sits exactly at 100%
    Timer {
        id: fullHideTimer
        interval: 800
        repeat: false
        onTriggered: {
            if (volumeDisplay.volume === 100) {
                // Hide the entire volume icon when exactly at 100%
                volumeDisplay.visible = false;
            }
        }
    }

    function getVolumeColor() {
        // Gradient from volLowColor at 0% to volHighColor at 100% (clamped)
        var t = Math.max(0, Math.min(1, volume / 100.0));
        return Qt.rgba(
            volLowColor.r + (volHighColor.r - volLowColor.r) * t,
            volLowColor.g + (volHighColor.g - volLowColor.g) * t,
            volLowColor.b + (volHighColor.b - volLowColor.b) * t,
            1
        );
    }

    function getIconColor() {
        // Use the same gradient for the collapsed icon as well
        return getVolumeColor();
    }

    PillIndicator {
        id: pillIndicator
        icon: shell && shell.defaultAudioSink && shell.defaultAudioSink.audio && shell.defaultAudioSink.audio.muted
            ? "volume_off"
            : (volume === 0 ? "volume_off" : (volume < 30 ? "volume_down" : "volume_up"))
        text: volume + "%"

        // Black pill background as requested
        pillColor: "#000000"
        iconCircleColor: getVolumeColor()
        iconTextColor: Theme.backgroundPrimary
        textColor: Theme.textPrimary
        collapsedIconColor: getIconColor()
        autoHide: true

        StyledTooltip {
            id: volumeTooltip
            text: "Volume: " + volume + "%\nLeft click for advanced settings.\nScroll up/down to change volume."
            positionAbove: false
            tooltipVisible: !ioSelector.visible && volumeDisplay.containsMouse
            targetItem: pillIndicator
            delay: 1500
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (ioSelector.visible) {
                    ioSelector.dismiss();
                } else {
                    ioSelector.show();
                }
            }
        }
    }

    Connections {
        target: shell ?? null
        function onVolumeChanged() {
            if (shell) {
                const clampedVolume = Math.max(0, Math.min(200, shell.volume));
                if (clampedVolume !== volume) {
                    volume = clampedVolume;
                    // Ensure module is visible on any change
                    if (!volumeDisplay.visible) volumeDisplay.visible = true;
                    pillIndicator.text = volume + "%";
                    pillIndicator.icon = shell.defaultAudioSink && shell.defaultAudioSink.audio && shell.defaultAudioSink.audio.muted
                        ? "volume_off"
                        : (volume === 0 ? "volume_off" : (volume < 30 ? "volume_down" : "volume_up"));

                    if (firstChange) {
                        firstChange = false
                    }
                    else {
                        pillIndicator.show();
                        // Handle auto-hide at exactly 100%
                        if (volume === 100) {
                            fullHideTimer.restart();
                        } else if (fullHideTimer.running) {
                            fullHideTimer.stop();
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (shell && shell.volume !== undefined) {
            volume = Math.max(0, Math.min(200, shell.volume));
            // If we start at exactly 100%, schedule auto-hide by default
            if (volume === 100) fullHideTimer.restart();
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        onEntered: {
            volumeDisplay.containsMouse = true
            pillIndicator.autoHide = false;
            pillIndicator.showDelayed()
        }
        onExited: {
            volumeDisplay.containsMouse = false
            pillIndicator.autoHide = true;
            pillIndicator.hide()
        }
        cursorShape: Qt.PointingHandCursor
        onWheel: (wheel) => {
            if (!shell) return;
            let step = 5;
            if (wheel.angleDelta.y > 0) {
                shell.updateVolume(Math.min(200, shell.volume + step));
            } else if (wheel.angleDelta.y < 0) {
                shell.updateVolume(Math.max(0, shell.volume - step));
            }
        }
    }
    property bool containsMouse: false
}
