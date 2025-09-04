import QtQuick
import QtQml
import "../Helpers/Time.js" as Time

// Non-visual helper for tracking and seeking playback position
Item {
    id: root
    property var currentPlayer: null
    property real currentPosition: 0 // ms

    // mprisToMs is centralized in Helpers/Time.js

    function seek(position) {
        try {
            if (currentPlayer && currentPlayer.canSeek && typeof currentPlayer.seek === 'function') {
                var targetMs = Math.max(0, Math.round(position));
                var deltaMs = targetMs - Math.max(0, Math.round(currentPosition));
                currentPlayer.seek(deltaMs / 1000.0);
                currentPosition = targetMs;
            }
        } catch (e) { /* ignore */ }
    }

    function seekByRatio(ratio) {
        try {
            if (currentPlayer && currentPlayer.canSeek && currentPlayer.length > 0) {
                var targetMs = Math.max(0, Math.round(ratio * currentPlayer.length * 1000));
                seek(targetMs);
            }
        } catch (e) { /* ignore */ }
    }

    // Poll MPRIS position properly (seconds) and convert to ms
    Timer {
        id: positionPoller
        interval: Theme.musicPositionPollMs
        repeat: true
        running: !!root.currentPlayer
        onTriggered: {
            if (!root.currentPlayer) { root.currentPosition = 0; return; }
            try {
                if (root.currentPlayer.positionSupported) {
                    root.currentPlayer.positionChanged();
                    var posMs = Time.mprisToMs(root.currentPlayer.position);
                    var lenMs = Time.mprisToMs(root.currentPlayer.length);
                    root.currentPosition = (lenMs > 0) ? Math.min(posMs, lenMs) : posMs;
                }
            } catch (e) { /* ignore */ }
        }
    }

    Connections {
        target: root.currentPlayer
        function onPositionChanged() {
            try {
                if (root.currentPlayer && root.currentPlayer.positionSupported) {
                    var posMs = Time.mprisToMs(root.currentPlayer.position);
                    var lenMs = Time.mprisToMs(root.currentPlayer.length);
                    root.currentPosition = (lenMs > 0) ? Math.min(posMs, lenMs) : posMs;
                }
            } catch (e) { /* ignore */ }
        }
        function onPlaybackStateChanged() {
            if (!root.currentPlayer) { root.currentPosition = 0; return; }
            if (root.currentPlayer.playbackState === 2 /* MprisPlaybackState.Stopped */) root.currentPosition = 0;
        }
    }
}
