import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import qs.Components
import qs.Settings

PanelWithOverlay {
    id: sidebarPopup
    showOverlay: false
    topMargin: 0
    bottomMargin: 0
    property int panelMarginPx: 0
    WlrLayershell.namespace: "sideright-music"
    function showAt() { sidebarPopupRect.showAt(); }
    function hidePopup() { sidebarPopupRect.hidePopup(); }
    

        Rectangle {
            id: sidebarPopupRect
        property real computedHeightPx: -1
        
        function showAt() {
            if (!sidebarPopup.visible) {
                if (computedHeightPx < 0) {
                    var ih = (musicWidget && musicWidget.implicitHeight > 0) ? musicWidget.implicitHeight : (250 * Theme.scale(screen));
                    computedHeightPx = Math.round(ih);
                }
                sidebarPopup.visible = true;
                forceActiveFocus();
            } else {
                forceActiveFocus();
            }
        }

        function hidePopup() { if (sidebarPopup.visible) sidebarPopup.visible = false }

        property real musicWidthPx: 840 * Theme.scale(screen)
        property real musicHeightPx: (musicWidget && musicWidget.implicitHeight > 0)
                                     ? Math.round(musicWidget.implicitHeight)
                                     : Math.round(250 * Theme.scale(screen))
        width: Math.round(musicWidthPx)
        height: Math.round(((computedHeightPx >= 0) ? computedHeightPx : musicHeightPx))
        color: "transparent"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        MouseArea { anchors.fill: parent }

        Item {
            id: mainRectangle
            width: sidebarPopupRect.width
            height: sidebarPopupRect.height
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 4 * Theme.scale(screen)
            anchors.bottomMargin: sidebarPopup.panelMarginPx
            

        }

        Item {
            anchors.fill: mainRectangle
            z: 1
            ColumnLayout {
                id: contentCol
                anchors.fill: parent
                spacing: 0

                RowLayout {
                    spacing: 8 * Theme.scale(screen)
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter
                    Music {
                        id: musicWidget
                        width: sidebarPopupRect.musicWidthPx
                        height: sidebarPopupRect.musicHeightPx
                    }
                }

            }
        }

        

    }

    
}
