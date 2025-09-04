pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "../Helpers/Time.js" as Time
import qs.Services
import qs.Settings
import qs.Components

Singleton {
    id: manager

    // --- Helpers -----------------------------------------------------------
    // Time conversion is centralized in Helpers/Time.js

    // --- Public API --------------------------------------------------------
    // Identify whether a player is MPD-like (mpd/mpdris/mopidy)
    function isPlayerMpd(player) {
        try {
            var p = player || currentPlayer;
            if (!p) return false;
            var idStr    = String((p.service || p.busName || "")).toLowerCase();
            var nameStr  = String(p.name || "").toLowerCase();
            var identStr = String(p.identity || "").toLowerCase();
            var re = /(mpd|mpdris|mopidy|music\s*player\s*daemon)/;
            return re.test(idStr) || re.test(nameStr) || re.test(identStr);
        } catch (e) { return false; }
    }

    function isCurrentMpdPlayer() { return isPlayerMpd(currentPlayer); }
    // Delegate core responsibilities to helper objects
    MusicPlayers { id: players }
    MusicPosition { id: position; currentPlayer: players.currentPlayer }
    // Public surface stays identical
    property alias currentPlayer: players.currentPlayer
    property alias selectedPlayerIndex: players.selectedPlayerIndex
    property alias currentPosition: position.currentPosition

    // Playback state helpers
    property bool   isPlaying:      currentPlayer ? currentPlayer.isPlaying : false
    property bool   isPaused:       currentPlayer ? (currentPlayer.playbackState === MprisPlaybackState.Paused) : false
    property bool   isStopped:      currentPlayer ? (currentPlayer.playbackState === MprisPlaybackState.Stopped) : true
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
    property bool   hasPlayer:      players.hasPlayer

    // --- Extended track metadata moved to MusicMeta ----------------------
    MusicMeta { id: meta; currentPlayer: players.currentPlayer }
    property alias trackGenre:          meta.trackGenre
    property alias trackLabel:          meta.trackLabel
    property alias trackYear:           meta.trackYear
    property alias trackBitrateStr:     meta.trackBitrateStr
    property alias trackSampleRateStr:  meta.trackSampleRateStr
    property alias trackDsdRateStr:     meta.trackDsdRateStr
    property alias trackCodec:          meta.trackCodec
    property alias trackCodecDetail:    meta.trackCodecDetail
    property alias trackChannelsStr:    meta.trackChannelsStr
    property alias trackBitDepthStr:    meta.trackBitDepthStr
    property alias trackNumberStr:      meta.trackNumberStr
    property alias trackDiscNumberStr:  meta.trackDiscNumberStr
    property alias trackAlbumArtist:    meta.trackAlbumArtist
    property alias trackComposer:       meta.trackComposer
    property alias trackUrlStr:         meta.trackUrlStr
    property alias trackRgTrackStr:     meta.trackRgTrackStr
    property alias trackRgAlbumStr:     meta.trackRgAlbumStr
    property alias trackDateStr:        meta.trackDateStr
    property alias trackContainer:      meta.trackContainer
    property alias trackFileSizeStr:    meta.trackFileSizeStr
    property alias trackChannelLayout:  meta.trackChannelLayout
    property alias trackQualitySummary: meta.trackQualitySummary
    

    Item { Component.onCompleted: players.updateCurrentPlayer() }
    function getAvailablePlayers() { return players.getAvailablePlayers(); }
    function updateCurrentPlayer() { return players.updateCurrentPlayer(); }

    function playPause() {
        if (!currentPlayer) return;
        if (currentPlayer.isPlaying) currentPlayer.pause(); else currentPlayer.play();
    }
    function play()     { if (currentPlayer && currentPlayer.canPlay)       currentPlayer.play(); }
    function pause()    { if (currentPlayer && currentPlayer.canPause)      currentPlayer.pause(); }




    // --- File introspection (ffprobe/mediainfo) ----------------------------
    // Parsed from tools

    function resetFileMeta() { fileAudioMeta = ({}) }

    function pathFromUrl(u) {
        if (!u) return "";
        var s = String(u);
        if (s.startsWith("file://")) {
            try { return decodeURIComponent(s.replace(/^file:\/\//, "")); } catch (e) { return s.replace(/^file:\/\//, ""); }
        }
        // If it's already a local path
        if (s.startsWith("/")) return s;
        return "";
            // Fallback to mediainfo
            mediainfoProcess.targetPath = targetPath;
            mediainfoProcess.running = true;
        }
    }
            // Fallback to sox info
            soxinfoProcess.targetPath = targetPath;
            soxinfoProcess.running = true;
        }
    }
    property alias cavaValues: cava.values
}
