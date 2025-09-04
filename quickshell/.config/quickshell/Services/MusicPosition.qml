import QtQuick

// Non-visual helper for tracking and seeking playback position
Item {
    id: root
    property var currentPlayer: null
    property real currentPosition: 0 // ms

    function mprisToMs(v) {
        if (v === undefined || v === null) return 0;
        if (v > 1e12) return Math.round(v / 1e6);
        if (v > 1e9)  return Math.round(v / 1e3);
        var hasFraction = Math.abs(v - Math.round(v)) > 0.0005;
        if (hasFraction || v < 36000) return Math.round(v * 1000);
        return Math.round(v);
    }

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
        interval: 1000
        repeat: true
        running: !!root.currentPlayer
        onTriggered: {
            if (!root.currentPlayer) { root.currentPosition = 0; return; }
            try {
                if (root.currentPlayer.positionSupported) {
                    root.currentPlayer.positionChanged();
                    var posMs = root.mprisToMs(root.currentPlayer.position);
                    var lenMs = root.mprisToMs(root.currentPlayer.length);
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
                    var posMs = root.mprisToMs(root.currentPlayer.position);
                    var lenMs = root.mprisToMs(root.currentPlayer.length);
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
