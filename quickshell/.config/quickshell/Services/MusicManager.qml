pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Settings
import qs.Components

Singleton {
    id: manager

    // --- Helpers -----------------------------------------------------------
    // Normalize MPRIS time to milliseconds (handles ns / µs / ms / s[.frac])
    function mprisToMs(v) {
        if (v === undefined || v === null) return 0;

        // Magnitude-based heuristics
        if (v > 1e12) return Math.round(v / 1e6); // ns -> ms
        if (v > 1e9)  return Math.round(v / 1e3); // µs -> ms

        // MPD case: seconds with fraction (e.g., 110.974)
        var hasFraction = Math.abs(v - Math.round(v)) > 0.0005;
        if (hasFraction || v < 36000) {           // <10h or fractional -> assume seconds
            return Math.round(v * 1000);          // s -> ms
        }

        // Otherwise treat as already ms
        return Math.round(v);
    }

    // --- Public API --------------------------------------------------------
    property var  currentPlayer: null
    property real currentPosition: 0                 // ms (kept in UI units)
    property int  selectedPlayerIndex: 0

    property bool   isPlaying:      currentPlayer ? currentPlayer.isPlaying : false
    property string trackTitle:     currentPlayer ? (currentPlayer.trackTitle  || "") : ""
    property string trackArtist:    currentPlayer ? (currentPlayer.trackArtist || "") : ""
    property string trackAlbum:     currentPlayer ? (currentPlayer.trackAlbum  || "") : ""
    property string coverUrl:       currentPlayer ? (currentPlayer.trackArtUrl || "") : ""
    property real   trackLength:    currentPlayer ? currentPlayer.length : 0  // raw from backend
    property bool   canPlay:        currentPlayer ? currentPlayer.canPlay : false
    property bool   canPause:       currentPlayer ? currentPlayer.canPause : false
    property bool   canGoNext:      currentPlayer ? currentPlayer.canGoNext : false
    property bool   canGoPrevious:  currentPlayer ? currentPlayer.canGoPrevious : false
    property bool   canSeek:        currentPlayer ? currentPlayer.canSeek : false
    property bool   hasPlayer:      getAvailablePlayers().length > 0

    Item {
        Component.onCompleted: updateCurrentPlayer()
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
        if (selectedPlayerIndex < avail.length) return avail[selectedPlayerIndex];
        selectedPlayerIndex = 0;
        return avail[0];
    }

    // Switch to selected/active player
    function updateCurrentPlayer() {
        let np = findActivePlayer();
        if (np !== currentPlayer) {
            currentPlayer = np;
            currentPosition = currentPlayer ? mprisToMs(currentPlayer.position) : 0;
        }
    }

    function playPause() {
        if (!currentPlayer) return;
        if (currentPlayer.isPlaying) currentPlayer.pause(); else currentPlayer.play();
    }
    function play()     { if (currentPlayer && currentPlayer.canPlay)       currentPlayer.play(); }
    function pause()    { if (currentPlayer && currentPlayer.canPause)      currentPlayer.pause(); }
    function next()     { if (currentPlayer && currentPlayer.canGoNext)     currentPlayer.next(); }
    function previous() { if (currentPlayer && currentPlayer.canGoPrevious) currentPlayer.previous(); }

    function seek(position) {
        if (currentPlayer && currentPlayer.canSeek) {
            currentPlayer.position = position;      // backend units are fine
            currentPosition = position;             // UI uses ms; we normalize at render if needed
        }
    }

    // Seek by ratio (0..1)
    function seekByRatio(ratio) {
        if (currentPlayer && currentPlayer.canSeek && currentPlayer.length > 0) {
            let seekPos = ratio * currentPlayer.length;
            currentPlayer.position = seekPos;
            currentPosition = mprisToMs(seekPos);
        }
    }

    // --- Keep time ticking even if backend doesn't push updates -----------
    Timer {
        id: positionTimer
        interval: 1000
        repeat: true
        running: true   // always ticking; guarded inside

        onTriggered: {
            if (!currentPlayer) {
                if (currentPosition !== 0) currentPosition = 0;
                return;
            }

            var backendPosMs = mprisToMs(currentPlayer.position);
            var lengthMs     = mprisToMs(currentPlayer.length);

            // If backend provides a moving value — trust it
            if (backendPosMs > 0 && backendPosMs !== currentPosition) {
                currentPosition = backendPosMs;
                return;
            }

            // Otherwise tick locally while playing
            if (currentPlayer.isPlaying) {
                var next = currentPosition + interval; // interval is ms
                currentPosition = (lengthMs > 0) ? Math.min(next, lengthMs) : next;
            } else {
                // paused/stopped: lazy-sync from backend if it differs
                if (backendPosMs !== currentPosition) currentPosition = backendPosMs;
            }
        }
    }

    // Sync when player object changes
    onCurrentPlayerChanged: {
        currentPosition = currentPlayer ? mprisToMs(currentPlayer.position) : 0;
    }

    // Subscribe to currentPlayer change notifications (if any)
    Connections {
        target: currentPlayer
        function onPositionChanged() { manager.currentPosition = manager.mprisToMs(currentPlayer.position); }
        function onIsPlayingChanged() { /* Timer is unconditional; nothing to do */ }
        function onLengthChanged() { /* no-op */ }
    }

    // React to MPRIS players list changes
    Connections {
        target: Mpris.players
        function onValuesChanged() { updateCurrentPlayer(); }
    }

    // Audio spectrum
    Cava { id: cava; count: 44 }
    property alias cavaValues: cava.values
}
