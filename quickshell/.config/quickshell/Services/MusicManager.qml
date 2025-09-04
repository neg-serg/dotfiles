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
    function stop()     { if (currentPlayer && typeof currentPlayer.stop === 'function') currentPlayer.stop(); }
    function next()     { if (currentPlayer && currentPlayer.canGoNext)     currentPlayer.next(); }
    function previous() { if (currentPlayer && currentPlayer.canGoPrevious) currentPlayer.previous(); }

    function seek(posMs) { position.seek(posMs); }

    // Metadata helpers moved to Services/MusicMeta

    // _mdAll removed (now in MusicMeta)

    // _toFlatString removed (now in MusicMeta)

    // _computeGenre removed

    // _computeLabel removed

    // _computeYear removed

    // _fmtKbps/_fmtKHz/_fmtMHz removed (now in MusicMeta)

    // Parse a variety of kHz/Hz string formats to Hz number (approximate)
    function parseRateToHz(val) {
        if (val === undefined || val === null || val === "") return NaN;
        var s = String(val).trim();
        // Accept like "44.1k", "44.1 kHz", "44100", "2822.4k"
        var mK = s.match(/^(\d+(?:\.\d+)?)\s*k(?:hz)?$/i);
        if (mK) return Math.round(Number(mK[1]) * 1000);
        var mHz = s.match(/^(\d+(?:\.\d+)?)\s*hz$/i);
        if (mHz) return Math.round(Number(mHz[1]));
        var n = Number(s);
        if (!isNaN(n)) return Math.round(n);
        return NaN;
    }

    function computeDsdVariant(codec, sampleRateStr) {
        try {
            if (!codec) return "";
            var c = String(codec).toUpperCase();
            if (c.indexOf('DSD') === -1) return "";
            // Try to detect DSD multiple from sample rate
            var hz = parseRateToHz(sampleRateStr || trackSampleRateStr || "");
            if (!isNaN(hz) && hz > 0) {
                var base = 44100; // DSD multiples of 44.1k
                var ratio = hz / base;
                // Find nearest among common rates
                var candidates = [64, 128, 256, 512, 1024];
                var best = 0, bestDiff = 1e9;
                for (var i = 0; i < candidates.length; i++) {
                    var r = candidates[i];
                    var diff = Math.abs(ratio - r);
                    if (diff < bestDiff) { bestDiff = diff; best = r; }
                }
                // Accept if within 5% tolerance
                if (best > 0 && (bestDiff / best) <= 0.05) {
                    return 'DSD' + best;
                }
            }
            // As a fallback, scan metadata strings for explicit DSDxx tokens
            var all = _mdAll();
            for (var j = 0; j < all.length; j++) {
                var str = String(all[j]);
                var m = str.match(/DSD\s*(64|128|256|512|1024)/i);
                if (m) return 'DSD' + m[1];
            }
            return 'DSD';
        } catch (e) {
            return 'DSD';
        }
    }

    // _computeDsdRateStr removed

    function computeBitrateStr() {
        var v = _playerProp(["bitrate", "audioBitrate", "xesam:audioBitrate", "xesam:bitrate", "mpris:bitrate", "mpd:bitrate"]);
        var s = _fmtKbps(v);
        if (s) return s;
        try { if (fileAudioMeta && fileAudioMeta.bitrateKbps) return String(fileAudioMeta.bitrateKbps); } catch (e) {}
        // Fallback: scan metadata strings for kbps hints
        var all = _mdAll();
        for (var i = 0; i < all.length; i++) {
            var str = all[i];
            // e.g., "320 kbps", "bitrate=320000", "br:192"
            var m = str.match(/(\d{2,4})\s*kbps/i);
            if (m) return m[1] + " kbps";
            var m2 = str.match(/bitrate\s*[:=]\s*(\d{4,7})/i);
            if (m2) return _fmtKbps(m2[1]);
        }
        return "";
    }

    function computeSampleRateStr() {
        var v = _playerProp(["sampleRate", "samplerate", "audioSampleRate", "xesam:audioSampleRate", "xesam:samplerate", "mpd:sampleRate"]);
        var s = _fmtKHz(v);
        if (s) return s;
        try { if (fileAudioMeta && fileAudioMeta.sampleRate) return String(fileAudioMeta.sampleRate); } catch (e) {}
        // Fallback: parse from audio format strings
        var all = _mdAll();
        for (var i = 0; i < all.length; i++) {
            var str = all[i];
            var m1 = str.match(/(\d{4,6})\s*Hz/i);
            if (m1) return _fmtKHz(m1[1]);
            var m2 = str.match(/(\d+(?:\.\d+)?)\s*kHz/i);
            if (m2) return _fmtKHz(m2[1]);
        }
        return "";
    }

    // _computeCodec removed

    function computeCodecDetail() {
        try {
            var parts = [];
            var base = trackCodec;
            if (!base && fileAudioMeta && fileAudioMeta.codec) base = prettyCodecName(fileAudioMeta.codec);
            if (!base && fileAudioMeta && fileAudioMeta.container) base = String(fileAudioMeta.container).toUpperCase();
            if (base) parts.push(base);
            if (fileAudioMeta && fileAudioMeta.profile) parts.push(fileAudioMeta.profile);
            if (fileAudioMeta && fileAudioMeta.codecLong) {
                var upperBase = base ? base.toUpperCase() : "";
                if (!upperBase || fileAudioMeta.codecLong.toUpperCase().indexOf(upperBase) === -1) {
                    parts.push('(' + fileAudioMeta.codecLong + ')');
                }
            }
            var out = parts.join(' ');
            return out;
        } catch (e) { return trackCodec; }
    }

    function computeChannelsStr() {
        var v = _playerProp(["channels","channelCount","xesam:channels","audioChannels","mpd:channels"]);
        var s = _toFlatString(v);
        if (s) {
            // normalize common representations
            if (/^1$/.test(s) || /mono/i.test(s)) return "1";
            if (/^2$/.test(s) || /stereo/i.test(s)) return "2";
            var m = String(s).match(/(\d+)\s*(?:ch|channels?)/i);
            if (m) return m[1];
            var m2 = String(s).match(/(\d+)/);
            if (m2) return m2[1];
            return "";
        }
        try {
            if (fileAudioMeta && fileAudioMeta.channels) {
                var fs = String(fileAudioMeta.channels);
                if (/^1$/.test(fs) || /mono/i.test(fs)) return "1";
                if (/^2$/.test(fs) || /stereo/i.test(fs)) return "2";
                var m0 = fs.match(/(\d+)/);
                if (m0) return m0[1];
            }
        } catch (e) {}
        // Parse from format strings
        var all = _mdAll();
        for (var i = 0; i < all.length; i++) {
            var str = all[i];
            var m1 = str.match(/(mono|stereo)/i);
            if (m1) return (/mono/i.test(m1[1]) ? "1" : "2");
            var m3 = str.match(/(\d+)\s*(?:ch|channels?)/i);
            if (m3) return m3[1];
            var m4 = str.match(/(\d+)/);
            if (m4) return m4[1];
        }
        return "";
    }

    function computeBitDepthStr() {
        var v = _playerProp(["bitDepth","bitsPerSample","xesam:bitDepth","audioBitDepth","mpd:bitDepth"]);
        var s = _toFlatString(v);
        if (s) {
            var m = String(s).match(/(\d{1,2})/);
            if (m) return m[1];
            return "";
        }
        try {
            if (fileAudioMeta && fileAudioMeta.bitDepth) {
                var bs = String(fileAudioMeta.bitDepth);
                var m0 = bs.match(/(\d{1,2})/);
                if (m0) return m0[1];
            }
        } catch (e) {}
        var all = _mdAll();
        for (var i = 0; i < all.length; i++) {
            var str = all[i];
            var m2 = str.match(/(\d{1,2})\s*bit/i);
            if (m2) return m2[1];
        }
        return "";
    }

    function computeTrackNumberStr() {
        var v = _playerProp(["trackNumber","xesam:trackNumber"]);
        var s = _toFlatString(v);
        if (s) return String(s);
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.track) return String(fileAudioMeta.tags.track); } catch (e) {}
        return "";
    }

    function computeDiscNumberStr() {
        var v = _playerProp(["discNumber","xesam:discNumber"]);
        var s = _toFlatString(v);
        if (s) return String(s);
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.disc) return String(fileAudioMeta.tags.disc); } catch (e) {}
        return "";
    }

    function computeAlbumArtist() {
        var v = _playerProp(["albumArtist","xesam:albumArtist"]);
        var s = _toFlatString(v);
        if (s) return s;
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.album_artist) return _toFlatString(fileAudioMeta.tags.album_artist); } catch (e) {}
        return "";
    }

    function computeComposer() {
        var v = _playerProp(["composer","xesam:composer"]);
        var s = _toFlatString(v);
        if (s) return s;
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.composer) return _toFlatString(fileAudioMeta.tags.composer); } catch (e) {}
        return "";
    }

    function computeUrlStr() {
        var v = _playerProp(["url","xesam:url"]);
        var s = _toFlatString(v);
        if (!s) return "";
        try {
            // Strip file:// if present
            if (s.startsWith("file://")) {
                return decodeURIComponent(s.replace(/^file:\/\//, ""));
            }
        } catch (e) { /* ignore */ }
        return s;
    }

    function computeRgTrackStr() {
        // Various forms: replaygain_track_gain, rg_track_gain, xesam:replayGainTrack
        var v = _playerProp([
            "replaygain_track_gain","rg_track_gain","replaygain_track","replayGainTrack","xesam:replaygain_track_gain","xesam:replayGainTrack"
        ]);
        var s = _toFlatString(v);
        if (s) return s;
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.replaygain_track_gain) return _toFlatString(fileAudioMeta.tags.replaygain_track_gain); } catch (e) {}
        var all = _mdAll();
        for (var i = 0; i < all.length; i++) {
            var str = all[i];
            var m = str.match(/(?:replaygain|rg)[^\d-+]*([+-]?\d+(?:\.\d+)?)\s*dB/i);
            if (m) return m[1] + " dB";
        }
        return "";
    }

    function computeRgAlbumStr() {
        var v = _playerProp([
            "replaygain_album_gain","rg_album_gain","replaygain_album","replayGainAlbum","xesam:replaygain_album_gain","xesam:replayGainAlbum"
        ]);
        var s = _toFlatString(v);
        if (s) return s;
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.replaygain_album_gain) return _toFlatString(fileAudioMeta.tags.replaygain_album_gain); } catch (e) {}
        var all = _mdAll();
        for (var i = 0; i < all.length; i++) {
            var str = all[i];
            var m = str.match(/album[^\d-+]*([+-]?\d+(?:\.\d+)?)\s*dB/i);
            if (m) return m[1] + " dB";
        }
        return "";
    }

    // Seek by ratio (0..1)
    function seekByRatio(ratio) {
        try {
            if (currentPlayer && currentPlayer.canSeek && currentPlayer.length > 0) {
                // currentPlayer.length is in seconds; convert to ms
                var targetMs = Math.max(0, Math.round(ratio * currentPlayer.length * 1000));
                seek(targetMs);
            }
        } catch (e) { /* ignore */ }
    }

    // --- File introspection (ffprobe/mediainfo) ----------------------------
    property bool introspectAudioEnabled: true
    // Parsed from tools
    property var  fileAudioMeta: ({})   // { codec, codecLong, profile, sampleFormat, sampleRate, bitrateKbps, channels, bitDepth, tags:{}, fileSizeBytes, container, channelLayout, encoder }

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
    }

    function introspectCurrentTrack() {
        if (!introspectAudioEnabled) return;
        const p = _pathFromUrl(trackUrlStr);
        if (!p) { _resetFileMeta(); return; }
        // Start with ffprobe
        ffprobeProcess.targetPath = p;
        ffprobeProcess.running = true;
    }

    onTrackUrlStrChanged: introspectCurrentTrack()

    Process {
        id: ffprobeProcess
        property string targetPath: ""
        command: ["ffprobe", "-v", "quiet", "-print_format", "json", "-show_streams", "-show_format", targetPath]
        stdout: StdioCollector { id: ffprobeStdout }
        onExited: (code, status) => {
            if (code === 0) {
                try {
                    const obj = JSON.parse(String(ffprobeStdout.text));
                    const meta = _parseFfprobe(obj);
                    if (meta) { fileAudioMeta = meta; return; }
                } catch (e) { /* fallthrough */ }
            }
            // Fallback to mediainfo
            mediainfoProcess.targetPath = targetPath;
            mediainfoProcess.running = true;
        }
    }

    Process {
        id: mediainfoProcess
        property string targetPath: ""
        command: ["mediainfo", "--Output=JSON", targetPath]
        stdout: StdioCollector { id: mediainfoStdout }
        onExited: (code, status) => {
            if (code === 0) {
                try {
                    const obj = JSON.parse(String(mediainfoStdout.text));
                    const meta = _parseMediainfo(obj);
                    if (meta) { fileAudioMeta = meta; return; }
                } catch (e) { /* ignore */ }
            }
            // Fallback to sox info
            soxinfoProcess.targetPath = targetPath;
            soxinfoProcess.running = true;
        }
    }

    Process {
        id: soxinfoProcess
        property string targetPath: ""
        // prefer soxi if present; but calling `sox --i` is more widely installed
        command: ["sox", "--i", targetPath]
        stdout: StdioCollector { id: soxinfoStdout }
        onExited: (code, status) => {
            if (code === 0) {
                const text = String(soxinfoStdout.text || "");
                const meta = _parseSoxInfo(text);
                if (meta) { fileAudioMeta = meta; return; }
            }
            // Give up gracefully
            _resetFileMeta();
        }
    }

    function parseFfprobe(obj) {
        if (!obj) return null;
        let audio = null;
        try {
            const streams = obj.streams || [];
            for (let i = 0; i < streams.length; i++) {
                if (streams[i] && streams[i].codec_type === 'audio') { audio = streams[i]; break; }
            }
        } catch (e) { /* ignore */ }
        const fmt = obj.format || {};
        const out = { codec: "", codecLong: "", profile: "", sampleFormat: "", sampleRate: "", bitrateKbps: "", channels: "", bitDepth: "", tags: {}, fileSizeBytes: 0, container: "", channelLayout: "", encoder: "" };
        try {
            out.codec = (audio && audio.codec_name) || "";
            const fmtname = (fmt.format_name || "").split(',')[0];
            if (!out.codec && fmtname) out.codec = fmtname;
        } catch (e) {}
        try { out.codecLong = (audio && audio.codec_long_name) || ""; } catch (e) {}
        try { out.profile = (audio && (audio.profile || audio.profile_name)) || ""; } catch (e) {}
        try { out.sampleFormat = (audio && (audio.sample_fmt || audio.sample_format)) || ""; } catch (e) {}
        try {
            const sr = (audio && audio.sample_rate) ? Number(audio.sample_rate) : (fmt.sample_rate ? Number(fmt.sample_rate) : NaN);
            if (!isNaN(sr)) out.sampleRate = _fmtKHz(sr);
        } catch (e) {}
        try {
            const br = (audio && audio.bit_rate) || fmt.bit_rate || "";
            if (br) out.bitrateKbps = _fmtKbps(br);
        } catch (e) {}
        try {
            const ch = (audio && audio.channels) || 0;
            if (ch === 1) out.channels = "Mono";
            else if (ch === 2) out.channels = "Stereo";
            else if (ch > 0) out.channels = ch + " ch";
        } catch (e) {}
        try {
            const bps = (audio && (audio.bits_per_sample || audio.bits_per_raw_sample)) || "";
            if (bps) out.bitDepth = (Number(bps) ? (Number(bps) + " bit") : (String(bps) + " bit"));
        } catch (e) {}
        try { out.tags = fmt.tags || (audio && audio.tags) || {}; } catch (e) {}
        try { out.fileSizeBytes = Number(fmt.size) || 0; } catch (e) {}
        try { out.container = String((fmt.format_name || "").split(',')[0] || ""); } catch (e) {}
        try { out.channelLayout = (audio && (audio.channel_layout || audio.ch_layout)) || ""; } catch (e) {}
        try { out.encoder = (fmt.tags && (fmt.tags.encoder || fmt.tags.Encoder)) || ""; } catch (e) {}
        // debug prints removed
        return out;
    }

    function parseMediainfo(obj) {
        try {
            const tracks = obj && obj.media && obj.media.track ? obj.media.track : [];
            let a = null, g = null;
            for (let i=0;i<tracks.length;i++) {
                const t = tracks[i];
                if (t && t['@type'] === 'Audio') a = t;
                if (t && t['@type'] === 'General') g = t;
            }
            const out = { codec: "", codecLong: "", profile: "", sampleFormat: "", sampleRate: "", bitrateKbps: "", channels: "", bitDepth: "", tags: {}, fileSizeBytes: 0, container: "", channelLayout: "", encoder: "" };
            if (a) {
                if (a.Format) out.codec = String(a.Format);
                if (a.Format_Commercial_IfAny) out.codecLong = String(a.Format_Commercial_IfAny);
                if (a.Format_Profile) out.profile = String(a.Format_Profile);
                if (a.BitDepth) out.sampleFormat = String(a.BitDepth) + 'bit';
                if (a.SamplingRate) out.sampleRate = _fmtKHz(a.SamplingRate);
                if (a.BitRate) out.bitrateKbps = _fmtKbps(a.BitRate);
                if (a.Channels) {
                    const ch = Number(a.Channels);
                    out.channels = (ch===1?"Mono":(ch===2?"Stereo":(ch>0?ch+" ch":"")));
                }
                if (a.BitDepth) out.bitDepth = String(a.BitDepth) + " bit";
                if (a.ChannelLayout) out.channelLayout = String(a.ChannelLayout);
            }
            const tags = {};
            if (g) {
                if (g.Genre) tags.genre = g.Genre;
                if (g.Album_Performer) tags.album_artist = g.Album_Performer;
                if (g.Performer) tags.artist = g.Performer;
                if (g.Recorded_Date) tags.date = g.Recorded_Date;
                if (g.Label) tags.label = g.Label;
                if (g.FileSize) { const n = Number(g.FileSize); if (!isNaN(n)) out.fileSizeBytes = n; }
                if (g.Format) out.container = String(g.Format);
                if (g.Encoded_Application) out.encoder = String(g.Encoded_Application);
            }
            out.tags = tags;
            // debug prints removed
            return out;
        } catch (e) {
            return null;
        }
    }

    function parseSoxInfo(text) {
        try {
            const out = { codec: "", sampleRate: "", bitrateKbps: "", channels: "", bitDepth: "", tags: {}, fileSizeBytes: 0, container: "", channelLayout: "", encoder: "" };
            const lines = String(text).split(/\r?\n/);
            const kv = {};
            for (let i = 0; i < lines.length; i++) {
                const line = lines[i];
                const idx = line.indexOf(':');
                if (idx <= 0) continue;
                const k = line.slice(0, idx).trim().toLowerCase();
                const v = line.slice(idx+1).trim();
                kv[k] = v;
            }
            // Sample encoding (e.g., FLAC, MPEG, Direct Stream Digital)
            if (kv['sample encoding']) {
                const enc = kv['sample encoding'];
                if (/flac/i.test(enc)) out.codec = 'FLAC';
                else if (/mpeg/i.test(enc)) out.codec = 'MPEG';
                else if (/dsd|direct\s*stream\s*digital/i.test(enc)) out.codec = 'DSD';
                else out.codec = enc;
            }
            // Channels
            if (kv['channels']) {
                const chs = kv['channels'];
                if (/^1\b|mono/i.test(chs)) out.channels = 'Mono';
                else if (/^2\b|stereo/i.test(chs)) out.channels = 'Stereo';
                else {
                    const m = chs.match(/(\d+)/);
                    out.channels = m ? (m[1] + ' ch') : chs;
                }
                // layout sometimes comes in comments; leave blank otherwise
            }
            // Sample rate
            if (kv['sample rate']) {
                const sr = kv['sample rate'].replace(/[^0-9.]/g, '');
                if (sr) out.sampleRate = _fmtKHz(sr);
            }
            // Precision -> bit depth
            if (kv['precision']) {
                const m = kv['precision'].match(/(\d{1,2})/);
                if (m) out.bitDepth = m[1] + ' bit';
            }
            // Bit rate
            if (kv['bit rate']) {
                const br = kv['bit rate'];
                // Typically like: 900k or 320k; normalize
                const n = br.match(/(\d+(?:\.\d+)?)/);
                if (n) {
                    let val = Number(n[1]);
                    // assume given in kbps
                    out.bitrateKbps = Math.round(val) + ' kbps';
                } else {
                    out.bitrateKbps = br;
                }
            }
            // Container/type
            if (kv['input file']) {
                const f = kv['input file'];
                const m = f.match(/\.(\w+)$/);
                if (m) out.container = m[1].toUpperCase();
            }
            // debug prints removed
            return out;
        } catch (e) { return null; }
    }

    function prettyCodecName(s) {
        if (!s) return "";
        var v = String(s).toLowerCase();
        if (v.startsWith('pcm_')) {
            return 'PCM ' + v.replace(/^pcm_/, '').toUpperCase();
        }
        switch (v) {
            case 'flac': return 'FLAC';
            case 'alac': return 'ALAC';
            case 'mp3': return 'MP3';
            case 'aac': return 'AAC';
            case 'vorbis': return 'Vorbis';
            case 'opus': return 'Opus';
            case 'wma': return 'WMA';
            case 'dff': case 'dsd': case 'dsf': return 'DSD';
            case 'm4a': return 'M4A';
            case 'wav': return 'WAV';
            case 'aiff': return 'AIFF';
            default:
                return String(s).toUpperCase();
        }
    }

    

    function computeDateStr() {
        var v = _playerProp(["date","xesam:contentCreated","xesam:date","xesam:contentcreated"]);
        var s = _toFlatString(v);
        if (s) return s;
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.date) return _toFlatString(fileAudioMeta.tags.date); } catch (e) {}
        return "";
    }

    function computeContainer() {
        try { if (fileAudioMeta && fileAudioMeta.container) return String(fileAudioMeta.container).toUpperCase(); } catch (e) {}
        return "";
    }

    function fmtBytes(n) {
        var num = Number(n);
        if (isNaN(num) || num <= 0) return "";
        var units = ["B", "KB", "MB", "GB", "TB"]; var i = 0;
        while (num >= 1024 && i < units.length-1) { num /= 1024; i++; }
        var fixed = (num >= 100 || i <= 1) ? 0 : 1;
        return num.toFixed(fixed) + " " + units[i];
    }

    function computeFileSizeStr() {
        try { if (fileAudioMeta && fileAudioMeta.fileSizeBytes) return fmtBytes(fileAudioMeta.fileSizeBytes); } catch (e) {}
        return "";
    }

    function computeChannelLayout() {
        try { if (fileAudioMeta && fileAudioMeta.channelLayout) return String(fileAudioMeta.channelLayout); } catch (e) {}
        return "";
    }

    // Encoder intentionally omitted from public API

    function computeQualitySummary() {
        // Example: "FLAC 44.1k 16 2" or "MP3 320 kbps 44.1k 16 2"
        var parts = [];
        var codec = trackCodec ? String(trackCodec).toUpperCase() : "";
        // Expand DSD to DSD64/128/etc when possible
        var isDsd = (codec.indexOf('DSD') !== -1);
        if (isDsd) {
            codec = _computeDsdVariant(codec, trackSampleRateStr);
        }
        if (codec) parts.push(codec);
        // Include bitrate only for lossy codecs
        var lossy = (function(c){
            c = String(c).toUpperCase();
            // Common lossless: FLAC, ALAC, WAV/AIFF/PCM, DSD, APE, WV (WavPack)
            if (!c) return false;
            if (/(FLAC|ALAC|PCM|WAV|AIFF|DSD|APE|WV)/.test(c)) return false;
            return true;
        })(codec);
        if (lossy && trackBitrateStr) {
            var br = String(trackBitrateStr).trim();
            // Extract numeric part and drop "kbps" suffix
            var mBr = br.match(/(\d+(?:\.\d+)?)/);
            if (mBr) br = mBr[1];
            parts.push(br);
        }
        // For DSD, omit sample rate since DSDxx already implies it
        if (!isDsd && trackSampleRateStr) parts.push(trackSampleRateStr);
        // Omit defaults: 16-bit depth and Stereo (2 channels)
        if (trackBitDepthStr && String(trackBitDepthStr) !== "16") parts.push(trackBitDepthStr);
        if (trackChannelsStr && String(trackChannelsStr) !== "2") parts.push(trackChannelsStr);
        return parts.filter(function(p){ return p && String(p).length > 0; }).join("/");
    }

    // --- Poll MPRIS position properly (seconds) and convert to ms ---------
    // Position polling handled by MusicPosition; player list by MusicPlayers

    // Audio spectrum (bars count from settings)
    // Prefer active profile bars, then settings, then fallback
    Cava {
        id: cava
        count: (
            Settings.settings.visualizerProfiles
            && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile]
            && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].cavaBars
        ) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].cavaBars
          : ((Settings.settings.cavaBars && Settings.settings.cavaBars > 0) ? Settings.settings.cavaBars : 86)
    }
    property alias cavaValues: cava.values
}
