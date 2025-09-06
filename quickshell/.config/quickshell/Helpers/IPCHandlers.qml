import QtQuick
import Quickshell.Io
import qs.Helpers

Item {
    id: root
    // Use Item to avoid requiring the Applauncher type
    property Item appLauncherPanel
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
