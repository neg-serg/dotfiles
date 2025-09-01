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
    // Screen for overlay placement (set from Bar/Bar.qml)
    property var screen
    property var trayMenu
    // Track programmatic overlay dismiss to distinguish outside-click
    property bool programmaticOverlayDismiss: false
    // Delay collapse after outside click (ms)
    Timer { id: collapseDelayTimer; interval: 5000; repeat: false; onTriggered: root.expanded = false }
    function dismissOverlayNow() { root.programmaticOverlayDismiss = true; trayOverlay.dismiss(); root.programmaticOverlayDismiss = false }
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
    // Overlay to close tray on outside clicks (Hyprland): separate layer window
    PanelWithOverlay {
        id: trayOverlay
        screen: root.screen
        visible: false
        showOverlay: false
        overlayColor: showOverlay ? Qt.rgba(0, 0, 0, 0.5) : "transparent"
        // When overlay is dismissed by outside click, collapse tray
        onVisibleChanged: {
            if (!visible) {
                if (trayMenu && trayMenu.visible) trayMenu.hideMenu();
                if (root.expanded) {
                    // Start delayed collapse only for outside-click dismiss
                    if (!root.programmaticOverlayDismiss) {
                        collapseDelayTimer.restart();
                    } else {
                        if (collapseDelayTimer.running) collapseDelayTimer.stop();
                        root.expanded = false;
                    }
                }
            }
        }
    }

    // Inline expanded content that participates in Row layout (shifts neighbors)
    Item {
        id: inlineBox
        // Show only when expanded (no animation)
        visible: collapsed && expanded
        anchors.verticalCenter: parent.verticalCenter
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
            radius: 0
            color: inlineBox.popupAccent
            border.color: "transparent"
            border.width: 0
            // No animated width — show full content immediately
            width: collapsedRow.implicitWidth + 6
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
                    // No per-icon animation; show immediately
                    opacity: 1
                    x: 0
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
                                root.dismissOverlayNow();
                            } else if (mouse.button === Qt.MiddleButton) {
                                if (trayMenu && trayMenu.visible) trayMenu.hideMenu();
                                modelData.secondaryActivate && modelData.secondaryActivate();
                                expanded = false;
                                root.dismissOverlayNow();
                            } else if (mouse.button === Qt.RightButton) {
                                if (trayMenu && trayMenu.visible) { trayMenu.hideMenu(); root.dismissOverlayNow(); return; }
                                if (modelData.hasMenu && modelData.menu && trayMenu) {
                                    const menuX = (width / 2) - (trayMenu.width / 2);
                                    const menuY = height + 20 * Theme.scale(Screen);
                                    trayMenu.menu = modelData.menu;
                                    trayMenu.showAt(parent, menuX, menuY);
                                    trayOverlay.show();
                                    try { trayOverlay.showOverlay = true; } catch (e) {}
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
            if (expanded) { trayOverlay.show(); try { trayOverlay.showOverlay = false; } catch (e) {} }
            else root.dismissOverlayNow();
        }
    }

    // If expanded state changes externally, keep overlay/menu state consistent
    onExpandedChanged: {
        if (!expanded) {
            if (trayMenu && trayMenu.visible) trayMenu.hideMenu();
            root.dismissOverlayNow();
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
                            trayOverlay.dismiss();
                            return;
                        }

                        if (modelData.hasMenu && modelData.menu && trayMenu) {
                            // Anchor the menu to the tray icon item (parent) and position it below the icon
                            const menuX = (width / 2) - (trayMenu.width / 2);
                            const menuY = height + 20 * Theme.scale(Screen);
                            trayMenu.menu = modelData.menu;
                            trayMenu.showAt(parent, menuX, menuY);
                            trayOverlay.show();
                            try { trayOverlay.showOverlay = false; } catch (e) {}
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
