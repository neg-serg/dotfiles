import QtQuick
import QtQml
import qs.Settings
import Quickshell.Services.Mpris

// Tracks MPRIS players and exposes currentPlayer.
// Selection rules (Settings.playerSelectionPriority): pinnedPlaying, mpdPlaying, anyPlaying, mpdRecent, pinned, recent, manual, first.
Item {
    id: root

    property var currentPlayer: null
    property int selectedPlayerIndex: 0
    property bool hasPlayer: getAvailablePlayers().length > 0
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
            var arr = _lastActiveStack || [];
            var idx = arr.indexOf(id);
            if (idx !== -1) arr.splice(idx, 1);
            arr.unshift(id);
            _lastActiveStack = arr;
            try {
                var maxN = 5;
                var toSave = arr.slice(0, maxN);
                if (Settings.settings && JSON.stringify(Settings.settings.lastActivePlayers || []) !== JSON.stringify(toSave)) {
                    Settings.settings.lastActivePlayers = toSave;
                }
            } catch (e2) {}
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

    function _isIgnored(p) {
        try {
            var list = (Settings.settings && Settings.settings.ignoredPlayers) ? Settings.settings.ignoredPlayers : [];
            if (!list || !list.length) return false;
            var id = playerId(p);
            for (var i = 0; i < list.length; i++) if (String(list[i]) === id) return true;
            return false;
        } catch (e) { return false; }
    }
    function _isPinned(p) {
        try {
            var list = (Settings.settings && Settings.settings.pinnedPlayers) ? Settings.settings.pinnedPlayers : [];
            if (!list || !list.length) return false;
            var id = playerId(p);
            for (var i = 0; i < list.length; i++) if (String(list[i]) === id) return true;
            return false;
        } catch (e) { return false; }
    }
    function getAvailablePlayers() {
        if (!Mpris.players || !Mpris.players.values) return [];
        let all = Mpris.players.values;
        let res = [];
        for (let i = 0; i < all.length; i++) {
            let p = all[i];
            if (p && p.canControl && !_isIgnored(p)) res.push(p);
        }
        return res;
    }

    function findActivePlayer() {
        let avail = getAvailablePlayers();
        if (avail.length === 0) return null;

        let byId = {};
        for (let i = 0; i < avail.length; i++) byId[playerId(avail[i])] = avail[i];

        function pick(rule) {
            switch (String(rule)) {
            case "pinnedPlaying":
                for (let i = 0; i < _lastActiveStack.length; i++) {
                    let p = byId[_lastActiveStack[i]];
                    if (p && p.isPlaying && _isPinned(p)) return p;
                }
                for (let j = 0; j < avail.length; j++) if (avail[j] && avail[j].isPlaying && _isPinned(avail[j])) return avail[j];
                return null;
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
                for (let j = 0; j < avail.length; j++) if (isPlayerMpd(avail[j])) return avail[j];
                return null;
            case "pinned":
                for (let i = 0; i < _lastActiveStack.length; i++) {
                    let p = byId[_lastActiveStack[i]];
                    if (p && _isPinned(p)) return p;
                }
                for (let j = 0; j < avail.length; j++) if (_isPinned(avail[j])) return avail[j];
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

        // Build rules: explicit array wins; otherwise preset
        const _allowedRules = ["pinnedPlaying","mpdPlaying","anyPlaying","mpdRecent","pinned","recent","manual","first"];
        function _sanitizeRules(arr) {
            var out = [];
            try {
                if (!arr || !arr.length) return out;
                for (var i = 0; i < arr.length; i++) {
                    var r = String(arr[i]);
                    if (_allowedRules.indexOf(r) === -1) {
                        try { console.warn('[MusicPlayers] Unknown rule in playerSelectionPriority:', r); } catch (e2) {}
                        continue;
                    }
                    if (out.indexOf(r) === -1) out.push(r);
                }
            } catch (e) {}
            return out;
        }
        function presetRules(name) {
            var n = String(name || "default");
            switch (n) {
            case "manualFirst":
                return ["manual", "pinnedPlaying", "anyPlaying", "pinned", "recent", "first"]; // manual, then pinned/playing, then recents
            case "playingFirst":
                return ["pinnedPlaying", "anyPlaying", "mpdPlaying", "pinned", "manual", "recent", "first"]; // prefer playing, then mpdPlaying
            case "mpdBias":
                return ["pinnedPlaying", "mpdPlaying", "anyPlaying", "mpdRecent", "pinned", "recent", "manual", "first"]; // mpd + pinned
            case "default":
            default:
                if (n !== "default") {
                    try { console.warn('[MusicPlayers] Unknown playerSelectionPreset:', n, '; using default'); } catch (e1) {}
                }
                return ["pinnedPlaying", "mpdPlaying", "anyPlaying", "mpdRecent", "pinned", "recent", "manual", "first"]; // default
            }
        }
        let cfg = (Settings.settings && Settings.settings.playerSelectionPriority) || null;
        let rules = [];
        if (cfg && cfg.length > 0) {
            rules = _sanitizeRules(cfg);
            if (!rules.length) {
                try { console.warn('[MusicPlayers] playerSelectionPriority contained no valid rules; falling back to preset'); } catch (e3) {}
                rules = presetRules(Settings.settings && Settings.settings.playerSelectionPreset);
            }
        } else {
            rules = presetRules(Settings.settings && Settings.settings.playerSelectionPreset);
        }
        for (let r = 0; r < rules.length; r++) {
            let candidate = pick(rules[r]);
            if (candidate) return candidate;
        }

        return avail[0];
    }

    function updateCurrentPlayer() {
        let np = findActivePlayer();
        if (np !== currentPlayer) {
            currentPlayer = np;
        }
    }

    Component.onCompleted: {
        updateCurrentPlayer();
        // Load persisted LIFO stack from settings
        try {
            var saved = (Settings.settings && Settings.settings.lastActivePlayers) ? Settings.settings.lastActivePlayers : [];
            if (saved && saved.length) _lastActiveStack = saved.filter(function(x){ return typeof x === 'string' && x.length > 0; });
        } catch (e) { }
    }

        // React to players list via Connections
        Connections {
            target: Mpris.players
            ignoreUnknownSignals: true
            function onValuesChanged() { root.pruneStack(); root.updateCurrentPlayer() }
        }
        // Track playback state per player to maintain LIFO
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

    // Fallback: poll in case Connections not delivered
    Timer {
        interval: Theme.musicPlayersPollMs
        repeat: true
        running: true
        onTriggered: root.updateCurrentPlayer()
    }
}
