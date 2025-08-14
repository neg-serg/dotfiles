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
            if (!root.appLauncherPanel) {
                console.warn("AppLauncherIpcHandler: appLauncherPanel not set!");
                return;
            }
            if (root.appLauncherPanel.visible) {
                root.appLauncherPanel.hidePanel();
            } else {
                console.log("[IPC] Applauncher show() called");
                root.appLauncherPanel.showAt();
            }
        }
    }
}

