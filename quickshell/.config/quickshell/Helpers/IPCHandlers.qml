import QtQuick
import Quickshell.Io
import qs.Bar.Modules
import qs.Helpers

Item {
    id: root
    property Applauncher appLauncherPanel
    property IdleInhibitor idleInhibitor
    IpcHandler {
        target: "globalIPC"
        function toggleIdleInhibitor(): void { root.idleInhibitor.toggle(); }
        // Toggle Applauncher visibility
        function toggleLauncher(): void {
            if (!root.appLauncherPanel) { return; }
            if (root.appLauncherPanel.visible) {
                root.appLauncherPanel.hidePanel();
            } else {
                root.appLauncherPanel.showAt();
            }
        }
    }
}
