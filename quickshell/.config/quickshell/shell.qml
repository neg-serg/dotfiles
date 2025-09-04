import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtCore
import qs.Bar
import qs.Bar.Modules
import qs.Helpers
import qs.Services

Scope {
    id: root
    // Centralized audio service
    Audio { id: audio }
    // Back-compat surface expected by modules
    property alias volume: audio.volume
    function updateVolume(vol) { audio.setVolume(vol) }
    // Window mirroring removed; Hyprland exclusive zones handle panel space

    Component.onCompleted: {
        Quickshell.shell = root;
    }

    // Overview {}
    Bar { id: bar; shell: root; }
    // Remove noisy Connections with unknown signals; we can re-evaluate on demand or via UI events

    Applauncher {
        id: appLauncherPanel
        visible: false
    }

    IdleInhibitor { id: idleInhibitor; }
    // Expose default sink for modules that reference it directly
    property alias defaultAudioSink: audio.defaultAudioSink
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

    // Volume/mute updates are handled inside Services/Audio

}
