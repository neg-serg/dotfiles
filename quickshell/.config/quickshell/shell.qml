import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import QtQuick
import QtCore
import qs.Bar
import qs.Bar.Modules
import qs.Widgets
import qs.Widgets.LockScreen
import qs.Settings
import qs.Helpers

Scope {
    id: root
    property bool pendingReload: false
    
    // Helper function to round value to nearest step
    function roundToStep(value, step) {
        return Math.round(value / step) * step;
    }

    // Volume property reflecting current audio volume in 0-100
    // Will be kept in sync dynamically below
    property int volume: (defaultAudioSink && defaultAudioSink.audio && !defaultAudioSink.audio.muted)
                        ? Math.round(defaultAudioSink.audio.volume * 100)
                        : 0

    // Function to update volume with clamping, stepping, and applying to audio sink
    function updateVolume(vol) {
        var clamped = Math.max(0, Math.min(100, vol));
        var stepped = roundToStep(clamped, 5);
        if (defaultAudioSink && defaultAudioSink.audio) {
            defaultAudioSink.audio.volume = stepped / 100;
        }
        volume = stepped;
    }

    Component.onCompleted: {
        Quickshell.shell = root;
        if (Settings.settings.panelPosition === "bottom") {
            windowMirror.mirror(bar.barHeight);
        }
    }

    Overview {}

    Bar {
        id: bar
        shell: root
    }

    // Helper to mirror window positions when the panel is at the bottom
    WindowMirror { id: windowMirror }

    Connections {
        target: Settings.settings
        function onPanelPositionChanged() {
            if (Settings.settings.panelPosition === "bottom") {
                windowMirror.mirror(bar.barHeight)
            }
        }
    }

    Connections {
        target: Hyprland
        function onClientAdded() {
            if (Settings.settings.panelPosition === "bottom") {
                windowMirror.mirror(bar.barHeight)
            }
        }
    }

    Applauncher {
        id: appLauncherPanel
        visible: false
    }

    LockScreen {
        id: lockScreen
        onLockedChanged: {
            if (!locked && root.pendingReload) {
                reloadTimer.restart();
                root.pendingReload = false;
            }
        }
    }

    IdleInhibitor {
        id: idleInhibitor
    }

    property var defaultAudioSink: Pipewire.defaultAudioSink // Reference to the default audio sink from Pipewire

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    IPCHandlers {
        appLauncherPanel: appLauncherPanel
        lockScreen: lockScreen
        idleInhibitor: idleInhibitor
    }

    Connections {
        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
        }

        function onReloadFailed() {
            Quickshell.inhibitReloadPopup();
        }

        target: Quickshell
    }

    Timer {
        id: reloadTimer
        interval: 500 // ms
        repeat: false
        onTriggered: Quickshell.reload(true)
    }

    Connections {
        target: Quickshell
        function onScreensChanged() {
            if (lockScreen.locked) {
                pendingReload = true;
            }
        }
    }

    Connections {
        target: defaultAudioSink ? defaultAudioSink.audio : null
        function onVolumeChanged() {
            if (defaultAudioSink.audio && !defaultAudioSink.audio.muted) {
                volume = Math.round(defaultAudioSink.audio.volume * 100);
                console.log("Volume changed externally to:", volume);
            }
        }
        function onMutedChanged() {
            if (defaultAudioSink.audio) {
                if (defaultAudioSink.audio.muted) {
                    volume = 0;
                    console.log("Audio muted, volume set to 0");
                } else {
                    volume = Math.round(defaultAudioSink.audio.volume * 100);
                    console.log("Audio unmuted, volume restored to:", volume);
                }
            }
        }
    }

}
