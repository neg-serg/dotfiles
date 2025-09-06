import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Settings
import qs.Components
import qs.Services as Services

Row {
    id: root
    property bool panelHover: false
    property bool hotHover: false
    property bool holdOpen: false
    property bool shortHoldActive: false

    // Timers centralized in TrayController service
    Connections {
        target: Services.TrayController
        function onLongHold() { root.holdOpen = false; root.expanded = false }
        function onShortHold() { root.shortHoldActive = false; if (!root.panelHover && !root.hotHover && !root.holdOpen) root.expanded = false }
        function onCollapseDelay() { root.expanded = false }
        function onGuardOff() { root.openGuard = false }
    }

    onHotHoverChanged: {
        if (hotHover) {
            Services.TrayController.stopShortHold();
            shortHoldActive = false;
            expanded = true;
        } else {
            const menuOpen = trayMenu && trayMenu.visible;
            if (!panelHover && !menuOpen && !holdOpen) {
                shortHoldActive = true;
                Services.TrayController.startShortHold();
            }
        }
    }
    property var shell
    property var screen
    property var trayMenu
    property bool programmaticOverlayDismiss: false
    // Collapse delay handled by TrayController service
    function dismissOverlayNow() { root.programmaticOverlayDismiss = true; trayOverlay.dismiss(); root.programmaticOverlayDismiss = false }
    spacing: Math.round(Theme.panelRowSpacing * Theme.scale(Screen))
    Layout.alignment: Qt.AlignVCenter

    property bool containsMouse: false
    property var systemTray: SystemTray

    property bool collapsed: Settings.settings.collapseSystemTray
    property bool expanded: false
    property bool openGuard: false

    PanelWithOverlay {
        id: trayOverlay
        screen: root.screen
        visible: false
        showOverlay: false
        overlayColor: showOverlay ? Theme.overlayStrong : "transparent"
        onVisibleChanged: {
            if (!visible) {
                if (trayMenu && trayMenu.visible) trayMenu.hideMenu();
                if (root.expanded) {
                    if (root.holdOpen || root.hotHover || root.panelHover || (trayMenu && trayMenu.visible)) {
                    } else {
                        if (!root.programmaticOverlayDismiss) {
                            Services.TrayController.startCollapseDelay();
                        } else {
                            Services.TrayController.stopCollapseDelay();
                            root.expanded = false;
                        }
                    }
                }
            }
        }
    }

    // Inline expanded content that participates in Row layout (shifts neighbors)
    Item {
        id: inlineBox
        visible: expanded
        anchors.verticalCenter: parent.verticalCenter
        width: bg.width
        height: bg.height
        Rectangle {
            id: bg
            radius: Theme.cornerRadiusSmall
            color: Theme.background
            border.color: Theme.borderSubtle
            border.width: Theme.uiBorderWidth
            width: collapsedRow.implicitWidth + Theme.panelTrayInlinePadding
            height: collapsedRow.implicitHeight + Theme.panelTrayInlinePadding
            anchors.verticalCenter: parent.verticalCenter
            clip: true
        }

        // Hover area over the inline box to keep it open while cursor is inside
        MouseArea {
            id: inlineHoverArea
            anchors.fill: bg
            z: 999
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: expanded = true
            onExited: {
                if (!root.panelHover && !root.hotHover && !root.holdOpen && !root.shortHoldActive) expanded = false
            }
        }
        Row {
            id: collapsedRow
            // Align to the right edge so reveal expands leftwards
            anchors.right: bg.right
            anchors.verticalCenter: bg.verticalCenter
            spacing: Math.round(Theme.panelRowSpacingSmall * Theme.scale(Screen))
            Repeater {
                model: systemTray.items
                delegate: Item {
                    width: Math.round(Theme.panelIconSize * Theme.scale(Screen))
                    height: Math.round(Theme.panelIconSize * Theme.scale(Screen))
                    visible: modelData
                    // No per-icon animation; show immediately
                    opacity: 1
                    x: 0
                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.round(Theme.panelIconSizeSmall * Theme.scale(Screen))
                        height: Math.round(Theme.panelIconSizeSmall * Theme.scale(Screen))
                        radius: Theme.cornerRadiusSmall
                        // Use a dark overlay for hover to avoid white-ish look
                        color: trayItemMouseArea.containsMouse ? Theme.overlayWeak : "transparent"
                        clip: true
                        TrayIcon {
                            id: icon
                            anchors.centerIn: parent
                            size: Math.round(Theme.panelIconSizeSmall * Theme.scale(Screen))
                            source: modelData?.icon || ""
                            grayscale: trayOverlay.visible
                            opacity: ready ? 1 : 0
                        }
                    }
                    MouseArea {
                        id: trayItemMouseArea
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
                                    const menuY = height + Math.round(Services.TrayController.menuYOffset * Theme.scale(Screen));
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

    // Collapsed trigger button (placed after inline box)
    IconButton {
        id: collapsedButton
        z: 1002
        visible: false // hidden; tray reveals by hover in bottom-right hot zone
        anchors.verticalCenter: parent.verticalCenter
        size: Math.round(Theme.panelIconSize * Theme.scale(Screen))
        cornerRadius: Theme.cornerRadiusSmall
        icon: Settings.settings.collapsedTrayIcon || "expand_more"
        iconRotation: expanded ? 90 : 0
        accentColor: Theme.accentHover
        iconNormalColor: Theme.textPrimary
        iconHoverColor: Theme.textPrimary
        onClicked: {
            expanded = !expanded;
            if (expanded) { openGuard = true; Services.TrayController.startGuard(); }
            if (expanded) { trayOverlay.show(); try { trayOverlay.showOverlay = false; } catch (e) {} }
            else root.dismissOverlayNow();
        }
    }

    onExpandedChanged: {
        if (!expanded) {
            if (trayMenu && trayMenu.visible) trayMenu.hideMenu();
            root.dismissOverlayNow();
        }
    }

    Connections {
        target: trayMenu
        function onVisibleChanged() {
            if (!trayMenu) return;
            if (trayMenu.visible) {
                root.expanded = true;
                root.holdOpen = true;
                Services.TrayController.stopLongHold();
                Services.TrayController.stopShortHold();
                root.shortHoldActive = false;
            } else {
                root.holdOpen = true;
                Services.TrayController.startLongHold();
            }
        }
    }


    // Inline icons (disabled: we show tray only via hover hot zone)
    Repeater {
        // Disabled always to avoid duplicate inline tray; use inlineBox above
        model: 0
        delegate: Item {
            width: Math.round(Theme.panelIconSize * Theme.scale(Screen))
            height: Math.round(Theme.panelIconSize * Theme.scale(Screen))

            visible: modelData
            property bool isHovered: trayMouseArea.containsMouse

            // No animations - static display

            Rectangle {
                anchors.centerIn: parent
                width: Math.round(Theme.panelIconSizeSmall * Theme.scale(Screen))
                height: Math.round(Theme.panelIconSizeSmall * Theme.scale(Screen))
                radius: Theme.cornerRadiusSmall
                color: "transparent"
                clip: true

                TrayIcon {
                    id: trayIcon
                    anchors.centerIn: parent
                    size: Math.round(Theme.panelIconSizeSmall * Theme.scale(Screen))
                    source: modelData?.icon || ""
                    grayscale: trayOverlay.visible
                    opacity: ready ? 1 : 0
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
                            const menuY = height + Math.round(Services.TrayController.menuYOffset * Theme.scale(Screen));
                            trayMenu.menu = modelData.menu;
                            trayMenu.showAt(parent, menuX, menuY);
                            trayOverlay.show();
                            try { trayOverlay.showOverlay = false; } catch (e) {}
                        } else
                        
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
                delay: Services.TrayController.tooltipDelayMs
            }

            Component.onDestruction:
            // No cache cleanup needed
            {}
        }
    }
}
