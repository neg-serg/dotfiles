import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import Quickshell
import qs.Components
import qs.Settings
import "../Helpers/Utils.js" as Utils

PopupWindow {
    id: subMenu
    implicitWidth: Theme.panelSubmenuWidth
    implicitHeight: Utils.clamp(listView.contentHeight + Theme.panelMenuHeightExtra, 40, listView.contentHeight + Theme.panelMenuHeightExtra)
    visible: false
    color: "transparent"

    required property var menu
    // Component used to spawn deeper submenus (injected from parent context)
    required property Component submenuHostComponent
    property var anchorItem: null
    property real anchorX
    property real anchorY

    anchor.item: anchorItem ? anchorItem : null
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY - Math.round(Theme.panelMenuAnchorYOffset * Theme.scale(Screen))

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
        radius: Theme.panelMenuRadius
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

        model: ScriptModel {
            id: subMenuModel;
            values: (function() {
                try {
                    const ch = opener && opener.children ? opener.children : null;
                    if (!ch) return [];
                    const v = ch.values;
                    if (typeof v === 'function') return [...v.call(ch)];
                    if (v && v.length !== undefined) return v;
                    if (ch && ch.length !== undefined) return ch;
                    return [];
                } catch (_) { return [] }
            })()
        }

        delegate: Item {
            required property var modelData
            width: listView.width
            height: entryItem.height
            DelegateEntry {
                id: entryItem
                entryData: parent.modelData
                listViewRef: listView
                submenuHostComponent: subMenu.submenuHostComponent
                menuWindow: subMenu
            }
        }
    }
}
