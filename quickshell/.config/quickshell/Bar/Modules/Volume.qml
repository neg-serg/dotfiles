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
    // Last non-muted icon category (hysteresis): 'off' | 'down' | 'up'
    property string lastVolIconCategory: 'up'
    visible: false
    // Gradient endpoints
    property color volLowColor: Theme.panelVolumeLowColor
    property color volHighColor: Theme.panelVolumeHighColor
    // Stub ioSelector to avoid reference errors if advanced UI isn't present
    Item {
        id: ioSelector
        visible: false
        function show() { visible = true }
        function dismiss() { visible = false }
    }

    // Collapse size when hidden (RowLayout-friendly)
    width: visible ? pillIndicator.width : 0
    height: visible ? pillIndicator.height : 0
    implicitWidth: visible ? pillIndicator.width : 0
    implicitHeight: visible ? pillIndicator.height : 0
    // Hint RowLayout
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.maximumWidth: implicitWidth
    Layout.maximumHeight: implicitHeight

    // Auto-hide at 100%
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
        // 0% -> lowColor, 100% -> highColor
        var t = Utils.clamp(volume / 100.0, 0, 1);
        return Qt.rgba(
            volLowColor.r + (volHighColor.r - volLowColor.r) * t,
            volLowColor.g + (volHighColor.g - volLowColor.g) * t,
            volLowColor.b + (volHighColor.b - volLowColor.b) * t,
            1
        );
    }

    function getIconColor() { return getVolumeColor(); }

    function resolveIconCategory(vol, muted) {
        if (muted) return 'off';
        if (vol <= Theme.volumeIconOffThreshold) return 'off';
        // Hysteresis between down/up thresholds
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

            // Update pill content/icon
            pillIndicator.text = volume + "%";
            const cat = resolveIconCategory(volume, Services.Audio.muted);
            if (cat !== 'off') lastVolIconCategory = cat;
            pillIndicator.icon = iconNameForCategory(cat);

            const atHundred = (volume === 100);

            // First change: avoid flash at exactly 100%
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

            // Manage full-hide timer
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
            // Start hidden at 100%
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
