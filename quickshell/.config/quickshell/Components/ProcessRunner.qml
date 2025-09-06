import QtQuick
import Quickshell.Io
import qs.Settings

// ProcessRunner: run a process (streaming lines or poll JSON) with backoff/poll timers.
// Examples: streaming — ProcessRunner { cmd: ["rsmetrx"], backoffMs: Theme.networkRestartBackoffMs, onLine: (l)=>handle(l) }
//           poll JSON — ProcessRunner { cmd: ["bash","-lc","ip -j -br a"], intervalMs: Theme.vpnPollMs, parseJson: true, onJson: (o)=>handle(o) }
Item {
    id: root
    property var cmd: []
    property int backoffMs: 1500
    property var env: null
    property int intervalMs: 0
    // Parse entire stdout as JSON once (on process end)
    property bool parseJson: false
    // Parse each line as JSON (streaming); falls back to line signal on parse failure
    property bool jsonLine: false
    // Debounce emission of line/jsonLine events (ms); 0 = emit immediately
    property int debounceMs: 0
    // Restart policy on exit when intervalMs == 0: 'always' or 'never'.
    // Backward-compat: if empty, fallback to restartOnExit boolean.
    property string restartMode: ""
    // Backward-compat flag (deprecated). Use restartMode instead.
    property bool restartOnExit: true
    property bool autoStart: true
    readonly property alias running: proc.running

    signal line(string s)
    signal json(var obj)
    signal exited(int code, int status)

    property int _consumed: 0

    Timer {
        id: backoff
        interval: root.backoffMs
        repeat: false
        onTriggered: proc.running = true
    }

    Timer {
        id: poll
        interval: Math.max(0, root.intervalMs)
        repeat: root.intervalMs > 0
        running: root.intervalMs > 0 && root.autoStart
        onTriggered: if (!proc.running) proc.running = true
    }

    // Debounce buffer for streaming output
    property string _pendingTail: ""
    property var _pendingLines: []
    Timer {
        id: debounce
        interval: Math.max(1, root.debounceMs)
        repeat: false
        onTriggered: root._flushPending()
    }

    Process {
        id: proc
        command: root.cmd
        environment: (root.env && typeof root.env === 'object') ? root.env : ({})
        running: root.intervalMs === 0 ? root.autoStart : false

        stdout: StdioCollector {
            waitForEnd: root.parseJson
            onTextChanged: {
                if (root.parseJson) return;
                const all = text;
                if (root._consumed >= all.length) return;
                const chunk = all.substring(root._consumed);
                // Combine with tail and split into lines
                const combined = root._pendingTail + chunk;
                let lines = combined.split("\n");
                // Last element is tail (may be empty if chunk ended with \n)
                root._pendingTail = lines.pop() || "";
                // Update consumed to leave tail for next time
                root._consumed = all.length - root._pendingTail.length;
                // Stash lines for debounced flush
                for (let i = 0; i < lines.length; i++) {
                    const s = (lines[i] || "").trim();
                    if (!s) continue;
                    root._pendingLines.push(s);
                }
                if (root.debounceMs > 0) {
                    debounce.restart();
                } else {
                    root._flushPending();
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

        onExited: function(exitCode, exitStatus) {
            root._consumed = 0;
            root._pendingTail = "";
            root.exited(exitCode, exitStatus);
            function _shouldRestart() {
                var m = String(root.restartMode || "").toLowerCase();
                if (m === 'always') return true;
                if (m === 'never') return false;
                // Fallback to legacy flag
                return !!root.restartOnExit;
            }
            if (root.intervalMs === 0 && _shouldRestart()) backoff.restart();
        }
    }

    function start() { proc.running = true }
    function stop()  { proc.running = false }

    function _flushPending() {
        if (!root._pendingLines || root._pendingLines.length === 0) return;
        try {
            for (let i = 0; i < root._pendingLines.length; i++) {
                const s = root._pendingLines[i];
                if (root.jsonLine) {
                    try {
                        const obj = JSON.parse(s);
                        root.json(obj);
                        continue;
                    } catch (e) { /* fall through to line */ }
                }
                root.line(s);
            }
        } finally {
            root._pendingLines = [];
        }
    }
}
