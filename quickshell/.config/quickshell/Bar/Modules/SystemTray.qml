import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import QtQuick.Effects
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Settings
import qs.Components

Row {
    property var bar
    property var shell
    property var trayMenu
    spacing: 8
    Layout.alignment: Qt.AlignVCenter

    property bool containsMouse: false
    property var systemTray: SystemTray

    // Collapse/expand behavior from settings
    property bool collapsed: Settings.settings.collapseSystemTray

    // Collapsed trigger button
    IconButton {
        id: collapsedButton
        visible: collapsed
        anchors.verticalCenter: parent.verticalCenter
        size: 24 * Theme.scale(Screen)
        icon: Settings.settings.collapsedTrayIcon || "expand_more"
        onClicked: collapsedPopup.visible ? collapsedPopup.close() : collapsedPopup.open()
    }

    Popup {
        id: collapsedPopup
        modal: false
        focus: true
        visible: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent | Popup.CloseOnPressOutside
        padding: 6
        background: Rectangle {
            radius: 8
            color: Theme.surfaceVariant
            border.color: Theme.outline
            border.width: 1
        }
        // Position near the trigger button using global coords
        onOpened: {
            const pt = collapsedButton.mapToItem(null, collapsedButton.width/2, collapsedButton.height);
            collapsedPopup.x = pt.x - collapsedPopup.width/2;
            collapsedPopup.y = pt.y + 6;
        }

        contentItem: Row {
            id: collapsedRow
            spacing: 6
            Repeater {
                model: systemTray.items
                delegate: Item {
                    width: 24 * Theme.scale(Screen)
                    height: 24 * Theme.scale(Screen)
                    visible: modelData

                    Rectangle {
                        anchors.centerIn: parent
                        width: 16 * Theme.scale(Screen)
                        height: 16 * Theme.scale(Screen)
                        radius: 6
                        color: "transparent"
                        clip: true

                        IconImage {
                            id: trayIconCollapsed
                            anchors.centerIn: parent
                            width: 16 * Theme.scale(Screen)
                            height: 16 * Theme.scale(Screen)
                            smooth: false
                            asynchronous: true
                            backer.fillMode: Image.PreserveAspectFit
                            source: {
                                let icon = modelData?.icon || "";
                                if (!icon) return "";
                                if (icon.includes("?path=")) {
                                    const [name, path] = icon.split("?path=");
                                    const fileName = name.substring(name.lastIndexOf("/") + 1);
                                    return `file://${path}/${fileName}`;
                                }
                                return icon;
                            }
                            opacity: status === Image.Ready ? 1 : 0
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: mouse => {
                            if (!modelData) return;
                            if (mouse.button === Qt.LeftButton) {
                                if (trayMenu && trayMenu.visible) trayMenu.hideMenu();
                                if (!modelData.onlyMenu) modelData.activate();
                                collapsedPopup.close();
                            } else if (mouse.button === Qt.MiddleButton) {
                                if (trayMenu && trayMenu.visible) trayMenu.hideMenu();
                                modelData.secondaryActivate && modelData.secondaryActivate();
                                collapsedPopup.close();
                            } else if (mouse.button === Qt.RightButton) {
                                if (trayMenu && trayMenu.visible) { trayMenu.hideMenu(); return; }
                                if (modelData.hasMenu && modelData.menu && trayMenu) {
                                    const menuX = (width / 2) - (trayMenu.width / 2);
                                    const menuY = height + 20 * Theme.scale(Screen);
                                    trayMenu.menu = modelData.menu;
                                    trayMenu.showAt(parent, menuX, menuY);
                                }
                            }
                        }
                    }
                }
            }
        }
        onClosed: {/* no-op */}
    }

    // Inline icons (visible only when not collapsed)
    Repeater {
        // Hide inline icons when collapsed
        model: collapsed ? 0 : systemTray.items
        delegate: Item {
            width: 24 * Theme.scale(Screen)
            height: 24 * Theme.scale(Screen)

            visible: modelData
            property bool isHovered: trayMouseArea.containsMouse

            // No animations - static display

            Rectangle {
                anchors.centerIn: parent
                width: 16 * Theme.scale(Screen)
                height: 16 * Theme.scale(Screen)
                radius: 6
                color: "transparent"
                clip: true

                IconImage {
                    id: trayIcon
                    anchors.centerIn: parent
                    width: 16 * Theme.scale(Screen)
                    height: 16 * Theme.scale(Screen)
                    smooth: false
                    asynchronous: true
                    backer.fillMode: Image.PreserveAspectFit
                    source: {
                        let icon = modelData?.icon || "";
                        if (!icon)
                            return "";
                        // Process icon path
                        if (icon.includes("?path=")) {
                            const [name, path] = icon.split("?path=");
                            const fileName = name.substring(name.lastIndexOf("/") + 1);
                            return `file://${path}/${fileName}`;
                        }
                        return icon;
                    }
                    opacity: status === Image.Ready ? 1 : 0
                    Component.onCompleted: {}
                }
            }

            MouseArea {
                id: trayMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: mouse => {
                    if (!modelData)
                        return;

                    if (mouse.button === Qt.LeftButton) {
                        // Close any open menu first
                        if (trayMenu && trayMenu.visible) {
                            trayMenu.hideMenu();
                        }

                        if (!modelData.onlyMenu) {
                            modelData.activate();
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        // Close any open menu first
                        if (trayMenu && trayMenu.visible) {
                            trayMenu.hideMenu();
                        }

                        modelData.secondaryActivate && modelData.secondaryActivate();
                    } else if (mouse.button === Qt.RightButton) {
                        trayTooltip.tooltipVisible = false;
                        // If menu is already visible, close it
                        if (trayMenu && trayMenu.visible) {
                            trayMenu.hideMenu();
                            return;
                        }

                        if (modelData.hasMenu && modelData.menu && trayMenu) {
                            // Anchor the menu to the tray icon item (parent) and position it below the icon
                            const menuX = (width / 2) - (trayMenu.width / 2);
                            const menuY = height + 20 * Theme.scale(Screen);
                            trayMenu.menu = modelData.menu;
                            trayMenu.showAt(parent, menuX, menuY);
                        } else
                        // console.log("No menu available for", modelData.id, "or trayMenu not set")
                        {}
                    }
                }
                onEntered: trayTooltip.tooltipVisible = true
                onExited: trayTooltip.tooltipVisible = false
            }

            StyledTooltip {
                id: trayTooltip
                text: modelData.tooltipTitle || modelData.name || modelData.id || "Tray Item"
                positionAbove: false
                tooltipVisible: false
                targetItem: trayIcon
                delay: 200
            }

            Component.onDestruction:
            // No cache cleanup needed
            {}
        }
    }
}
