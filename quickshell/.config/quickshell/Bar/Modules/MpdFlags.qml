import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Settings
import qs.Services
import qs.Components
import "../../Helpers/Utils.js" as Utils

Item {
    id: root
    property bool enabled: false
    // Polling even when not enabled but MPD is current player
    property int  fallbackIntervalMs: Theme.mpdFlagsFallbackMs
    // Colors from theme for readability on panel background
    property color iconColor: Theme.textPrimary
    property int iconPx: Math.round(Theme.fontSizeSmall * Theme.scale(Screen))
    // Prefer mpc; fallback to rmpc
    property string cmd: "(mpc status || rmpc status)"
    property var activeFlags: [] // [{ key, icon, title }]
    property string mpdState: "unknown" // playing | paused | stopped | unknown
    // Background padding
    property int padX: Math.round(Theme.panelRowSpacingSmall * Theme.scale(Screen))
    property int padY: Math.round(Theme.uiGapTiny * Theme.scale(Screen))
    property int radius: Math.round(Theme.cornerRadiusSmall * Theme.scale(Screen))
    implicitWidth: content.implicitWidth + 2 * padX
    implicitHeight: Utils.clamp(content.implicitHeight + 2 * padY, iconPx + 2 * padY, content.implicitHeight + 2 * padY)
    // Ensure the item actually occupies its implicit size
    width: implicitWidth
    height: implicitHeight
    visible: enabled && activeFlags.length > 0

    function parseStatus(text) {
        try {
            const s = String(text || "");
            // Prefer JSON (rmpc); fallback to text (mpc)
            var trimmed = s.trim();
            const flags = [];
            function pushFlag(ok, key, icon, title) { if (ok) flags.push({ key, icon, title }); }
            function isOn(v) {
                var t = String(v).toLowerCase();
                return t === "on" || t === "1" || t === "true" || t === "one";
            }
            if (trimmed.startsWith("{") || trimmed.startsWith("[")) {
                // JSON mode
                var obj = JSON.parse(trimmed);
                // Normalize variants
                var stv = (obj.state || obj.State || "").toString().toLowerCase();
                if (!stv && obj.mpd && obj.mpd.state) stv = String(obj.mpd.state).toLowerCase();
                mpdState = stv || "unknown";
                pushFlag(!!obj.repeat, "repeat", "repeat", "Repeat");
                pushFlag(!!obj.random, "random", "shuffle", "Random");
                var sglv = (obj.single !== undefined) ? obj.single : (obj.options && obj.options.single);
                pushFlag(isOn(sglv), "single", "repeat_one", "Single");
                var conv = (obj.consume !== undefined) ? obj.consume : (obj.options && obj.options.consume);
                pushFlag(isOn(conv), "consume", "auto_delete", "Consume");
                var xf = (obj.xfade !== undefined && obj.xfade !== null) ? obj.xfade : (obj.options && obj.options.xfade);
                var xfOn = false;
                if (typeof xf === 'number') xfOn = xf > 0; else if (xf !== undefined && xf !== null) xfOn = !/^0$|^off$/i.test(String(xf));
                pushFlag(xfOn, "xfade", "blur_linear", "Crossfade");
            } else {
                // Text mode
                var st = "unknown";
                var mbr = trimmed.match(/\[(playing|paused|stopped)\]/i);
                if (mbr && mbr[1]) st = String(mbr[1]).toLowerCase();
                var mst = trimmed.match(/\bstate:\s*(playing|paused|stopped)\b/i);
                if (mst && mst[1]) st = String(mst[1]).toLowerCase();
                mpdState = st;
                const rep = /\brepeat:\s*(on|off|1|0)\b/i.exec(trimmed);
                const rnd = /\brandom:\s*(on|off|1|0)\b/i.exec(trimmed);
                const sgl = /\bsingle:\s*(on|off|1|0)\b/i.exec(trimmed);
                const con = /\bconsume:\s*(on|off|1|0)\b/i.exec(trimmed);
                const xfd = /\b(?:xfade|crossfade):\s*([0-9]+|on|off)\b/i.exec(trimmed);
                pushFlag(rep && isOn(rep[1]), "repeat", "repeat", "Repeat");
                pushFlag(rnd && isOn(rnd[1]), "random", "shuffle", "Random");
                pushFlag(sgl && isOn(sgl[1]), "single", "repeat_one", "Single");
                pushFlag(con && isOn(con[1]), "consume", "auto_delete", "Consume");
                pushFlag(xfd && !/^0$|^off$/i.test(xfd[1]), "xfade", "blur_linear", "Crossfade");
            }
            activeFlags = flags;
        } catch (e) {
            activeFlags = [];
        }
    }

    function refresh() {
        try {
            if (!proc.running) proc.running = true
        } catch (e) { }
    }

    function isMpd() {
        try {
            const p = MusicManager.currentPlayer;
            if (!p) return false;
            const n = String(p.identity || p.name || p.id || "").toLowerCase();
            return /(mpd|mpdris)/.test(n);
        } catch (e) { return false; }
    }

    // One-shot status parser
    ProcessRunner {
        id: proc
        cmd: ["bash", "-lc", root.cmd + " 2>/dev/null || true"]
        autoStart: false
        restartOnExit: false
        // Consume entire output via onLine accumulation; sufficient for our parser
        property string _buf: ""
        onLine: (s) => { _buf += (s + "\n") }
        onExited: (code, status) => { root.parseStatus(_buf); _buf = "" }
    }

    // Updates via MPD idle on 'options' subsystem
    ProcessRunner {
        id: idle
        // Prefer mpc; fallback to rmpc
        cmd: ["bash", "-lc", "mpc -q idle options player 2>/dev/null || rmpc -q idle options player 2>/dev/null || true"]
        restartOnExit: true
        backoffMs: 250
        onExited: (code, status) => {
            if (root.enabled) proc.start()
        }
    }

    // Fallback polling if idle misses or unsupported
    Timer {
        id: fallback
        interval: root.fallbackIntervalMs
        repeat: true
        // Only when enabled
        running: root.enabled
        onTriggered: { root.refresh() }
    }

    // Control lifecycle
    Component.onCompleted: { if (enabled) { proc.start(); idle.start(); } }
    onEnabledChanged: {
        if (enabled) {
            activeFlags = [];
            proc.start();
            idle.start();
        } else {
            idle.stop();
            activeFlags = [];
        }
    }

    // Icon row
    Row {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.padX
        anchors.rightMargin: root.padX
        anchors.topMargin: root.padY
        anchors.bottomMargin: root.padY
        spacing: Math.round(Theme.panelRowSpacingSmall * Theme.scale(Screen))
        Repeater {
            model: activeFlags
            delegate: MaterialIcon {
                icon: modelData.icon
                color: root.iconColor
                size: root.iconPx
                opacity: Theme.uiIconEmphasisOpacity
            }
        }
    }
}
