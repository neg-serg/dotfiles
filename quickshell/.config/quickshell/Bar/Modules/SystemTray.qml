// qs/Bar/Modules/SystemTray.qml — DEBUG VARIANT
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Settings
import qs.Components

Row {
    id: root
    property var bar        // PanelWindow; coordinate space is bar.contentItem
    property var shell
    property var trayMenu   // QsMenuAnchor

    spacing: 8
    Layout.alignment: Qt.AlignVCenter

    // Debug flags
    property bool debug_force_center: true   // anchor at window center first
    property bool debug_disable_toggle: true // don't close on 2-й клик (исключим авто-закрытие)

    property bool menuIsOpen: false
    property var  lastMenuEntry: null

    function scale() : real { return Theme.scale(bar ? bar.screen : null) }

    Connections {
        target: trayMenu
        ignoreUnknownSignals: true
        function onOpened()  { root.menuIsOpen = true;  console.log("[tray] menu OPENED") }
        function onClosed()  { root.menuIsOpen = false; root.lastMenuEntry = null; console.log("[tray] menu CLOSED") }
    }

    // Debug anchor dot (shows where we try to open)
    Rectangle {
        id: anchorDot
        visible: true
        width: 6; height: 6; radius: 3
        color: "red"
        opacity: 0.7
        anchors.centerIn: undefined
        x: trayMenu ? trayMenu.anchor.rect.x - width/2 : 0
        y: trayMenu ? trayMenu.anchor.rect.y - height/2 : 0
    }

    function openNativeMenu(entry, iconItem) {
        if (!trayMenu) { console.warn("[tray] no trayMenu anchor"); return }
        if (!entry)    { console.warn("[tray] no entry"); return }

        console.log("[tray] try open:",
                    "hasMenu=", !!entry.hasMenu,
                    "menu=", !!entry.menu,
                    "title=", entry.title || entry.name || entry.id || "")

        if (!entry.hasMenu || !entry.menu) {
            console.warn("[tray] entry has no native menu; nothing to show")
            return
        }

        trayMenu.menu = entry.menu

        if (trayMenu.anchor.window !== bar && bar)
            trayMenu.anchor.window = bar

        const target = (bar && bar.contentItem) ? bar.contentItem : null
        if (!target) { console.warn("[tray] no bar.contentItem"); return }

        let ax, ay
        if (debug_force_center) {
            // Force obvious visible position: window center
            ax = Math.round((target.width  || 0) / 2)
            ay = Math.round((target.height || 0) / 2)
        } else if (iconItem) {
            // Normal placement near icon
            const pTopLeft = iconItem.mapToItem(target, 0, 0)
            const pBottom  = iconItem.mapToItem(target, 0, iconItem.height)
            const s = scale()
            const margin = Math.round(4 * s)
            const isBottom = (Settings.settings.panelPosition === "bottom")
            ax = Math.round(pTopLeft.x + iconItem.width / 2)
            ay = isBottom ? Math.round(pTopLeft.y - margin) : Math.round(pBottom.y + margin)
        } else {
            ax = 20; ay = 20
        }

        // Clamp inside window
        const w = target.width  || 0
        const h = target.height || 0
        ax = Math.min(Math.max(1, ax), w - 2)
        ay = Math.min(Math.max(1, ay), h - 2)

        trayMenu.anchor.rect.x = ax
        trayMenu.anchor.rect.y = ay
        trayMenu.anchor.rect.width  = 1
        trayMenu.anchor.rect.height = 1

        anchorDot.x = ax - anchorDot.width/2
        anchorDot.y = ay - anchorDot.height/2

        console.log("[tray] open at:", ax, ay, "win=", w, h)
        root.lastMenuEntry = entry
        Qt.callLater(() => trayMenu.open())
    }

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: traySlot
            property var entry: modelData

            width:  24 * root.scale()
            height: 24 * root.scale()
            visible: !!entry

            IconImage {
                id: trayIcon
                anchors.centerIn: parent
                width:  16 * root.scale()
                height: 16 * root.scale()
                smooth: false
                asynchronous: true
                backer.fillMode: Image.PreserveAspectFit
                source: {
                    const icon = entry?.icon || ""
                    if (!icon) return ""
                    if (icon.includes("?path=")) {
                        const [name, path] = icon.split("?path=")
                        const fileName = name.substring(name.lastIndexOf("/") + 1)
                        return `file://${path}/${fileName}`
                    }
                    return icon
                }
                opacity: status === Image.Ready ? 1 : 0
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                onClicked: (mouse) => {
                    if (!entry) return
                    if (mouse.button === Qt.RightButton) {
                        // ВАЖНО: временно не закрываем сами (чтобы исключить «само-закрытие»)
                        if (!root.debug_disable_toggle && root.menuIsOpen && root.lastMenuEntry === entry) {
                            trayMenu.close()
                            return
                        }
                        openNativeMenu(entry, trayIcon)
                    } else if (mouse.button === Qt.LeftButton) {
                        if (!entry.onlyMenu && typeof entry.activate === "function")
                            entry.activate()
                    } else if (mouse.button === Qt.MiddleButton) {
                        if (typeof entry.secondaryActivate === "function")
                            entry.secondaryActivate()
                    }
                }
            }

            StyledTooltip {
                text: entry.tooltipTitle || entry.name || entry.id || "Tray Item"
                positionAbove: false
                tooltipVisible: false
                targetItem: trayIcon
                delay: 200
            }
        }
    }
}
