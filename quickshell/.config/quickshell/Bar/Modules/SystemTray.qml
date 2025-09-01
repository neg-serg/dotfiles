import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import QtQuick.Effects
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Settings
import qs.Components

Row {
    id: root
    property var bar
    property var shell
    property var trayMenu
    spacing: 8
    Layout.alignment: Qt.AlignVCenter

    property bool containsMouse: false
    property var systemTray: SystemTray

    // Collapse/expand behavior from settings
    property bool collapsed: Settings.settings.collapseSystemTray
    property bool expanded: false
    // Guard to avoid immediate close from the same click that opened
    property bool openGuard: false
    Timer { id: guardTimer; interval: 120; repeat: false; onTriggered: openGuard = false }

    // Collapsed trigger button
    IconButton {
        id: collapsedButton
        z: 1002
        visible: collapsed
        anchors.verticalCenter: parent.verticalCenter
        // Keep compact size to match bar density
        size: 24 * Theme.scale(Screen)
        icon: Settings.settings.collapsedTrayIcon || "expand_more"
        // Derive accent from calendar's accent with low brightness
        property real ab: (Settings.settings.trayAccentBrightness !== undefined ? Settings.settings.trayAccentBrightness : 0.25)
        property color derivedAccent: Qt.rgba(
            Theme.accentPrimary.r * ab,
            Theme.accentPrimary.g * ab,
            Theme.accentPrimary.b * ab,
            1
        )
        accentColor: derivedAccent
        // Neutral icon normally, readable light icon on hover (dark accent)
        iconNormalColor: Theme.textPrimary
        iconHoverColor: Theme.textPrimary
        onClicked: {
            expanded = !expanded;
            if (expanded) { openGuard = true; guardTimer.restart(); }
        }
    }

    // Note: we purposely avoid a full overlay here to prevent immediate close issues in Row

    // Inline popup content under the trigger button (parented to bar to avoid Row layout)
    Rectangle {
        id: inlinePopup
        visible: collapsed && expanded
        parent: bar
        z: 1001
        // Dark blue popup background (derived from calendar accent, low brightness)
        radius: 12
        property real pab: (Settings.settings.trayAccentBrightness !== undefined ? Settings.settings.trayAccentBrightness : 0.25)
        property color popupAccent: Qt.rgba(
            Theme.accentPrimary.r * pab,
            Theme.accentPrimary.g * pab,
            Theme.accentPrimary.b * pab,
            1
        )
        color: popupAccent
        border.color: Theme.backgroundTertiary
        border.width: 1
        width: collapsedRow.implicitWidth + 12
        height: collapsedRow.implicitHeight + 12
        // Position relative to bar using global mapping
        x: collapsedButton.mapToItem(bar, collapsedButton.width/2, collapsedButton.height).x - inlinePopup.width/2
        y: collapsedButton.mapToItem(bar, collapsedButton.width/2, collapsedButton.height).y + 6
        Row {
            id: collapsedRow
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
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
                                expanded = false;
                            } else if (mouse.button === Qt.MiddleButton) {
                                if (trayMenu && trayMenu.visible) trayMenu.hideMenu();
                                modelData.secondaryActivate && modelData.secondaryActivate();
                                expanded = false;
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
