pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
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

    // --- Extended track metadata (best-effort from MPRIS metadata) -------
    // These are derived properties; values depend on what the player exposes.
    property string trackGenre:          _computeGenre()
    property string trackLabel:          _computeLabel()
    property string trackYear:           _computeYear()
    property string trackBitrateStr:     _computeBitrateStr()
    property string trackSampleRateStr:  _computeSampleRateStr()
    // DSD-specific compact MHz rate (e.g., 2.8M, 5.6M) for UI details (not summary)
    property string trackDsdRateStr:     _computeDsdRateStr()
    property string trackCodec:          _computeCodec()
    property string trackCodecDetail:    _computeCodecDetail()
    property string trackChannelsStr:    _computeChannelsStr()
    property string trackBitDepthStr:    _computeBitDepthStr()
    property string trackNumberStr:      _computeTrackNumberStr()
    property string trackDiscNumberStr:  _computeDiscNumberStr()
    property string trackAlbumArtist:    _computeAlbumArtist()
    property string trackComposer:       _computeComposer()
    property string trackUrlStr:         _computeUrlStr()
    property string trackRgTrackStr:     _computeRgTrackStr()
    property string trackRgAlbumStr:     _computeRgAlbumStr()
    property string trackDateStr:        _computeDateStr()
    property string trackContainer:      _computeContainer()
    property string trackFileSizeStr:    _computeFileSizeStr()
    property string trackChannelLayout:  _computeChannelLayout()
    property string trackQualitySummary: _computeQualitySummary()
    

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
            // Avoid querying Player.Position (some backends don't support it)
            currentPosition = 0;
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
        // Use relative Seek only; avoid SetPosition and any Position property writes
        try {
            if (currentPlayer && currentPlayer.canSeek && typeof currentPlayer.seek === 'function') {
                var targetMs = Math.max(0, Math.round(position));
                var deltaMs = targetMs - Math.max(0, Math.round(currentPosition));
                currentPlayer.seek(deltaMs);
                currentPosition = targetMs;
            }
        } catch (e) { /* ignore */ }
    }

    // --- Metadata helpers -------------------------------------------------
    function _playerProp(keys) {
        // Try direct properties on currentPlayer (e.g., trackGenre) then common aliases
        var p = currentPlayer;
        if (!p) return undefined;
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i];
            try {
                if (p[k] !== undefined && p[k] !== null && p[k] !== "") return p[k];
                var k2 = k.replace(/[:.]/g, "_");
                if (p[k2] !== undefined && p[k2] !== null && p[k2] !== "") return p[k2];
            } catch (e) { /* ignore */ }
        }
        // Try metadata dictionary variants
        var md = null;
        try { md = p['metadata'] || p['trackMetadata'] || p['meta'] || null; } catch (e) { md = null; }
        if (md) {
            for (var j = 0; j < keys.length; j++) {
                var mk = keys[j];
                try {
                    if (md[mk] !== undefined && md[mk] !== null && md[mk] !== "") return md[mk];
                    var mk2 = mk.replace(/[:.]/g, "_");
                    if (md[mk2] !== undefined && md[mk2] !== null && md[mk2] !== "") return md[mk2];
                } catch (e2) { /* ignore */ }
            }
        }
        return undefined;
    }

    function _mdAll() {
        var out = [];
        var p = currentPlayer;
        if (!p) return out;
        try {
            var md = p['metadata'] || p['trackMetadata'] || p['meta'] || null;
            if (md && typeof md === 'object') {
                for (var k in md) {
                    try { out.push(String(md[k])); } catch (e) { /* ignore */ }
                }
            }
        } catch (e) { /* ignore */ }
        // Collect a few likely direct props too
        var directKeys = [
            'format','audioFormat','audio_format','audio-format','bitrate','samplerate','sampleRate','channels','channelCount','codec','encoding','mimeType','mimetype'
        ];
        for (var i = 0; i < directKeys.length; i++) {
            var k = directKeys[i];
            try {
                var v = p[k];
                if (v !== undefined && v !== null && v !== '') out.push(String(v));
            } catch (e2) { /* ignore */ }
        }
        return out;
    }

    function _toFlatString(v) {
        if (v === undefined || v === null) return "";
        try {
            if (Array.isArray(v)) return v.filter(function(x){return !!x;}).join(", ");
        } catch (e) { /* ignore */ }
        return String(v);
    }

    function _computeGenre() {
        var v = _playerProp(["trackGenre", "genre", "genres", "xesam:genre", "xesam.genre"]);
        var s = _toFlatString(v);
        if (s) return s;
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.genre) return _toFlatString(fileAudioMeta.tags.genre); } catch (e) {}
        return "";
    }

    function _computeLabel() {
        var v = _playerProp(["label", "publisher", "albumLabel", "xesam:publisher", "xesam:label", "xesam:albumLabel"]);
        var s = _toFlatString(v);
        if (s) return s;
        try {
            if (fileAudioMeta && fileAudioMeta.tags) {
                if (fileAudioMeta.tags.label) return _toFlatString(fileAudioMeta.tags.label);
                if (fileAudioMeta.tags.publisher) return _toFlatString(fileAudioMeta.tags.publisher);
            }
        } catch (e) {}
        return "";
    }

    function _computeYear() {
        var v = _playerProp(["year", "date", "releaseDate", "xesam:contentCreated", "xesam:year"]);
        var s = _toFlatString(v);
        if (!s) return "";
        // Try to parse ISO/date and extract year
        try {
            // Accept pure year, datetime, or timestamp in ms
            if (/^\d{4}$/.test(s)) return s;
            var n = Number(s);
            if (!isNaN(n) && n > 1000) {
                // Heuristic: values like 20200101 or ms timestamp
                if (n < 3000) return String(Math.floor(n));
                var d = new Date(n);
                var y = d.getFullYear();
                if (y > 1900 && y < 3000) return String(y);
            }
            var d2 = new Date(s);
            var y2 = d2.getFullYear();
            if (y2 > 1900 && y2 < 3000) return String(y2);
        } catch (e) { /* ignore */ }
        // Fallback: take first 4-digit year-like token
        var m = s.match(/(19\d{2}|20\d{2})/);
        if (m) return m[1];
        try {
            if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.date) {
                const y = String(fileAudioMeta.tags.date);
                const m2 = y.match(/(19\d{2}|20\d{2})/);
                if (m2) return m2[1];
            }
        } catch (e) {}
        return "";
    }

    function _fmtKbps(val) {
        if (val === undefined || val === null || val === "") return "";
        var s = String(val).trim();
        if (/kbps$/i.test(s)) return s;
        var n = Number(s);
        if (isNaN(n)) return s;
        // If looks like bps (e.g., 192000), convert to kbps
        if (n > 5000) n = Math.round(n / 1000);
        return n + " kbps";
    }

    function _fmtKHz(val) {
        if (val === undefined || val === null || val === "") return "";
        var s = String(val).trim();
        if (/khz$/i.test(s)) {
            // normalize "44.1 kHz" or "44.1kHz" to "44.1k"
            var m = s.match(/(\d+(?:\.\d+)?)/);
            if (m) {
                var num = Number(m[1]);
                var dec = (Math.abs(num - Math.round(num)) > 0.05) ? 1 : 0;
                return Number(num).toFixed(dec) + 'k';
            }
            return s.replace(/\s*kHz/i, 'k');
        }
        var n = Number(s);
        if (isNaN(n)) return s;
        // If looks like Hz (e.g., 44100), convert to kHz
        var khz = n >= 1000 ? (n / 1000) : n; // support already-in-kHz numbers
        // Show 1 decimal for common non-integer kHz (e.g., 44.1)
        var dec = (Math.abs(khz - Math.round(khz)) > 0.05) ? 1 : 0;
        return khz.toFixed(dec) + 'k';
    }

    function _fmtMHz(hz) {
        var mhz = Number(hz) / 1e6;
        if (!isFinite(mhz) || mhz <= 0) return "";
        var dec = (Math.abs(mhz - Math.round(mhz)) > 0.05) ? 1 : 1; // keep 1 decimal for readability
        return mhz.toFixed(dec) + 'M';
    }

    // Parse a variety of kHz/Hz string formats to Hz number (approximate)
    function _parseRateToHz(val) {
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

    function _computeDsdVariant(codec, sampleRateStr) {
        try {
            if (!codec) return "";
            var c = String(codec).toUpperCase();
            if (c.indexOf('DSD') === -1) return "";
            // Try to detect DSD multiple from sample rate
            var hz = _parseRateToHz(sampleRateStr || trackSampleRateStr || "");
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

    function _computeDsdRateStr() {
        try {
            var codec = trackCodec ? String(trackCodec).toUpperCase() : "";
            if (codec.indexOf('DSD') === -1) return "";
            // Prefer numeric sample rate if available
            var hz = _parseRateToHz(trackSampleRateStr);
            if (!isNaN(hz) && hz > 0) return _fmtMHz(hz);
            // Try deriving from detected variant like DSD64/128...
            var variant = _computeDsdVariant(codec, trackSampleRateStr);
            var m = String(variant).match(/DSD(64|128|256|512|1024)/);
            if (m) {
                var mult = Number(m[1]);
                var estHz = mult * 44100; // base 44.1k
                return _fmtMHz(estHz);
            }
            // Fallback parsing from metadata strings
            var all = _mdAll();
            for (var j = 0; j < all.length; j++) {
                var s = String(all[j]);
                var mhz = s.match(/(\d+(?:\.\d+)?)\s*MHz/i);
                if (mhz) return mhz[1] + 'M';
                var khz = s.match(/(\d{4,6})\s*Hz/i);
                if (khz) return _fmtMHz(khz[1]);
            }
        } catch (e) { /* ignore */ }
        return "";
    }

    function _computeBitrateStr() {
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

    function _computeSampleRateStr() {
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

    function _computeCodec() {
        // Common codec names; try direct fields and metadata scan
        var v = _playerProp(["codec","encoding","format","mimeType","mimetype","xesam:audioCodec","xesam:codec","mpd:codec"]);
        var s = _toFlatString(v);
        if (s) return _prettyCodecName(s);
        try { if (fileAudioMeta && fileAudioMeta.codec) return _prettyCodecName(fileAudioMeta.codec); } catch (e) {}
        var all = _mdAll();
        var re = /(flac|alac|wav|aiff|pcm|mp3|aac|m4a|opus|vorbis|ogg|wma|ape|wv|dsd|dff|dsf)/i;
        for (var i = 0; i < all.length; i++) {
            var str = all[i];
            var m = str.match(re);
            if (m) return m[1].toUpperCase();
        }
        return "";
    }

    function _computeCodecDetail() {
        try {
            var parts = [];
            var base = trackCodec;
            if (!base && fileAudioMeta && fileAudioMeta.codec) base = _prettyCodecName(fileAudioMeta.codec);
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

    function _computeChannelsStr() {
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

    function _computeBitDepthStr() {
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

    function _computeTrackNumberStr() {
        var v = _playerProp(["trackNumber","xesam:trackNumber"]);
        var s = _toFlatString(v);
        if (s) return String(s);
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.track) return String(fileAudioMeta.tags.track); } catch (e) {}
        return "";
    }

    function _computeDiscNumberStr() {
        var v = _playerProp(["discNumber","xesam:discNumber"]);
        var s = _toFlatString(v);
        if (s) return String(s);
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.disc) return String(fileAudioMeta.tags.disc); } catch (e) {}
        return "";
    }

    function _computeAlbumArtist() {
        var v = _playerProp(["albumArtist","xesam:albumArtist"]);
        var s = _toFlatString(v);
        if (s) return s;
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.album_artist) return _toFlatString(fileAudioMeta.tags.album_artist); } catch (e) {}
        return "";
    }

    function _computeComposer() {
        var v = _playerProp(["composer","xesam:composer"]);
        var s = _toFlatString(v);
        if (s) return s;
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.composer) return _toFlatString(fileAudioMeta.tags.composer); } catch (e) {}
        return "";
    }

    function _computeUrlStr() {
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

    function _computeRgTrackStr() {
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

    function _computeRgAlbumStr() {
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
                var seekPos = Math.max(0, Math.round(ratio * currentPlayer.length));
                seek(seekPos);
            }
        } catch (e) { /* ignore */ }
    }

    // --- File introspection (ffprobe/mediainfo) ----------------------------
    property bool introspectAudioEnabled: true
    // Parsed from tools
    property var  fileAudioMeta: ({})   // { codec, codecLong, profile, sampleFormat, sampleRate, bitrateKbps, channels, bitDepth, tags:{}, fileSizeBytes, container, channelLayout, encoder }

    function _resetFileMeta() { fileAudioMeta = ({}) }

    function _pathFromUrl(u) {
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

    function _parseFfprobe(obj) {
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

    function _parseMediainfo(obj) {
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

    function _parseSoxInfo(text) {
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

    function _prettyCodecName(s) {
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

    

    function _computeDateStr() {
        var v = _playerProp(["date","xesam:contentCreated","xesam:date","xesam:contentcreated"]);
        var s = _toFlatString(v);
        if (s) return s;
        try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.date) return _toFlatString(fileAudioMeta.tags.date); } catch (e) {}
        return "";
    }

    function _computeContainer() {
        try { if (fileAudioMeta && fileAudioMeta.container) return String(fileAudioMeta.container).toUpperCase(); } catch (e) {}
        return "";
    }

    function _fmtBytes(n) {
        var num = Number(n);
        if (isNaN(num) || num <= 0) return "";
        var units = ["B", "KB", "MB", "GB", "TB"]; var i = 0;
        while (num >= 1024 && i < units.length-1) { num /= 1024; i++; }
        var fixed = (num >= 100 || i <= 1) ? 0 : 1;
        return num.toFixed(fixed) + " " + units[i];
    }

    function _computeFileSizeStr() {
        try { if (fileAudioMeta && fileAudioMeta.fileSizeBytes) return _fmtBytes(fileAudioMeta.fileSizeBytes); } catch (e) {}
        return "";
    }

    function _computeChannelLayout() {
        try { if (fileAudioMeta && fileAudioMeta.channelLayout) return String(fileAudioMeta.channelLayout); } catch (e) {}
        return "";
    }

    // Encoder intentionally omitted from public API

    function _computeQualitySummary() {
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
        if (lossy && trackBitrateStr) parts.push(trackBitrateStr);
        // For DSD, omit sample rate since DSDxx already implies it
        if (!isDsd && trackSampleRateStr) parts.push(trackSampleRateStr);
        if (trackBitDepthStr) parts.push(trackBitDepthStr);
        if (trackChannelsStr) parts.push(trackChannelsStr);
        return parts.filter(function(p){ return p && String(p).length > 0; }).join(" ");
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

            // Avoid reading Player.Position every tick to prevent DBus warnings
            var lengthMs = mprisToMs(currentPlayer.length);

            // Otherwise tick locally while playing
            if (currentPlayer.isPlaying) {
                var next = currentPosition + interval; // interval is ms
                currentPosition = (lengthMs > 0) ? Math.min(next, lengthMs) : next;
            } else {
                // paused/stopped: keep last known position
            }
        }
    }

    // (Removed explicit onCurrentPlayerChanged handler to avoid duplicate binding issues)

    // Subscribe to currentPlayer change notifications (if any)
    Connections {
        target: currentPlayer
        function onIsPlayingChanged() { /* Timer is unconditional; nothing to do */ }
        function onLengthChanged() { /* no-op */ }
    }

    // React to MPRIS players list changes
    Connections {
        target: Mpris.players
        function onValuesChanged() { updateCurrentPlayer(); }
    }

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
