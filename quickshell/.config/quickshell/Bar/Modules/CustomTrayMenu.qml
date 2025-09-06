pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Quickshell
import qs.Settings
import qs.Components
import "../../Helpers/Utils.js" as Utils
import "../../Helpers/Color.js" as Color

    PopupWindow {
        id: trayMenu
        implicitWidth: Theme.panelMenuWidth
        implicitHeight: Utils.clamp(listView.contentHeight + Theme.panelMenuHeightExtra, 40, listView.contentHeight + Theme.panelMenuHeightExtra)
        visible: false
        color: "transparent"

    property QsMenuHandle menu
    property var anchorItem: null
    property real anchorX
    property real anchorY

    anchor.item: anchorItem ? anchorItem : null
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY - Math.round(Theme.panelMenuAnchorYOffset * Theme.scale(Screen))

    // Recursively destroy all open submenus in delegate tree
    function destroySubmenusRecursively(item) {
        if (!item || !item.contentItem) return;
        var children = item.contentItem.children;
        for (var i = 0; i < children.length; ++i) {
            var child = children[i];
            if (child.subMenu) {
                child.subMenu.hideMenu();
                child.subMenu.destroy();
                child.subMenu = null;
            }
            if (child.contentItem) {
                destroySubmenusRecursively(child);
            }
        }
    }

    function showAt(item, x, y) {
        if (!item) { return; }
        anchorItem = item;
        anchorX = x;
        anchorY = y;
        visible = true;
        forceActiveFocus();
        Qt.callLater(() => trayMenu.anchor.updateAnchor())
    }

    function hideMenu() { visible = false; destroySubmenusRecursively(listView) }

    Item {
        anchors.fill: parent;
        Keys.onEscapePressed: trayMenu.hideMenu();
    }

    QsMenuOpener { id: opener; menu: trayMenu.menu }
    // Submenu host component passed into delegates
    Component { id: submenuHostComp; SubmenuHost { submenuHostComponent: submenuHostComp } }

    Rectangle {
        id: bg;
        anchors.fill: parent;
        color: Theme.background;
        border.color: Theme.borderSubtle;
        border.width: Theme.uiBorderWidth;
        radius: Theme.panelMenuRadius;
        z: 0;
    }

    ListView {
        id: listView;
        anchors.fill: parent;
        anchors.margins: Theme.panelMenuPadding;
        spacing: Theme.panelMenuItemSpacing;
        interactive: false;
        enabled: trayMenu.visible;
        clip: true;

        model: ScriptModel {
            id: rootMenuModel;
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

        readonly property color _hoverColor: Theme.surfaceHover

        delegate: Item {
            required property var modelData
            width: listView.width
            height: entryItem.height
            DelegateEntry {
                id: entryItem
                // Ensure we pass the ListView delegate's modelData, not any outer modelData (e.g., screen)
                entryData: parent.modelData
                listViewRef: listView
                submenuHostComponent: submenuHostComp
                menuWindow: trayMenu
            }
        }
    }

    Component {
        id: subMenuComponent;
        SubmenuHost { submenuHostComponent: submenuHostComp }
    }

    
}
