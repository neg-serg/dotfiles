import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Settings
import qs.Components

Row {
    id: root
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

    // Note: we purposely avoid a full overlay here to prevent immediate close issues in Row

    // Inline expanded content that participates in Row layout (shifts neighbors)
    Item {
        id: inlineBox
        // Keep visible during close animation until width shrinks to 0
        visible: collapsed && (expanded || openProgress > 0)
        anchors.verticalCenter: parent.verticalCenter
        // Open progress 0..1 drives horizontal expansion
        property real openProgress: 0
        Behavior on openProgress { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        // Background behind inline tray icons
        property real pab: (Settings.settings.trayAccentBrightness !== undefined ? Settings.settings.trayAccentBrightness : 0.25)
        property color popupAccent: Qt.rgba(
            Theme.accentPrimary.r * pab,
            Theme.accentPrimary.g * pab,
            Theme.accentPrimary.b * pab,
            1
        )
        width: bg.width
        height: bg.height
        Rectangle {
            id: bg
            radius: 10
            color: inlineBox.popupAccent
            border.color: Theme.backgroundTertiary
            border.width: 1
            // Horizontal expand from right to left
            width: Math.max(0, Math.round((collapsedRow.implicitWidth + 6) * inlineBox.openProgress))
            height: collapsedRow.implicitHeight + 6
            anchors.verticalCenter: parent.verticalCenter
            clip: true
        }
        Row {
            id: collapsedRow
            // Align to the right edge so reveal expands leftwards
            anchors.right: bg.right
            anchors.verticalCenter: bg.verticalCenter
            spacing: 4
            Repeater {
                model: systemTray.items
                delegate: Item {
                    width: 24 * Theme.scale(Screen)
                    height: 24 * Theme.scale(Screen)
                    visible: modelData
                    // Staggered reveal (train) from right to left
                    // Compute per-item progress based on actual revealed width of bg
                    property var i: (typeof index === 'number' ? index : 0)
                    property var n: (systemTray && systemTray.items ? systemTray.items.length : 0)
                    property real w: 24 * Theme.scale(Screen)
                    property real span: (w + collapsedRow.spacing)
                    // How many item slots could fit into the currently revealed width (minus padding)
                    property real revealedSlots: Math.max(0, (bg.width - 6) / Math.max(1, span))
                    // Right-most item (largest index) appears first as width grows
                    property real tRaw: (revealedSlots - (n - 1 - i))
                    property real t: Math.max(0, Math.min(1, tRaw))
                    opacity: t
                    x: Math.round((1 - t) * 12)
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

    // Collapsed trigger button (placed after inline box so it stays on the right when expanded)
    IconButton {
        id: collapsedButton
        z: 1002
        visible: collapsed
        anchors.verticalCenter: parent.verticalCenter
        // Keep compact size to match bar density
        size: 24 * Theme.scale(Screen)
        // Reduce rounding specifically for tray button (half of default 8)
        cornerRadius: 4
        icon: Settings.settings.collapsedTrayIcon || "expand_more"
        // Rotate to point towards tray content when expanded (left)
        iconRotation: expanded ? 90 : 0
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
            if (collapsed) inlineBox.openProgress = expanded ? 1 : 0;
        }
    }

    // Keep animation in sync if expanded changes from elsewhere (settings, etc.)
    onExpandedChanged: {
        if (collapsed) inlineBox.openProgress = expanded ? 1 : 0;
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
