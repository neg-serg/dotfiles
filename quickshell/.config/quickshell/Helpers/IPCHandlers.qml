import QtQuick
import Quickshell.Io
import qs.Helpers

Item {
    id: root
    property IdleInhibitor idleInhibitor
    IpcHandler {
        target: "globalIPC"
        function toggleIdleInhibitor(): void { root.idleInhibitor.toggle(); }
    }
}
