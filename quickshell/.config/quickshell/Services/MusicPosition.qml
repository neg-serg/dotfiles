import QtQuick
import QtQml
import qs.Settings
import qs.Services
import "../Helpers/Utils.js" as Utils
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
                var targetMs = Utils.clamp(Math.round(position), 0, 2147483647);
                var deltaMs = targetMs - Utils.clamp(Math.round(currentPosition), 0, 2147483647);
                currentPlayer.seek(deltaMs / 1000.0);
                currentPosition = targetMs;
            }
        } catch (e) { /* ignore */ }
    }

    function seekByRatio(ratio) {
        try {
            if (currentPlayer && currentPlayer.canSeek && currentPlayer.length > 0) {
                var targetMs = Utils.clamp(Math.round(ratio * currentPlayer.length * 1000), 0, 2147483647);
                seek(targetMs);
            }
        } catch (e) { /* ignore */ }
    }

    // Poll MPRIS position via centralized Timers service
    Connections {
        target: Services.Timers
        function onTickMusicPosition() {
            if (!root.currentPlayer) { root.currentPosition = 0; return; }
            try {
                if (root.currentPlayer.positionSupported) {
                    root.currentPlayer.positionChanged();
                    var posMs = Time.mprisToMs(root.currentPlayer.position);
                    var lenMs = Time.mprisToMs(root.currentPlayer.length);
                    root.currentPosition = (lenMs > 0) ? Utils.clamp(posMs, 0, lenMs) : posMs;
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
                    root.currentPosition = (lenMs > 0) ? Utils.clamp(posMs, 0, lenMs) : posMs;
                }
            } catch (e) { /* ignore */ }
        }
        function onPlaybackStateChanged() {
            if (!root.currentPlayer) { root.currentPosition = 0; return; }
            if (root.currentPlayer.playbackState === 2 /* MprisPlaybackState.Stopped */) root.currentPosition = 0;
        }
    }
}
