import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import QtQuick
import QtCore
import qs.Bar
import qs.Bar.Modules
import qs.Widgets
import qs.Settings
import qs.Helpers

Scope {
    id: root
    // Helper function to round value to nearest step
    function roundToStep(value, step) { return Math.round(value / step) * step; }
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
    // Sync volume with current sink state
    function syncVolume() {
        if (defaultAudioSink && defaultAudioSink.audio) {
            volume = defaultAudioSink.audio.muted
                ? 0
                : Math.round(defaultAudioSink.audio.volume * 100);
        }
    }
    // Mirror panel when positioned at the bottom (guard settings availability)
    function mirrorIfBottom() {
        try {
            if (Settings.settings && Settings.settings.panelPosition === "bottom") {
                windowMirror.mirror(bar.barHeight);
            }
        } catch (e) { /* ignore until settings load */ }
    }

    Component.onCompleted: {
        Quickshell.shell = root;
        mirrorIfBottom();
    }

    // Overview {}
    Bar { id: bar; shell: root; }
    WindowMirror { id: windowMirror } // Helper to mirror window positions when the panel is at the bottom
    // Remove noisy Connections with unknown signals; we can re-evaluate on demand or via UI events

    Applauncher {
        id: appLauncherPanel
        visible: false
    }

    IdleInhibitor { id: idleInhibitor; }
    property var defaultAudioSink: Pipewire.defaultAudioSink // Reference to the default audio sink from Pipewire
    PwObjectTracker { objects: [Pipewire.defaultAudioSink]; }
    IPCHandlers { appLauncherPanel: appLauncherPanel; idleInhibitor: idleInhibitor; }

    Connections {
        function onReloadCompleted() { Quickshell.inhibitReloadPopup(); }
        function onReloadFailed() { Quickshell.inhibitReloadPopup(); }
        target: Quickshell
    }

    Timer {
        id: reloadTimer
        interval: 500
        repeat: false
        onTriggered: Quickshell.reload(true)
    }

    Connections {
        target: defaultAudioSink ? defaultAudioSink.audio : null
        function onVolumeChanged() { syncVolume(); }
        function onMutedChanged() { syncVolume(); }
    }

}
