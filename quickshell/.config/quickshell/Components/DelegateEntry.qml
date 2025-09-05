import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import qs.Settings
import qs.Components
import "../Helpers/Color.js" as Color

Rectangle {
    id: entry
    required property var modelData
    // Reference to parent ListView for sibling submenu cleanup
    required property ListView listViewRef
    // Component to create submenu host
    required property Component submenuHostComponent
    // Parent menu window (PopupWindow) to attach submenus to
    required property Item menuWindow

    // Theming
    property color hoverBaseColor: Theme.surfaceHover
    property int   itemRadius: Theme.panelMenuItemRadius

    width: listViewRef.width
    height: (modelData?.isSeparator) ? Theme.panelMenuSeparatorHeight : Theme.panelMenuItemHeight
    color: "transparent"
    radius: itemRadius

    property var subMenu: null

    // Separator line
    Rectangle {
        anchors.centerIn: parent
        width: parent.width - (Theme.panelMenuDividerMargin * 2)
        height: Theme.uiSeparatorThickness
        color: Theme.borderSubtle
        visible: modelData?.isSeparator ?? false
    }

    // Hover background for regular items
    Rectangle {
        id: bg
        anchors.fill: parent
        color: mouseArea.containsMouse ? hoverBaseColor : "transparent"
        radius: itemRadius
        visible: !(modelData?.isSeparator ?? false)
        property color hoverTextColor: mouseArea.containsMouse ? Color.contrastOn(bg.color, Theme.textPrimary, Theme.textSecondary, Theme.contrastThreshold) : Theme.textPrimary

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.panelMenuPadding
            anchors.rightMargin: Theme.panelMenuPadding
            spacing: Theme.panelMenuItemSpacing

            Text {
                Layout.fillWidth: true
                color: (modelData?.enabled ?? true) ? bg.hoverTextColor : Theme.textDisabled
                text: modelData?.text ?? ""
                font.family: Theme.fontFamily
                font.pixelSize: Math.round(Theme.fontSizeSmall * Theme.scale(screen) * Theme.panelMenuItemFontScale)
                font.weight: mouseArea.containsMouse ? Font.DemiBold : Font.Medium
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            Image {
                id: menuIcon
                Layout.preferredWidth: Theme.panelMenuIconSize
                Layout.preferredHeight: Theme.panelMenuIconSize
                source: modelData?.icon ?? ""
                visible: (modelData?.icon ?? "") !== ""
                fillMode: Image.PreserveAspectFit
            }
            // Fallback icon when provided source fails to load
            MaterialIcon {
                visible: ((modelData?.icon ?? "") !== "") && (menuIcon.status === Image.Error)
                icon: Settings.settings.trayFallbackIcon || "broken_image"
                size: Math.round(Theme.panelMenuIconSize * Theme.scale(screen))
                color: Theme.textSecondary
            }
            MaterialIcon {
                // Chevron/right indicator for submenu
                icon: modelData?.hasChildren ? "chevron_right" : ""
                size: Math.round(Theme.panelMenuChevronSize * Theme.scale(screen))
                visible: modelData?.hasChildren ?? false
                color: Theme.textPrimary
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false) && menuWindow.visible
            cursorShape: Qt.PointingHandCursor

            function openSubmenu() {
                if (!(modelData?.hasChildren)) return;
                // Close sibling submenus
                for (let i = 0; i < listViewRef.contentItem.children.length; i++) {
                    const sibling = listViewRef.contentItem.children[i];
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
                entry.subMenu = submenuHostComponent.createObject(menuWindow, {
                    menu: modelData,
                    anchorItem: entry,
                    anchorX: anchorX,
                    anchorY: 0
                });
                entry.subMenu.showAt(entry, anchorX, 0);
            }

            onClicked: {
                if (!modelData || modelData.isSeparator) return;
                if (modelData.hasChildren) return; // submenu opens on hover
                modelData.triggered();
                // Close the root menu
                menuWindow.visible = false;
            }
            onEntered: openSubmenu()
        }
    }
}
