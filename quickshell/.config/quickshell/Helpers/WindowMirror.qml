import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: windowMirror

    // Collected monitor and client information
    property var  monitors: []
    property var  clients: []
    property real _panelHeight: 0

    // Processes used for querying geometry and moving windows
    property Process getMonitors: Process {
        command: ["bash", "-lc", "hyprctl -j monitors"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    windowMirror.monitors = JSON.parse(text)
                } catch (_) {
                    windowMirror.monitors = []
                }
                windowMirror.getClients.running = true
            }
        }
    }

    property Process getClients: Process {
        command: ["bash", "-lc", "hyprctl -j clients"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    windowMirror.clients = JSON.parse(text)
                } catch (_) {
                    windowMirror.clients = []
                }
                Qt.callLater(windowMirror.apply)
            }
        }
    }

    property Process mover: Process {}

    // Entry point used by the shell to mirror all windows
    function mirror(panelHeight) {
        windowMirror._panelHeight = panelHeight || 0
        windowMirror.getMonitors.running = true
    }

    // Apply the mirrored coordinates in a single batch
    function apply() {
        if (windowMirror._panelHeight <= 0)
            return

        const cmds = []
        for (const c of windowMirror.clients) {
            // Skip floating and fullscreen windows
            if (c.floating || c.fullscreen)
                continue

            const mon = windowMirror.monitors.find(m => m.id === c.monitor)
            if (!mon)
                continue

            const screenHeight = mon.size[1]
            const newY = screenHeight - c.at[1] - c.size[1] + windowMirror._panelHeight
            cmds.push(`dispatch movewindowpixel exact ${c.at[0]} ${newY},address:${c.address}`)
        }

        if (cmds.length) {
            // Use --batch so Hyprland applies everything atomically
            windowMirror.mover.command = ["bash", "-lc", 'hyprctl --batch "' + cmds.join('; ') + '"']
            windowMirror.mover.running = true
        }
    }
}
