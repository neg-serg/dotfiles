import QtQuick
import Quickshell.Io
import qs.Bar.Modules
import qs.Helpers
import qs.Widgets.LockScreen

Item {
    id: root

    property Applauncher appLauncherPanel
    property LockScreen lockScreen
    property IdleInhibitor idleInhibitor

    IpcHandler {
        target: "globalIPC"

        function toggleIdleInhibitor(): void {
            root.idleInhibitor.toggle()
        }

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

        // Toggle LockScreen
        function toggleLock(): void {
            if (!root.lockScreen) {
                console.warn("LockScreenIpcHandler: lockScreen not set!");
                return;
            }
            console.log("[IPC] LockScreen show() called");
            root.lockScreen.locked = true;
        }
    }
}

