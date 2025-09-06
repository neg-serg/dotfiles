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
    property bool parseJson: false
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

        onExited: function(exitCode, exitStatus) {
            root._consumed = 0;
            root.exited(exitCode, exitStatus);
            if (root.intervalMs === 0 && root.restartOnExit) backoff.restart();
        }
    }

    function start() { proc.running = true }
    function stop()  { proc.running = false }
}
