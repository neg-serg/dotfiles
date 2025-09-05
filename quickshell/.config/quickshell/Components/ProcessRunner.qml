import QtQuick
import Quickshell.Io
import qs.Settings

// ProcessRunner: lightweight runner with optional JSON parsing and built-in restart/poll timers.
// Usage examples:
// - Streaming lines:
//   ProcessRunner { cmd: ["rsmetrx"]; backoffMs: Theme.networkRestartBackoffMs; onLine: (l)=> handle(l) }
// - Poll JSON:
//   ProcessRunner { cmd: ["bash","-lc","ip -j -br a"]; intervalMs: Theme.vpnPollMs; parseJson: true; onJson: (obj)=> handle(obj) }
Item {
    id: root
    // Command to execute
    property var cmd: []
    // Restart backoff after unexpected exit (ms)
    property int backoffMs: 1500
    // Optional polling interval (ms). When > 0, runs once per tick.
    property int intervalMs: 0
    // Parse stdout as JSON (single shot). When true, emits json(obj) on stream finish.
    property bool parseJson: false
    // Control whether to auto-restart on exit in streaming mode (intervalMs==0)
    property bool restartOnExit: true
    // Auto start when created
    property bool autoStart: true
    // Expose running state
    readonly property alias running: proc.running

    signal line(string s)
    signal json(var obj)

    // Streaming collector
    property int _consumed: 0

    // Backoff restart timer (for streaming processes)
    Timer {
        id: backoff
        interval: root.backoffMs
        repeat: false
        onTriggered: proc.running = true
    }

    // Poll timer (for JSON mode or periodic triggers)
    Timer {
        id: poll
        interval: Math.max(0, root.intervalMs)
        repeat: root.intervalMs > 0
        running: root.intervalMs > 0 && root.autoStart
        onTriggered: if (!proc.running) proc.running = true
    }

    Process {
        id: proc
        command: root.cmd
        running: root.intervalMs === 0 ? root.autoStart : false

        stdout: StdioCollector {
            waitForEnd: root.parseJson
            onTextChanged: {
                if (root.parseJson) return;
                const all = text;
                if (root._consumed >= all.length) return;
                const chunk = all.substring(root._consumed);
                root._consumed = all.length;
                let lines = chunk.split("\n");
                const last = lines.pop();
                if (last && !chunk.endsWith("\n")) {
                    root._consumed -= last.length;
                } else if (last) {
                    lines.push(last);
                }
                for (let l of lines) {
                    const s = (l || "").trim(); if (!s) continue; root.line(s);
                }
            }
            onStreamFinished: {
                if (!root.parseJson) return;
                try {
                    const obj = JSON.parse(text);
                    root.json(obj);
                } catch (e) { /* ignore parse errors */ }
            }
        }

        stderr: StdioCollector { waitForEnd: true }

        onExited: {
            root._consumed = 0;
            if (root.intervalMs > 0) {
                // In poll mode, rely on timer to retrigger
            } else {
                // Streaming mode: restart with backoff
                if (root.restartOnExit) backoff.restart();
            }
        }
    }

    function start() { proc.running = true }
    function stop()  { proc.running = false }
}
