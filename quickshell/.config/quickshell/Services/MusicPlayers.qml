import QtQuick
import QtQml
import qs.Settings
import Quickshell.Services.Mpris

// Non-visual helper that tracks available MPRIS players and exposes currentPlayer
// Player selection policy
// - Configured via Settings.settings.playerSelectionPriority (array of rules)
// - Supported rules (checked in order until a match):
//   "mpdPlaying"  -> most-recent MPD that is currently playing
//   "anyPlaying"  -> most-recent player that is currently playing (any backend)
//   "mpdRecent"   -> most-recent MPD (regardless of playing)
//   "recent"      -> most-recent player (regardless of playing)
//   "manual"      -> respect manually selected index if within range
//   "first"       -> fallback to the first available
// Examples:
//   ["manual","recent","first"]
//   ["anyPlaying","mpdPlaying","manual","first"]
Item {
    id: root

    // Public API
    property var currentPlayer: null
    property int selectedPlayerIndex: 0
    property bool hasPlayer: getAvailablePlayers().length > 0
    // LIFO of last active players by id (most recent first)
    property var _lastActiveStack: []

    function playerId(p) {
        try {
            if (!p) return "";
            return String(p.service || p.busName || p.name || p.identity || "");
        } catch (e) { return ""; }
    }

    function isPlayerMpd(p) {
        try {
            if (!p) return false;
            var idStr    = String((p.service || p.busName || "")).toLowerCase();
            var nameStr  = String(p.name || "").toLowerCase();
            var identStr = String(p.identity || "").toLowerCase();
            var re = /(mpd|mpdris|mopidy|music\s*player\s*daemon)/;
            return re.test(idStr) || re.test(nameStr) || re.test(identStr);
        } catch (e) { return false; }
    }

    function touchActive(p) {
        try {
            var id = playerId(p);
            if (!id) return;
            // Move to front (dedupe)
            var arr = _lastActiveStack || [];
            var idx = arr.indexOf(id);
            if (idx !== -1) arr.splice(idx, 1);
            arr.unshift(id);
            _lastActiveStack = arr;
        } catch (e) {}
    }

    function pruneStack() {
        try {
            var avail = getAvailablePlayers();
            var ids = {};
            for (var i = 0; i < avail.length; i++) ids[playerId(avail[i])] = true;
            var pruned = [];
            var src = _lastActiveStack || [];
            for (var j = 0; j < src.length; j++) if (ids[src[j]]) pruned.push(src[j]);
            _lastActiveStack = pruned;
        } catch (e) {}
    }

    function getAvailablePlayers() {
        if (!Mpris.players || !Mpris.players.values) return [];
        let all = Mpris.players.values;
        let res = [];
        for (let i = 0; i < all.length; i++) {
            let p = all[i];
            if (p && p.canControl) res.push(p);
        }
        return res;
    }

    function findActivePlayer() {
        let avail = getAvailablePlayers();
        if (avail.length === 0) return null;

        // Fast map from id -> player
        let byId = {};
        for (let i = 0; i < avail.length; i++) byId[playerId(avail[i])] = avail[i];

        function pick(rule) {
            switch (String(rule)) {
            case "mpdPlaying":
                for (let i = 0; i < _lastActiveStack.length; i++) {
                    let p = byId[_lastActiveStack[i]];
                    if (p && p.isPlaying && isPlayerMpd(p)) return p;
                }
                return null;
            case "anyPlaying":
                for (let i = 0; i < _lastActiveStack.length; i++) {
                    let p = byId[_lastActiveStack[i]];
                    if (p && p.isPlaying) return p;
                }
                // Fallback: scan avail if stack empty
                for (let j = 0; j < avail.length; j++) if (avail[j] && avail[j].isPlaying) return avail[j];
                return null;
            case "mpdRecent":
                for (let i = 0; i < _lastActiveStack.length; i++) {
                    let p = byId[_lastActiveStack[i]];
                    if (p && isPlayerMpd(p)) return p;
                }
                // Fallback: first MPD in avail
                for (let j = 0; j < avail.length; j++) if (isPlayerMpd(avail[j])) return avail[j];
                return null;
            case "recent":
                for (let i = 0; i < _lastActiveStack.length; i++) {
                    let p = byId[_lastActiveStack[i]];
                    if (p) return p;
                }
                return null;
            case "manual":
                if (selectedPlayerIndex < avail.length) return avail[selectedPlayerIndex];
                return null;
            case "first":
                return avail[0] || null;
            default:
                return null;
            }
        }

        // Apply configured priority rules
        let rules = (Settings.settings && Settings.settings.playerSelectionPriority)
            ? Settings.settings.playerSelectionPriority
            : ["mpdPlaying","anyPlaying","mpdRecent","recent","manual","first"];
        for (let r = 0; r < rules.length; r++) {
            let candidate = pick(rules[r]);
            if (candidate) return candidate;
        }

        // Safety fallback
        return avail[0];
    }

    function updateCurrentPlayer() {
        let np = findActivePlayer();
        if (np !== currentPlayer) {
            currentPlayer = np;
        }
    }

    Component.onCompleted: updateCurrentPlayer()

    // Primary: react to MPRIS players list changes via Connections
    // Keep it under data: [...] to satisfy Item's default property list
    data: [
        Connections {
            target: Mpris.players
            ignoreUnknownSignals: true
            function onValuesChanged() { root.pruneStack(); root.updateCurrentPlayer() }
        },
        // Track playback state changes per player to maintain LIFO order
        Instantiator {
            active: true
            model: (Mpris.players && Mpris.players.values) ? Mpris.players.values : []
            delegate: Connections {
                target: modelData
                ignoreUnknownSignals: true
                function onPlaybackStateChanged() { root.touchActive(target); root.updateCurrentPlayer(); }
                function onIsPlayingChanged()     { if (target && target.isPlaying) { root.touchActive(target); root.updateCurrentPlayer(); } }
            }
        }
    ]

    // Fallback: light polling in case Connections are not delivered in this env
    Timer {
        interval: Theme.musicPlayersPollMs
        repeat: true
        running: true
        onTriggered: root.updateCurrentPlayer()
    }
}
