import QtQuick
import QtQml
import qs.Settings
import Quickshell.Services.Mpris

// Non-visual helper that tracks available MPRIS players and exposes currentPlayer
Item {
    id: root

    // Public API
    property var currentPlayer: null
    property int selectedPlayerIndex: 0
    property bool hasPlayer: getAvailablePlayers().length > 0
    // LIFO of last active players by id (most recent first)
    property var _lastActiveStack: []

    function _playerId(p) {
        try {
            if (!p) return "";
            return String(p.service || p.busName || p.name || p.identity || "");
        } catch (e) { return ""; }
    }

    function _isPlayerMpd(p) {
        try {
            if (!p) return false;
            var idStr    = String((p.service || p.busName || "")).toLowerCase();
            var nameStr  = String(p.name || "").toLowerCase();
            var identStr = String(p.identity || "").toLowerCase();
            var re = /(mpd|mpdris|mopidy|music\s*player\s*daemon)/;
            return re.test(idStr) || re.test(nameStr) || re.test(identStr);
        } catch (e) { return false; }
    }

    function _touchActive(p) {
        try {
            var id = _playerId(p);
            if (!id) return;
            // Move to front (dedupe)
            var arr = _lastActiveStack || [];
            var idx = arr.indexOf(id);
            if (idx !== -1) arr.splice(idx, 1);
            arr.unshift(id);
            _lastActiveStack = arr;
        } catch (e) {}
    }

    function _pruneStack() {
        try {
            var avail = getAvailablePlayers();
            var ids = {};
            for (var i = 0; i < avail.length; i++) ids[_playerId(avail[i])] = true;
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
        for (let i = 0; i < avail.length; i++) byId[_playerId(avail[i])] = avail[i];

        // Priority: MPD-like > others
        // 1) Most-recent MPD that is currently playing
        for (let k = 0; k < _lastActiveStack.length; k++) {
            let p = byId[_lastActiveStack[k]];
            if (p && p.isPlaying && _isPlayerMpd(p)) return p;
        }
        // 2) Most-recent non-MPD that is currently playing
        for (let k1 = 0; k1 < _lastActiveStack.length; k1++) {
            let p1 = byId[_lastActiveStack[k1]];
            if (p1 && p1.isPlaying && !_isPlayerMpd(p1)) return p1;
        }
        // 3) Most-recent MPD available
        for (let k2 = 0; k2 < _lastActiveStack.length; k2++) {
            let p2 = byId[_lastActiveStack[k2]];
            if (p2 && _isPlayerMpd(p2)) return p2;
        }
        // 4) Most-recent non-MPD available
        for (let k3 = 0; k3 < _lastActiveStack.length; k3++) {
            let p3 = byId[_lastActiveStack[k3]];
            if (p3 && !_isPlayerMpd(p3)) return p3;
        }
        // 5) Otherwise, respect selected index if in range
        if (selectedPlayerIndex < avail.length) return avail[selectedPlayerIndex];
        // 6) Fallback to first
        selectedPlayerIndex = 0;
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
            function onValuesChanged() { root._pruneStack(); root.updateCurrentPlayer() }
        },
        // Track playback state changes per player to maintain LIFO order
        Instantiator {
            active: true
            model: (Mpris.players && Mpris.players.values) ? Mpris.players.values : []
            delegate: Connections {
                target: modelData
                ignoreUnknownSignals: true
                function onPlaybackStateChanged() { root._touchActive(target); root.updateCurrentPlayer(); }
                function onIsPlayingChanged()     { if (target && target.isPlaying) { root._touchActive(target); root.updateCurrentPlayer(); } }
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
