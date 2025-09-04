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
    // Audio service is a singleton now; modules should import qs.Services.Audio directly
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
