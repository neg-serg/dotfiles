import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import qs.Settings
import qs.Components
import "../Helpers/Color.js" as Color

Rectangle {
    id: entry
// Data for this entry (explicitly passed from ListView delegate)
required property var entryData
    // Reference to parent ListView for sibling submenu cleanup
    required property ListView listViewRef
    // Component to create submenu host
    required property Component submenuHostComponent
    // Parent menu window (PopupWindow) to attach submenus to
    required property var menuWindow

    // Optional screen (for Theme.scale). If not provided, defaults to 1.0 scale.
    property var screen: (menuWindow && menuWindow.screen) ? menuWindow.screen : null
    // Debug: computed font px
    readonly property int _computedPx: Math.max(1, Math.round(Theme.fontSizeSmall * Theme.scale(entry.screen) * Theme.panelMenuItemFontScale))
    function _entryText() {
        try {
            var d = entryData; if (!d) return "";
            var keys = ['text','label','title','name','id'];
            for (var i=0;i<keys.length;i++) {
                var k = keys[i]; var v = d[k];
                if (v !== undefined && v !== null) {
                    var s = String(v); if (s.length) return s;
                }
            }
            // Fallback best-effort
            return (d && d.toString) ? String(d) : '';
        } catch (e) { return "" }
    }
    // Theming
    property color hoverBaseColor: Theme.surfaceHover
    property int   itemRadius: Theme.panelMenuItemRadius

    width: listViewRef.width
    height: (entryData?.isSeparator) ? Theme.panelMenuSeparatorHeight : Theme.panelMenuItemHeight
    color: "transparent"
    radius: itemRadius

    property var subMenu: null

    // Separator line
    Rectangle {
        anchors.centerIn: parent
        width: parent.width - (Theme.panelMenuDividerMargin * 2)
        height: Theme.uiSeparatorThickness
        color: Theme.borderSubtle
        visible: entryData?.isSeparator ?? false
    }

    // Hover background for regular items
    Rectangle {
        id: bg
        anchors.fill: parent
        color: mouseArea.containsMouse ? hoverBaseColor : "transparent"
        radius: itemRadius
        visible: !(entryData?.isSeparator ?? false)
        property color hoverTextColor: mouseArea.containsMouse ? Color.contrastOn(bg.color, Theme.textPrimary, Theme.textSecondary, Theme.contrastThreshold) : Theme.textPrimary

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.panelMenuPadding
            anchors.rightMargin: Theme.panelMenuPadding
            spacing: Theme.panelMenuItemSpacing

            Text {
                Layout.fillWidth: true
                // Use primary text normally; switch to contrast-on-hover when hovered
                color: mouseArea.containsMouse
                       ? bg.hoverTextColor
                       : ((entryData?.enabled ?? true) ? Theme.textPrimary : Theme.textDisabled)
                text: entry._entryText()
                font.family: Theme.fontFamily
                font.pixelSize: entry._computedPx
                font.weight: mouseArea.containsMouse ? Font.DemiBold : Font.Medium
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                z: 10
            }

            Image {
                id: menuIcon
                Layout.preferredWidth: Theme.panelMenuIconSize
                Layout.preferredHeight: Theme.panelMenuIconSize
                source: entryData?.icon ?? ""
                visible: (entryData?.icon ?? "") !== ""
                fillMode: Image.PreserveAspectFit
            }
            // Fallback icon when provided source fails to load
            MaterialIcon {
                visible: ((entryData?.icon ?? "") !== "") && (menuIcon.status === Image.Error)
                icon: Settings.settings.trayFallbackIcon || "broken_image"
                size: Math.round(Theme.panelMenuIconSize * Theme.scale(screen))
                color: Theme.textSecondary
            }
            MaterialIcon {
                // Chevron/right indicator for submenu
                icon: entryData?.hasChildren ? "chevron_right" : ""
                size: Math.round(Theme.panelMenuChevronSize * Theme.scale(entry.screen))
                visible: entryData?.hasChildren ?? false
                color: Theme.textPrimary
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: (entryData?.enabled ?? true) && !(entryData?.isSeparator ?? false) && (menuWindow && menuWindow.visible)
            cursorShape: Qt.PointingHandCursor

            function openSubmenu() {
                if (!(entryData?.hasChildren)) return;
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
                    menu: entryData,
                    anchorItem: entry,
                    anchorX: anchorX,
                    anchorY: 0
                });
                entry.subMenu.showAt(entry, anchorX, 0);
            }

            onClicked: {
                if (!entryData || entryData.isSeparator) return;
                if (entryData.hasChildren) return; // submenu opens on hover
                entryData.triggered();
                // Close the root menu
                menuWindow.visible = false;
            }
            onEntered: openSubmenu()
        }
    }
    Component.onCompleted: {
        try {
            var keys = []; var d=entryData; for (var k in d) keys.push(k);
            console.debug('[Menu][DelegateEntry] init keys=', keys.join(','), 'text=', entry._entryText(), 'px=', entry._computedPx,
                          'textPrimary=', String(Theme.textPrimary), 'hoverBase=', String(hoverBaseColor))
        } catch (e) {}
    }
    // Note: modelData is a context property in delegate; not all engines expose change signals.
}
