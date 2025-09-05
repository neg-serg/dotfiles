import QtQuick
import QtQuick.Controls
import qs.Components
import qs.Settings

PopupWindow {
    id: subMenu
    implicitWidth: Theme.panelSubmenuWidth
    implicitHeight: Utils.clamp(listView.contentHeight + Theme.panelMenuHeightExtra, 40, listView.contentHeight + Theme.panelMenuHeightExtra)
    visible: false
    color: "transparent"

    required property var menu
    property var anchorItem: null
    property real anchorX
    property real anchorY

    anchor.item: anchorItem ? anchorItem : null
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY

    function showAt(item, x, y) {
        if (!item) return;
        anchorItem = item;
        anchorX = x;
        anchorY = y;
        visible = true;
        Qt.callLater(() => subMenu.anchor.updateAnchor());
    }
    function hideMenu() { visible = false }
    function containsMouse() { return subMenu.containsMouse }

    Item { anchors.fill: parent; Keys.onEscapePressed: subMenu.hideMenu() }

    QsMenuOpener { id: opener; menu: subMenu.menu }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Theme.background
        border.color: Theme.borderSubtle
        border.width: Theme.uiBorderWidth
        radius: Theme.panelMenuItemRadius
        z: 0
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: Theme.panelMenuPadding
        spacing: Theme.panelMenuItemSpacing
        interactive: false
        enabled: subMenu.visible
        clip: true

        model: ScriptModel { values: opener.children ? [...opener.children.values] : [] }

        delegate: DelegateEntry {
            modelData: modelData
            listViewRef: listView
            submenuHostComponent: submenuHostComp
            menuWindow: subMenu
        }
    }

    Component { id: submenuHostComp; SubmenuHost {} }
}

