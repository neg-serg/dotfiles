pragma Singleton
import QtQuick
import qs.Settings

// Centralized tick timers for multiple consumers
Singleton {
    id: root

    // Signals emitted on each interval
    signal tickTime()
    signal tickMusicPosition()
    signal tickMusicPlayers()
    signal tickMpdFlagsFallback()
    signal tickClipboard()
    signal tick2s()

    // Time/Clock tick (configurable)
    Timer {
        interval: Theme.timeTickMs
        repeat: true
        running: true
        onTriggered: root.tickTime()
    }

    // Music position polling (configurable)
    Timer {
        interval: Theme.musicPositionPollMs
        repeat: true
        running: true
        onTriggered: root.tickMusicPosition()
    }

    // Music players polling (configurable)
    Timer {
        interval: Theme.musicPlayersPollMs
        repeat: true
        running: true
        onTriggered: root.tickMusicPlayers()
    }

    // MPD flags fallback polling (configurable)
    Timer {
        interval: Theme.mpdFlagsFallbackMs
        repeat: true
        running: true
        onTriggered: root.tickMpdFlagsFallback()
    }

    // Clipboard polling for Applauncher (configurable)
    Timer {
        interval: Theme.applauncherClipboardPollMs
        repeat: true
        running: true
        onTriggered: root.tickClipboard()
    }

    // Generic 2s tick for UI dedupe tasks
    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: root.tick2s()
    }
}

