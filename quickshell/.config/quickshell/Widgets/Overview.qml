import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Services
import qs.Settings

ShellRoot {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property ShellScreen modelData
            anchors { top: true; bottom: true; right: true; left: true; }
            color: "transparent"
            screen: modelData
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell-overview"
            MultiEffect {
                id: overviewBgBlur
                anchors.fill: parent
                source: bgImage
                blurEnabled: true
                blur: 0.48
                blurMax: 128
            }
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(Theme.backgroundPrimary.r, Theme.backgroundPrimary.g, Theme.backgroundPrimary.b, 0.5)
            }
        }
    }
}
