import QtQuick
import QtQuick.Layouts
import qs.Settings
import qs.Components
import qs.Bar.Modules
import qs.Services as Services
import "../../Helpers/Utils.js" as Utils

Item {
    id: volumeDisplay
    property int volume: 0
    property bool firstChange: true
    // Track last non-muted icon category to add hysteresis between thresholds
    // Values: 'off' | 'down' | 'up'
    property string lastVolIconCategory: 'up'
    visible: false
    // Pleasant endpoint colors from Theme
    property color volLowColor: Theme.panelVolumeLowColor
    property color volHighColor: Theme.panelVolumeHighColor
    // Stub ioSelector to avoid reference errors if advanced UI isn't present
    Item {
        id: ioSelector
        visible: false
        function show() { visible = true }
        function dismiss() { visible = false }
    }

    // Collapse size when hidden so it doesn't leave a gap
    // RowLayout relies on implicit sizes, so override them too
    width: visible ? pillIndicator.width : 0
    height: visible ? pillIndicator.height : 0
    implicitWidth: visible ? pillIndicator.width : 0
    implicitHeight: visible ? pillIndicator.height : 0
    // Hint RowLayout to use these collapsed sizes
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.maximumWidth: implicitWidth
    Layout.maximumHeight: implicitHeight

    // Hide the pill after ~800ms when volume sits exactly at 100%
    Timer {
        id: fullHideTimer
        interval: Theme.panelVolumeFullHideMs
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
        var t = Utils.clamp(volume / 100.0, 0, 1);
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

    function resolveIconCategory(vol, muted) {
        if (muted) return 'off';
        if (vol <= Theme.volumeIconOffThreshold) return 'off';
        // Hysteresis region between downThreshold and upThreshold retains last category
        if (vol < Theme.volumeIconDownThreshold) return 'down';
        if (vol >= Theme.volumeIconUpThreshold) return 'up';
        return lastVolIconCategory === 'down' ? 'down' : 'up';
    }

    function iconNameForCategory(cat) {
        switch (cat) {
        case 'off': return 'volume_off';
        case 'down': return 'volume_down';
        case 'up': default: return 'volume_up';
        }
    }

    PillIndicator {
        id: pillIndicator
        icon: iconNameForCategory(resolveIconCategory(volume, Services.Audio.muted))
        text: volume + "%"

        pillColor: Theme.panelPillBackground
        iconCircleColor: getVolumeColor()
        iconTextColor: Theme.background
        textColor: Theme.textPrimary
        collapsedIconColor: getIconColor()
        autoHide: true
        // Use per-volume override if provided
        autoHidePauseMs: Theme.volumePillAutoHidePauseMs
        showDelayMs: Theme.volumePillShowDelayMs

        StyledTooltip {
            id: volumeTooltip
            text: "Volume: " + volume + "%\nLeft click for advanced settings.\nScroll up/down to change volume."
            positionAbove: false
            tooltipVisible: !ioSelector.visible && volumeDisplay.containsMouse
            targetItem: pillIndicator
            delay: Theme.tooltipDelayMs
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
        target: Services.Audio
        function onVolumeChanged() {
            const clampedVolume = Utils.clamp(Services.Audio.volume, 0, 100);
            if (clampedVolume === volume) return;

            volume = clampedVolume;

            // Update pill content/icon from current state
            pillIndicator.text = volume + "%";
            const cat = resolveIconCategory(volume, Services.Audio.muted);
            if (cat !== 'off') lastVolIconCategory = cat;
            pillIndicator.icon = iconNameForCategory(cat);

            const atHundred = (volume === 100);

            // First change: don't flash the pill if we're exactly at 100%
            // to allow the module to remain hidden; otherwise reveal it.
            if (firstChange) {
                firstChange = false;
                if (!atHundred) {
                    if (!volumeDisplay.visible) volumeDisplay.visible = true;
                    pillIndicator.show();
                }
            } else {
                if (!volumeDisplay.visible) volumeDisplay.visible = true;
                pillIndicator.show();
            }

            // Schedule/stop full hide depending on current value, even on first change.
            if (atHundred) {
                fullHideTimer.restart();
            } else if (fullHideTimer.running) {
                fullHideTimer.stop();
            }
        }
    }

    Component.onCompleted: {
        if (Services.Audio && Services.Audio.volume !== undefined) {
            volume = Utils.clamp(Services.Audio.volume, 0, 100);
            const cat = resolveIconCategory(volume, Services.Audio.muted || false);
            if (cat !== 'off') lastVolIconCategory = cat;
            pillIndicator.icon = iconNameForCategory(cat);
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
            let step = Services.Audio.step || 5;
            if (wheel.angleDelta.y > 0) {
                Services.Audio.changeVolume(step);
            } else if (wheel.angleDelta.y < 0) {
                Services.Audio.changeVolume(-step);
            }
        }
    }
    property bool containsMouse: false
}
