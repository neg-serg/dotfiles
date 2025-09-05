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
    // Track whether pointer is anywhere over the bar panel
    property bool panelHover: false
    // Track whether pointer is in external hot zone (from Bar)
    property bool hotHover: false
    // Keep tray open for a while after menu close (long hold)
    property bool holdOpen: false
    // Short hold after leaving hot zone without interacting
    property bool shortHoldActive: false

    // Long hold timer (menu close): keep for 2.5 seconds
    Timer {
        id: longHoldTimer
        interval: Theme.panelTrayLongHoldMs
        repeat: false
        onTriggered: {
            root.holdOpen = false;
            root.expanded = false;
        }
    }
    // Short hold timer (hover leave): keep for 1.5 seconds
    Timer {
        id: shortHoldTimer
        interval: Theme.panelTrayShortHoldMs
        repeat: false
        onTriggered: { root.shortHoldActive = false; if (!root.panelHover && !root.hotHover && !root.holdOpen) root.expanded = false }
    }

    onHotHoverChanged: {
        if (hotHover) {
            // entering hot zone: ensure open and cancel short hold
            shortHoldTimer.stop();
            shortHoldActive = false;
            expanded = true;
        } else {
            // leaving hot zone: start short hold if not on panel and not menu/long-hold
            const menuOpen = trayMenu && trayMenu.visible;
            if (!panelHover && !menuOpen && !holdOpen) {
                shortHoldActive = true;
                shortHoldTimer.restart();
            }
        }
    }
    property var shell
    // Screen for overlay placement (set from Bar/Bar.qml)
    property var screen
    property var trayMenu
    // Track programmatic overlay dismiss to distinguish outside-click
    property bool programmaticOverlayDismiss: false
    // Delay collapse after outside click (ms)
    Timer { id: collapseDelayTimer; interval: Theme.panelTrayOverlayDismissDelayMs; repeat: false; onTriggered: root.expanded = false }
    function dismissOverlayNow() { root.programmaticOverlayDismiss = true; trayOverlay.dismiss(); root.programmaticOverlayDismiss = false }
    spacing: Math.round(Theme.panelRowSpacing * Theme.scale(Screen))
    Layout.alignment: Qt.AlignVCenter

    property bool containsMouse: false
    property var systemTray: SystemTray

    // Collapse/expand behavior from settings
    property bool collapsed: Settings.settings.collapseSystemTray
    property bool expanded: false
    // Guard to avoid immediate close from the same click that opened
    property bool openGuard: false
    Timer { id: guardTimer; interval: Theme.panelTrayGuardMs; repeat: false; onTriggered: openGuard = false }

    // Note: we purposely avoid a full overlay here to prevent immediate close issues in Row
    // Overlay to close tray on outside clicks (Hyprland): separate layer window
    PanelWithOverlay {
        id: trayOverlay
        screen: root.screen
        visible: false
        showOverlay: false
        overlayColor: showOverlay ? Theme.overlayStrong : "transparent"
        // When overlay is dismissed by outside click, collapse tray
        onVisibleChanged: {
            if (!visible) {
                if (trayMenu && trayMenu.visible) trayMenu.hideMenu();
                if (root.expanded) {
                    // Do not collapse if we are holding open or hovering hot zone/panel or menu is visible
                    if (root.holdOpen || root.hotHover || root.panelHover || (trayMenu && trayMenu.visible)) {
                        // keep open
                    } else {
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
    }

    // Inline expanded content that participates in Row layout (shifts neighbors)
    Item {
        id: inlineBox
        // Show only when expanded (no animation)
        visible: expanded
        anchors.verticalCenter: parent.verticalCenter
        // Background behind inline tray icons (match bar background)
        width: bg.width
        height: bg.height
        Rectangle {
            id: bg
            radius: Theme.cornerRadiusSmall
            color: Theme.background
            border.color: Theme.borderSubtle
            border.width: Theme.uiBorderWidth
            // No animated width — show full content immediately
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
                                    const menuY = height + Math.round(Theme.panelMenuYOffset * Theme.scale(Screen));
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

    // External hover hot-zone is added in Bar/Bar.qml (to be right of media/volume)

    // Collapsed trigger button (placed after inline box so it stays on the right when expanded)
    IconButton {
        id: collapsedButton
        z: 1002
        visible: false // hidden; tray reveals by hover in bottom-right hot zone
        anchors.verticalCenter: parent.verticalCenter
        // Keep compact size to match bar density
        size: Math.round(Theme.panelIconSize * Theme.scale(Screen))
        // Reduce rounding specifically for tray button (half of default 8)
        cornerRadius: Theme.cornerRadiusSmall
        icon: Settings.settings.collapsedTrayIcon || "expand_more"
        // Rotate to point towards tray content when expanded (left)
        iconRotation: expanded ? 90 : 0
        // Use derived accent token for hover/active
        accentColor: Theme.accentHover
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

    // React to menu visibility to enforce hold-open behavior
    Connections {
        target: trayMenu
        function onVisibleChanged() {
            if (!trayMenu) return;
            if (trayMenu.visible) {
                // While menu is open, keep tray expanded and prevent auto-collapse
                root.expanded = true;
                root.holdOpen = true;
                longHoldTimer.stop();
                shortHoldTimer.stop();
                root.shortHoldActive = false;
            } else {
                // After menu closes, keep open for the same timeout
                root.holdOpen = true;
                longHoldTimer.restart();
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
                            const menuY = height + Math.round(Theme.panelMenuYOffset * Theme.scale(Screen));
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
                delay: Theme.tooltipDelayMs
            }

            Component.onDestruction:
            // No cache cleanup needed
            {}
        }
    }
}
