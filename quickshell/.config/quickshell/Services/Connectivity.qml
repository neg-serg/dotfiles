pragma Singleton
import QtQuick
import qs.Settings
import qs.Components
import "../Helpers/Utils.js" as Utils

// Connectivity: shared networking signals/state
// - hasLink: any non-loopback interface up (or UNKNOWN with address)
// - hasInternet: ping 1.1.1.1 reachable
// - interfaces: last JSON array from `ip -j -br a`
// - rxKiBps / txKiBps: live rates from `rsmetrx` stream
Item {
    id: root

    // Link + reachability
    property bool hasLink: false
    property bool hasInternet: false
    property var  interfaces: []

    // Traffic rates (KiB/s)
    property real rxKiBps: 0
    property real txKiBps: 0

    // Fast ping mode after link up: 500ms interval for 10s
    property bool fastMode: false
    readonly property int  fastIntervalMs: 500
    readonly property int  fastDurationMs: 10000

    // When link comes up, check internet immediately
    onHasLinkChanged: {
        if (root.hasLink) {
            inetProbe.start();
            // Engage fast mode to detect internet quickly
            root.fastMode = true;
        } else {
            root.hasInternet = false;
        }
    }

    // When internet is detected, leave fast mode
    onHasInternetChanged: {
        if (root.hasInternet) root.fastMode = false;
    }

    // --- Link detection via `ip -j -br a`
    Timer {
        id: linkPoll
        interval: Theme.networkLinkPollMs
        repeat: true
        running: true
        onTriggered: if (!linkProbe.running) linkProbe.start()
    }
    ProcessRunner {
        id: linkProbe
        cmd: ["bash", "-lc", "ip -j -br a"]
        parseJson: true
        autoStart: false
        restartOnExit: false
        onJson: (arr) => {
            try {
                root.interfaces = Array.isArray(arr) ? arr : []
                let up = false
                for (let it of root.interfaces) {
                    const name = (it && it.ifname) ? String(it.ifname) : ""
                    if (!name || name === "lo") continue
                    const state = (it && it.operstate) ? String(it.operstate) : ""
                    const addrs = Array.isArray(it?.addr_info) ? it.addr_info : []
                    if (state === "UP" || (state === "UNKNOWN" && addrs.length > 0)) { up = true; break }
                }
                root.hasLink = up
            } catch (e) { /* ignore */ }
        }
    }

    // --- Internet reachability via ping
    Timer {
        id: inetPoll
        interval: (function(){ var v = Utils.coerceInt(Settings.settings.networkPingIntervalMs, 30000); return Utils.clamp(v, 1000, 600000); })()
        repeat: true
        running: !root.fastMode
        onTriggered: {
            if (!root.hasLink) { root.hasInternet = false; return }
            if (!inetProbe.running) inetProbe.start()
        }
    }
    ProcessRunner {
        id: inetProbe
        cmd: ["bash", "-lc", "ping -n -c1 -W1 1.1.1.1 >/dev/null && echo OK || echo FAIL"]
        autoStart: false
        restartOnExit: false
        onLine: (line) => { const ok = String(line||"").trim().indexOf("OK") !== -1; root.hasInternet = ok }
    }

    // --- rsmetrx streaming (JSON lines: { rx_kib_s, tx_kib_s })
    ProcessRunner {
        id: rsStream
        cmd: ["rsmetrx"]
        backoffMs: Theme.networkRestartBackoffMs
        onLine: (line) => {
            try {
                const data = JSON.parse(line)
                if (typeof data.rx_kib_s === "number") root.rxKiBps = data.rx_kib_s
                if (typeof data.tx_kib_s === "number") root.txKiBps = data.tx_kib_s
            } catch (e) { /* ignore */ }
        }
    }

    // Fast ping timers
    Timer {
        id: fastInetPoll
        interval: root.fastIntervalMs
        repeat: true
        running: root.fastMode
        onTriggered: {
            if (!root.hasLink) return;
            inetProbe.start();
        }
    }
    Timer {
        id: fastStop
        interval: root.fastDurationMs
        repeat: false
        running: root.fastMode
        onTriggered: root.fastMode = false
    }

    // Kick initial link detection quickly on startup
    Component.onCompleted: { linkProbe.start() }
}
