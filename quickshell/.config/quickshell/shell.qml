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
    

    Component.onCompleted: {
        Quickshell.shell = root;
    }

    // Overview {}
    Bar { id: bar; shell: root; }

    IdleInhibitor { id: idleInhibitor; }
    IPCHandlers { idleInhibitor: idleInhibitor; }

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
