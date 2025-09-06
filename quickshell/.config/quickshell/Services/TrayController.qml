pragma Singleton
import QtQuick
import qs.Settings

// TrayController: centralizes SystemTray guard/collapse timers and popup timings
// Exposes start/stop APIs and emits signals on elapse for consumers to react.
Item {
    id: root

    // Signals consumers can handle
    signal longHold()
    signal shortHold()
    signal collapseDelay()
    signal guardOff()

    // Public API
    function startLongHold()  { longHoldTimer.restart() }
    function stopLongHold()   { if (longHoldTimer.running) longHoldTimer.stop() }
    function startShortHold() { shortHoldTimer.restart() }
    function stopShortHold()  { if (shortHoldTimer.running) shortHoldTimer.stop() }
    function startCollapseDelay() { collapseDelayTimer.restart() }
    function stopCollapseDelay()  { if (collapseDelayTimer.running) collapseDelayTimer.stop() }
    function startGuard() { guardTimer.restart() }
    function stopGuard()  { if (guardTimer.running) guardTimer.stop() }

    // Timers use Theme tokens for durations; they rebind as Theme changes
    Timer {
        id: longHoldTimer
        interval: Theme.panelTrayLongHoldMs
        repeat: false
        onTriggered: root.longHold()
    }
    Timer {
        id: shortHoldTimer
        interval: Theme.panelTrayShortHoldMs
        repeat: false
        onTriggered: root.shortHold()
    }
    Timer {
        id: collapseDelayTimer
        interval: Theme.panelTrayOverlayDismissDelayMs
        repeat: false
        onTriggered: root.collapseDelay()
    }
    Timer {
        id: guardTimer
        interval: Theme.panelTrayGuardMs
        repeat: false
        onTriggered: root.guardOff()
    }

    // Expose tray-related popup timings/tokens
    // Tooltip delay used by tray tooltips
    property int tooltipDelayMs: Theme.tooltipDelayMs
    // Vertical offset for menus anchored to tray icons
    property int menuYOffset: Theme.panelMenuYOffset
    // Submenu gap (if used by tray menus)
    property int submenuGap: Theme.panelSubmenuGap
}
