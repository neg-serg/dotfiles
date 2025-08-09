import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Settings

PanelWindow {
    id: outerPanel
    property bool showOverlay: Settings.settings.dimPanels
    property int topMargin: 36 * Theme.scale(screen)
    property color overlayColor: showOverlay ? Theme.overlay : "transparent"
    
    function dismiss() {
        visible = false;
    }

    function show() {
        visible = true;
    }

    implicitWidth: screen.width
    implicitHeight: screen.height
    color: visible ? overlayColor : "transparent"
    visible: false
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    screen: (typeof modelData !== 'undefined' ? modelData : null)
    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    margins.top: topMargin

    MouseArea {
        anchors.fill: parent
        onClicked: outerPanel.dismiss()
    }

    Behavior on color {
        ColorAnimation {
            duration: 350
            easing.type: Easing.InOutCubic
        }
    }
}