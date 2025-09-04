pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Non-visual helper for centralizing PipeWire audio volume/mute state
Item {
    id: root

    // Expose the default sink and its audio object
    property var defaultAudioSink: Pipewire.defaultAudioSink
    readonly property var _audio: (defaultAudioSink && defaultAudioSink.audio) ? defaultAudioSink.audio : null

    // Public state
    property int  volume: 0          // 0..100, 0 when muted
    property bool muted: (_audio ? _audio.muted : false)

    // Stepping/limits
    property int step: 5

    function roundToStep(v) { return Math.round(v / step) * step }

    function syncFromSink() {
        if (_audio) {
            muted = _audio.muted
            volume = _audio.muted ? 0 : Math.round((_audio.volume || 0) * 100)
        } else {
            muted = false
            volume = 0
        }
    }

    // Set absolute volume in percent (0..100), quantized to `step`
    function setVolume(vol) {
        var clamped = Math.max(0, Math.min(100, Math.round(vol)))
        var stepped = roundToStep(clamped)
        if (_audio) {
            _audio.volume = stepped / 100.0
            if (_audio.muted && stepped > 0) _audio.muted = false
        }
        volume = stepped
    }

    // Backward-compat alias
    function updateVolume(vol) { setVolume(vol) }

    // Relative change helper
    function changeVolume(delta) { setVolume(volume + (Number(delta) || 0)) }

    function toggleMute() { if (_audio) _audio.muted = !_audio.muted }

    // Keep in sync with the PipeWire sink
    Connections {
        target: _audio
        function onVolumeChanged() { root.syncFromSink() }
        function onMutedChanged()  { root.syncFromSink() }
    }

    // Track sink object swap
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    Component.onCompleted: syncFromSink()
}
