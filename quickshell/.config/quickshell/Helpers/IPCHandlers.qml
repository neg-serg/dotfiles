import QtQuick
import Quickshell.Io

Item {
    id: root
    property IdleInhibitor idleInhibitor
    IpcHandler {
        target: "globalIPC"
        function toggleIdleInhibitor(): void { root.idleInhibitor.toggle(); }
    }
}
