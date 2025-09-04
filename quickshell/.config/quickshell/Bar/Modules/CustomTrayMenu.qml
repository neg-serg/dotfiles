pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Quickshell
import qs.Settings
import qs.Components

    PopupWindow {
        id: trayMenu
        implicitWidth: Theme.panelMenuWidth
        implicitHeight: Math.max(40, listView.contentHeight + Theme.panelMenuHeightExtra)
        visible: false
        color: "transparent"

    property QsMenuHandle menu
    property var anchorItem: null
    property real anchorX
    property real anchorY

    anchor.item: anchorItem ? anchorItem : null
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY - Theme.panelMenuAnchorYOffset

    // Recursive function to destroy all open submenus in delegate tree, safely avoiding infinite recursion
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
            // Recursively destroy submenus only if the child has contentItem to prevent issues
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
        Qt.callLater(() => trayMenu.anchor.updateAnchor());
    }

    function hideMenu() {
        visible = false;
        destroySubmenusRecursively(listView);
    }

    Item {
        anchors.fill: parent;
        Keys.onEscapePressed: trayMenu.hideMenu();
    }

    QsMenuOpener {
        id: opener;
        menu: trayMenu.menu;
    }

    // Base background: compact; radius configured by Theme
    Rectangle {
        id: bg;
        anchors.fill: parent;
        color: Theme.backgroundPrimary || "#222";
        border.color: "transparent";
        border.width: 0;
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
            values: opener.children ? [...opener.children.values] : []
        }

        // Brighter hover color: lighten accentPrimary towards white, then apply light alpha
        readonly property real _lighten: 0.5
        readonly property color _hoverColor: Qt.rgba(
            Theme.accentPrimary.r + (1 - Theme.accentPrimary.r) * _lighten,
            Theme.accentPrimary.g + (1 - Theme.accentPrimary.g) * _lighten,
            Theme.accentPrimary.b + (1 - Theme.accentPrimary.b) * _lighten,
            0.18
        )

        delegate: Rectangle {
            id: entry;
            required property var modelData;

            width: listView.width;
            height: (modelData?.isSeparator) ? Theme.panelMenuSeparatorHeight : Theme.panelMenuItemHeight;
            color: "transparent";
            radius: 0;

            property var subMenu: null;

            Rectangle {
                anchors.centerIn: parent;
                width: parent.width - (Theme.panelMenuDividerMargin * 2);
                height: 1;
                color: Qt.darker(Theme.backgroundPrimary || "#222", 1.4);
                visible: modelData?.isSeparator ?? false;
            }

            Rectangle {
                id: bg;
                anchors.fill: parent;
                // Hover color: brightened accent tint with light alpha
                color: mouseArea.containsMouse ? listView._hoverColor : "transparent";
                radius: 0;
                visible: !(modelData?.isSeparator ?? false);
                property color hoverTextColor: mouseArea.containsMouse ? Theme.textPrimary : Theme.textPrimary;

                RowLayout {
                    anchors.fill: parent;
                    anchors.leftMargin: 6;
                    anchors.rightMargin: 6;
                    spacing: 4;

                    Text {
                        Layout.fillWidth: true;
                        color: (modelData?.enabled ?? true) ? bg.hoverTextColor : Theme.textDisabled;
                        text: modelData?.text ?? "";
                        font.family: Theme.fontFamily;
                        font.pixelSize: Math.round(Theme.fontSizeSmall * Theme.scale(screen) * 0.90);
                        font.weight: mouseArea.containsMouse ? Font.DemiBold : Font.Medium;
                        verticalAlignment: Text.AlignVCenter;
                        elide: Text.ElideRight;
                    }

                    Image {
                        Layout.preferredWidth: 16;
                        Layout.preferredHeight: 16;
                        source: modelData?.icon ?? "";
                        visible: (modelData?.icon ?? "") !== "";
                        fillMode: Image.PreserveAspectFit;
                    }

                    MaterialIcon {
                        // Chevron/right indicator for submenu
                        icon: modelData?.hasChildren ? "chevron_right" : ""
                        size: Math.round(15 * Theme.scale(screen))
                        visible: modelData?.hasChildren ?? false
                        color: Theme.textPrimary
                    }
                }

                MouseArea {
                    id: mouseArea;
                    anchors.fill: parent;
                    hoverEnabled: true;
                    enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false) && trayMenu.visible;

                    onClicked: {
                        if (modelData && !modelData.isSeparator) {
                            if (modelData.hasChildren) {
                                // Submenus open on hover; ignore click here
                                return;
                            }
                            modelData.triggered();
                            trayMenu.hideMenu();
                        }
                    }

                    onEntered: {
                        if (!trayMenu.visible) return;

                        if (modelData?.hasChildren) {
                            // Close sibling submenus immediately
                            for (let i = 0; i < listView.contentItem.children.length; i++) {
                                const sibling = listView.contentItem.children[i];
                                if (sibling !== entry && sibling.subMenu) {
                                    sibling.subMenu.hideMenu();
                                    sibling.subMenu.destroy();
                                    sibling.subMenu = null;
                                }
                            }
                            if (entry.subMenu) {
                                entry.subMenu.hideMenu();
                                entry.subMenu.destroy();
                                entry.subMenu = null;
                            }
                            var globalPos = entry.mapToGlobal(0, 0);
                            var submenuWidth = 180;
                            var gap = 12;
                            var openLeft = (globalPos.x + entry.width + submenuWidth > Screen.width);
                            var anchorX = openLeft ? -submenuWidth - gap : entry.width + gap;

                            entry.subMenu = subMenuComponent.createObject(trayMenu, {
                                menu: modelData,
                                anchorItem: entry,
                                anchorX: anchorX,
                                anchorY: 0
                            });
                            entry.subMenu.showAt(entry, anchorX, 0);
                        } else {
                            // Hovered item without submenu; close siblings
                            for (let i = 0; i < listView.contentItem.children.length; i++) {
                                const sibling = listView.contentItem.children[i];
                                if (sibling.subMenu) {
                                    sibling.subMenu.hideMenu();
                                    sibling.subMenu.destroy();
                                    sibling.subMenu = null;
                                }
                            }
                            if (entry.subMenu) {
                                entry.subMenu.hideMenu();
                                entry.subMenu.destroy();
                                entry.subMenu = null;
                            }
                        }
                    }

                    onExited: {
                        if (entry.subMenu && !entry.subMenu.containsMouse()) {
                            entry.subMenu.hideMenu();
                            entry.subMenu.destroy();
                            entry.subMenu = null;
                        }
                    }
                }
            }

            // Simplified containsMouse without recursive calls to avoid stack overflow
            function containsMouse() {
                return mouseArea.containsMouse;
            }

            Component.onDestruction: {
                if (subMenu) {
                    subMenu.destroy();
                    subMenu = null;
                }
            }
        }
    }

    Component {
        id: subMenuComponent;

        PopupWindow {
            id: subMenu;
            implicitWidth: 180;
            implicitHeight: Math.max(40, listView.contentHeight + 12);
            visible: false;
            color: "transparent";

            property QsMenuHandle menu;
            property var anchorItem: null;
            property real anchorX;
            property real anchorY;

            anchor.item: anchorItem ? anchorItem : null;
            anchor.rect.x: anchorX;
            anchor.rect.y: anchorY;

            function showAt(item, x, y) {
                if (!item) {
                    console.warn("subMenuComponent: anchorItem is undefined, not showing menu.");
                    return;
                }
                anchorItem = item;
                anchorX = x;
                anchorY = y;
                visible = true;
                Qt.callLater(() => subMenu.anchor.updateAnchor());
            }

            function hideMenu() {
                visible = false;
                // Close all submenus recursively in this submenu
                for (let i = 0; i < listView.contentItem.children.length; i++) {
                    const child = listView.contentItem.children[i];
                    if (child.subMenu) {
                        child.subMenu.hideMenu();
                        child.subMenu.destroy();
                        child.subMenu = null;
                    }
                }
            }

            // Simplified containsMouse avoiding recursive calls
            function containsMouse() {
                return subMenu.containsMouse;
            }

            Item {
                anchors.fill: parent;
                Keys.onEscapePressed: subMenu.hideMenu();
            }

            QsMenuOpener {
                id: opener;
                menu: subMenu.menu;
            }

    // Submenu background: compact; radius configured by Theme
            Rectangle {
                id: bg;
                anchors.fill: parent;
                color: Theme.backgroundPrimary || "#222";
                border.color: "transparent";
                border.width: 0;
                radius: 0;
                z: 0;
            }

            ListView {
                id: listView;
                anchors.fill: parent;
                anchors.margins: Theme.panelMenuPadding;
                spacing: Theme.panelMenuItemSpacing;
                interactive: false;
                enabled: subMenu.visible;
                clip: true;

                model: ScriptModel {
                    values: opener.children ? [...opener.children.values] : [];
                }

                // Reuse the same brightened hover color for submenu
                readonly property color _hoverColor: listView._hoverColor

                delegate: Rectangle {
                    id: entry;
                    required property var modelData;

                    width: listView.width;
                    height: (modelData?.isSeparator) ? Theme.panelMenuSeparatorHeight : Theme.panelMenuItemHeight;
                    color: "transparent";
                    radius: 0;

                    property var subMenu: null;

                    Rectangle {
                        anchors.centerIn: parent;
                        width: parent.width - (Theme.panelMenuDividerMargin * 2);
                        height: 1;
                        color: Qt.darker(Theme.surfaceVariant || "#222", 1.4);
                        visible: modelData?.isSeparator ?? false;
                    }

                    Rectangle {
                        id: bg;
                        anchors.fill: parent;
                        color: mouseArea.containsMouse ? _hoverColor : "transparent";
                        radius: Theme.panelMenuRadius;
                        visible: !(modelData?.isSeparator ?? false);
                        property color hoverTextColor: mouseArea.containsMouse ? Theme.textPrimary : Theme.textPrimary;

                        RowLayout {
                            anchors.fill: parent;
                            anchors.leftMargin: 6;
                            anchors.rightMargin: 6;
                            spacing: Theme.panelMenuItemSpacing;

                            Text {
                                Layout.fillWidth: true;
                                color: (modelData?.enabled ?? true) ? bg.hoverTextColor : Theme.textDisabled;
                                text: modelData?.text ?? "";
                                font.family: Theme.fontFamily;
                                font.pixelSize: Math.round(Theme.fontSizeSmall * Theme.scale(screen) * 0.90);
                                font.weight: mouseArea.containsMouse ? Font.DemiBold : Font.Medium;
                                verticalAlignment: Text.AlignVCenter;
                                elide: Text.ElideRight;
                            }

                            Image {
                                Layout.preferredWidth: Theme.panelMenuIconSize;
                                Layout.preferredHeight: Theme.panelMenuIconSize;
                                source: modelData?.icon ?? "";
                                visible: (modelData?.icon ?? "") !== "";
                                fillMode: Image.PreserveAspectFit;
                            }

                            MaterialIcon {
                                icon: modelData?.hasChildren ? "chevron_right" : ""
                                size: Math.round(Theme.panelMenuChevronSize * Theme.scale(screen))
                                visible: modelData?.hasChildren ?? false
                                color: Theme.textPrimary
                            }
                        }

                        MouseArea {
                            id: mouseArea;
                            anchors.fill: parent;
                            hoverEnabled: true;
                            enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false) && subMenu.visible;

                            onClicked: {
                                if (modelData && !modelData.isSeparator) {
                                    if (modelData.hasChildren) {
                                        return;
                                    }
                                    modelData.triggered();
                                    trayMenu.hideMenu();
                                }
                            }

                            onEntered: {
                                if (!subMenu.visible) return;

                                if (modelData?.hasChildren) {
                                    for (let i = 0; i < listView.contentItem.children.length; i++) {
                                        const sibling = listView.contentItem.children[i];
                                        if (sibling !== entry && sibling.subMenu) {
                                            sibling.subMenu.hideMenu();
                                            sibling.subMenu.destroy();
                                            sibling.subMenu = null;
                                        }
                                    }
                                    if (entry.subMenu) {
                                        entry.subMenu.hideMenu();
                                        entry.subMenu.destroy();
                                        entry.subMenu = null;
                                    }
                                    var globalPos = entry.mapToGlobal(0, 0);
                                    var submenuWidth = Theme.panelSubmenuWidth;
                                    var gap = Theme.panelSubmenuGap;
                                    var openLeft = (globalPos.x + entry.width + submenuWidth > Screen.width);
                                    var anchorX = openLeft ? -submenuWidth - gap : entry.width + gap;

                                    entry.subMenu = subMenuComponent.createObject(subMenu, {
                                        menu: modelData,
                                        anchorItem: entry,
                                        anchorX: anchorX,
                                        anchorY: 0
                                    });
                                    entry.subMenu.showAt(entry, anchorX, 0);
                                } else {
                                    for (let i = 0; i < listView.contentItem.children.length; i++) {
                                        const sibling = listView.contentItem.children[i];
                                        if (sibling.subMenu) {
                                            sibling.subMenu.hideMenu();
                                            sibling.subMenu.destroy();
                                            sibling.subMenu = null;
                                        }
                                    }
                                    if (entry.subMenu) {
                                        entry.subMenu.hideMenu();
                                        entry.subMenu.destroy();
                                        entry.subMenu = null;
                                    }
                                }
                            }

                            onExited: {
                                if (entry.subMenu && !entry.subMenu.containsMouse()) {
                                    entry.subMenu.hideMenu();
                                    entry.subMenu.destroy();
                                    entry.subMenu = null;
                                }
                            }
                        }
                    }

                    // Simplified & safe containsMouse avoiding recursion
                    function containsMouse() {
                        return mouseArea.containsMouse;
                    }

                    Component.onDestruction: {
                        if (subMenu) {
                            subMenu.destroy();
                            subMenu = null;
                        }
                    }
                }
            }
        }
    }
}
