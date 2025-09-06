import QtQuick
import QtQml
import qs.Components
import qs.Settings

// Computes extended track metadata and introspects files
Item {
    id: root

    property var currentPlayer: null
    property bool debugMetaLogging: false
    property int _recalcSeq: 0

    // Public metadata (set imperatively to avoid re-evaluation)
    property string trackGenre: ""
    property string trackLabel: ""
    property string trackYear: ""
    property string trackBitrateStr: ""
    property string trackSampleRateStr: ""
    property string trackDsdRateStr: ""
    property string trackCodec: ""
    property string trackCodecDetail: ""
    property string trackChannelsStr: ""
    property string trackBitDepthStr: ""
    property string trackNumberStr: ""
    property string trackDiscNumberStr: ""
    property string trackAlbumArtist: ""
    property string trackComposer: ""
    property string trackUrlStr: ""
    property string trackDateStr: ""
    property string trackContainer: ""
    property string trackFileSizeStr: ""
    property string trackChannelLayout: ""
    property string trackQualitySummary: ""

    property bool introspectAudioEnabled: true
    property string _lastPath: ""
    property string _pendingPath: ""
    property var fileAudioMeta:({})   // { codec, codecLong, profile, sampleFormat, sampleRate, bitrateKbps, channels, bitDepth, tags:{}, fileSizeBytes, container, channelLayout, encoder }
    function resetFileMeta() { fileAudioMeta = ({}) }

    Timer {
        id: recalcTimer
        interval: Theme.musicMetaRecalcDebounceMs
        repeat: false
        onTriggered: recalcAll()
    }

    function scheduleRecalc() {
        if (recalcTimer.running) recalcTimer.restart(); else recalcTimer.start();
    }

    function recalcAll() {
        var t0 = 0; if (debugMetaLogging) { t0 = Date.now(); ++_recalcSeq; }
        // Compute URL first to trigger introspection when it changes
        var newUrl = computeUrlStr();
        if (trackUrlStr !== newUrl) trackUrlStr = newUrl;

        trackGenre          = computeGenre();
        trackLabel          = computeLabel();
        trackYear           = computeYear();
        trackBitrateStr     = computeBitrateStr();
        trackSampleRateStr  = computeSampleRateStr();
        trackCodec          = computeCodec();
        trackCodecDetail    = computeCodecDetail();
        trackChannelsStr    = computeChannelsStr();
        trackBitDepthStr    = computeBitDepthStr();
        trackNumberStr      = computeTrackNumberStr();
        trackDiscNumberStr  = computeDiscNumberStr();
        trackAlbumArtist    = computeAlbumArtist();
        trackComposer       = computeComposer();
        trackDateStr        = computeDateStr();
        trackContainer      = computeContainer();
        trackFileSizeStr    = computeFileSizeStr();
        trackChannelLayout  = computeChannelLayout();
        // Depends on several of the above
        trackDsdRateStr     = computeDsdRateStr();
        trackQualitySummary = computeQualitySummary();
        
    }

    function playerProp(keys) {
        var p = currentPlayer;
        if (!p) return undefined;
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i];
            try {
                if (p[k] !== undefined && p[k] !== null && p[k] !== "") return p[k];
                var k2 = k.replace(/[:.]/g, "_");
                if (p[k2] !== undefined && p[k2] !== null && p[k2] !== "") return p[k2];
            } catch (e) { }
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
                } catch (e2) { }
            }
        }
        return undefined;
    }

    function mdAll() {
        var out = [];
        var p = currentPlayer;
        if (p) {
            try {
                var md = p['metadata'] || p['trackMetadata'] || p['meta'] || null;
                if (md && typeof md === 'object') {
                    for (var k in md) {
                        try { out.push(String(md[k])); } catch (e) { }
                    }
                }
            } catch (e) { }
            var directKeys = [
                'format','audioFormat','audio_format','audio-format','bitrate','samplerate','sampleRate','channels','channelCount','codec','encoding','mimeType','mimetype'
            ];
            for (var i = 0; i < directKeys.length; i++) {
                var k2 = directKeys[i];
                try {
                    var v2 = p[k2];
                    if (v2 !== undefined && v2 !== null && v2 !== '') out.push(String(v2));
                } catch (e2) { }
            }
        }
        return out;
    }

    function toFlatString(v) { if (v === undefined || v === null) return ""; try { if (Array.isArray(v)) return v.filter(function(x){return !!x;}).join(", "); } catch (e) {} return String(v); }
    function fmtKbps(val) { if (val === undefined || val === null || val === "") return ""; var s = String(val).trim(); if (/kbps$/i.test(s)) return s; var n = Number(s); if (isNaN(n)) return s; if (n > 5000) n = Math.round(n / 1000); return n + " kbps"; }
    function fmtKHz(val) { if (val === undefined || val === null || val === "") return ""; var s = String(val).trim(); if (/khz$/i.test(s)) { var m = s.match(/(\d+(?:\.\d+)?)/); if (m) { var num = Number(m[1]); var dec = (Math.abs(num - Math.round(num)) > 0.05) ? 1 : 0; return Number(num).toFixed(dec) + 'k'; } return s.replace(/\s*kHz/i, 'k'); } var n = Number(s); if (isNaN(n)) return s; var khz = n >= 1000 ? (n / 1000) : n; var dec2 = (Math.abs(khz - Math.round(khz)) > 0.05) ? 1 : 0; return khz.toFixed(dec2) + 'k'; }
    function fmtMHz(hz) { var mhz = Number(hz) / 1e6; if (!isFinite(mhz) || mhz <= 0) return ""; var dec = (Math.abs(mhz - Math.round(mhz)) > 0.05) ? 1 : 1; return mhz.toFixed(dec) + 'M'; }
    function parseRateToHz(val) { if (val === undefined || val === null || val === "") return NaN; var s = String(val).trim(); var mK = s.match(/^(\d+(?:\.\d+)?)\s*k(?:hz)?$/i); if (mK) return Math.round(Number(mK[1]) * 1000); var mHz = s.match(/^(\d+(?:\.\d+)?)\s*hz$/i); if (mHz) return Math.round(Number(mHz[1])); var n = Number(s); if (!isNaN(n)) return Math.round(n); return NaN; }

    function prettyCodecName(s) { if (!s) return ""; var v = String(s).toLowerCase(); if (v.startsWith('pcm_')) { return 'PCM ' + v.replace(/^pcm_/, '').toUpperCase(); } switch (v) { case 'flac': return 'FLAC'; case 'alac': return 'ALAC'; case 'mp3': return 'MP3'; case 'aac': return 'AAC'; case 'vorbis': return 'Vorbis'; case 'opus': return 'Opus'; case 'wma': return 'WMA'; case 'dff': case 'dsd': case 'dsf': return 'DSD'; case 'm4a': return 'M4A'; case 'wav': return 'WAV'; case 'aiff': return 'AIFF'; default: return String(s).toUpperCase(); } }

    function computeGenre() { var v = playerProp(["trackGenre", "genre", "genres", "xesam:genre", "xesam.genre"]); var s = toFlatString(v); if (s) return s; try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.genre) return toFlatString(fileAudioMeta.tags.genre); } catch (e) {} return ""; }
    function computeLabel() { var v = playerProp(["label", "publisher", "albumLabel", "xesam:publisher", "xesam:label", "xesam:albumLabel"]); var s = toFlatString(v); if (s) return s; try { if (fileAudioMeta && fileAudioMeta.tags) { if (fileAudioMeta.tags.label) return toFlatString(fileAudioMeta.tags.label); if (fileAudioMeta.tags.publisher) return toFlatString(fileAudioMeta.tags.publisher); } } catch (e) {} return ""; }
    function computeYear() { var v = playerProp(["year", "date", "releaseDate", "xesam:contentCreated", "xesam:year"]); var s = toFlatString(v); if (!s) return ""; try { if (/^\d{4}$/.test(s)) return s; var n = Number(s); if (!isNaN(n) && n > 1000) { if (n < 3000) return String(Math.floor(n)); var d = new Date(n); var y = d.getFullYear(); if (y > 1900 && y < 3000) return String(y); } var d2 = new Date(s); var y2 = d2.getFullYear(); if (y2 > 1900 && y2 < 3000) return String(y2); } catch (e) {} var m = s.match(/(19\d{2}|20\d{2})/); if (m) return m[1]; try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.date) { const y = String(fileAudioMeta.tags.date); const m2 = y.match(/(19\d{2}|20\d{2})/); if (m2) return m2[1]; } } catch (e) {} return ""; }
    function computeBitrateStr() { var v = playerProp(["bitrate", "audioBitrate", "xesam:audioBitrate", "xesam:bitrate", "mpris:bitrate", "mpd:bitrate"]); var s = fmtKbps(v); if (s) return s; try { if (fileAudioMeta && fileAudioMeta.bitrateKbps) return String(fileAudioMeta.bitrateKbps); } catch (e) {} return ""; }
    function computeSampleRateStr() { var v = playerProp(["sampleRate", "samplerate", "audioSampleRate", "xesam:audioSampleRate", "xesam:samplerate", "mpd:sampleRate"]); var s = fmtKHz(v); if (s) return s; try { if (fileAudioMeta && fileAudioMeta.sampleRate) return String(fileAudioMeta.sampleRate); } catch (e) {} var all = mdAll(); for (var i = 0; i < all.length; i++) { var str = all[i]; var m1 = str.match(/(\d{4,6})\s*Hz/i); if (m1) return fmtKHz(m1[1]); var m2 = str.match(/(\d+(?:\.\d+)?)\s*kHz/i); if (m2) return fmtKHz(m2[1]); } return ""; }
    function computeCodec() { var v = playerProp(["codec","encoding","format","mimeType","mimetype","xesam:audioCodec","xesam:codec","mpd:codec"]); var s = toFlatString(v); if (s) return prettyCodecName(s); try { if (fileAudioMeta && fileAudioMeta.codec) return prettyCodecName(fileAudioMeta.codec); } catch (e) {} var all = mdAll(); var re = /(flac|alac|wav|aiff|pcm|mp3|aac|m4a|opus|vorbis|ogg|wma|ape|wv|dsd|dff|dsf)/i; for (var i2 = 0; i2 < all.length; i2++) { var str = all[i2]; var m = str.match(re); if (m) return m[1].toUpperCase(); } return ""; }
    function computeCodecDetail() { try { var parts = []; var base = trackCodec; if (!base && fileAudioMeta && fileAudioMeta.codec) base = prettyCodecName(fileAudioMeta.codec); if (!base && fileAudioMeta && fileAudioMeta.container) base = String(fileAudioMeta.container).toUpperCase(); if (base) parts.push(base); if (fileAudioMeta && fileAudioMeta.profile) parts.push(fileAudioMeta.profile); if (fileAudioMeta && fileAudioMeta.codecLong) { var upperBase = base ? base.toUpperCase() : ""; if (!upperBase || fileAudioMeta.codecLong.toUpperCase().indexOf(upperBase) === -1) { parts.push('(' + fileAudioMeta.codecLong + ')'); } } var out = parts.join(' '); return out; } catch (e) { return trackCodec; } }
    function computeChannelsStr() { var v = playerProp(["channels","channelCount","xesam:channels","audioChannels","mpd:channels"]); var s = toFlatString(v); if (s) { if (/^1$/.test(s) || /mono/i.test(s)) return "1"; if (/^2$/.test(s) || /stereo/i.test(s)) return "2"; var m = String(s).match(/(\d+)\s*(?:ch|channels?)/i); if (m) return m[1]; var m2 = String(s).match(/(\d+)/); if (m2) return m2[1]; return ""; } try { if (fileAudioMeta && fileAudioMeta.channels) { var fs = String(fileAudioMeta.channels); if (/^1$/.test(fs) || /mono/i.test(fs)) return "1"; if (/^2$/.test(fs) || /stereo/i.test(fs)) return "2"; var m0 = fs.match(/(\d+)/); if (m0) return m0[1]; } } catch (e) {} var all = mdAll(); for (var i3 = 0; i3 < all.length; i3++) { var str2 = all[i3]; var m1 = str2.match(/(mono|stereo)/i); if (m1) return (/mono/i.test(m1[1]) ? "1" : "2"); var m3 = str2.match(/(\d+)\s*(?:ch|channels?)/i); if (m3) return m3[1]; var m4 = str2.match(/(\d+)/); if (m4) return m4[1]; } return ""; }
    function computeBitDepthStr() { var v = playerProp(["bitDepth","bitsPerSample","xesam:bitDepth","audioBitDepth","mpd:bitDepth"]); var s = toFlatString(v); if (s) { var m = String(s).match(/(\d{1,2})/); if (m) return m[1]; return ""; } try { if (fileAudioMeta && fileAudioMeta.bitDepth) { var bs = String(fileAudioMeta.bitDepth); var m0 = bs.match(/(\d{1,2})/); if (m0) return m0[1]; } } catch (e) {} var all2 = mdAll(); for (var i4 = 0; i4 < all2.length; i4++) { var str3 = all2[i4]; var m2 = str3.match(/(\d{1,2})\s*bit/i); if (m2) return m2[1]; } return ""; }
    function computeTrackNumberStr() { var v = playerProp(["trackNumber","xesam:trackNumber"]); var s = toFlatString(v); if (s) return String(s); try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.track) return String(fileAudioMeta.tags.track); } catch (e) {} return ""; }
    function computeDiscNumberStr() { var v = playerProp(["discNumber","xesam:discNumber"]); var s = toFlatString(v); if (s) return String(s); try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.disc) return String(fileAudioMeta.tags.disc); } catch (e) {} return ""; }
    function computeAlbumArtist() { var v = playerProp(["albumArtist","xesam:albumArtist"]); var s = toFlatString(v); if (s) return s; try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.album_artist) return toFlatString(fileAudioMeta.tags.album_artist); } catch (e) {} return ""; }
    function computeComposer() { var v = playerProp(["composer","xesam:composer"]); var s = toFlatString(v); if (s) return s; try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.composer) return toFlatString(fileAudioMeta.tags.composer); } catch (e) {} return ""; }
    function computeUrlStr() { var v = playerProp(["url","xesam:url"]); var s = toFlatString(v); if (!s) return ""; try { if (s.startsWith("file://")) { return decodeURIComponent(s.replace(/^file:\/\//, "")); } } catch (e) { } return s; }
    function computeDsdVariant(codec, sampleRateStr) { try { if (!codec) return ""; var c = String(codec).toUpperCase(); if (c.indexOf('DSD') === -1) return ""; var hz = parseRateToHz(sampleRateStr || trackSampleRateStr || ""); if (!isNaN(hz) && hz > 0) { var base = 44100; var ratio = hz / base; var candidates = [64, 128, 256, 512, 1024]; var best = 0, bestDiff = 1e9; for (var i = 0; i < candidates.length; i++) { var r = candidates[i]; var diff = Math.abs(ratio - r); if (diff < bestDiff) { bestDiff = diff; best = r; } } if (best > 0 && (bestDiff / best) <= 0.05) { return 'DSD' + best; } } var all3 = mdAll(); for (var j = 0; j < all3.length; j++) { var s3 = String(all3[j]); var m = s3.match(/DSD\s*(64|128|256|512|1024)/i); if (m) return 'DSD' + m[1]; } return 'DSD'; } catch (e) { return 'DSD'; } }
    function computeDsdRateStr() { try { var codec = trackCodec ? String(trackCodec).toUpperCase() : ""; if (codec.indexOf('DSD') === -1) return ""; var hz = parseRateToHz(trackSampleRateStr); if (!isNaN(hz) && hz > 0) return fmtMHz(hz); var variant = computeDsdVariant(codec, trackSampleRateStr); var m = String(variant).match(/DSD(64|128|256|512|1024)/); if (m) { var mult = Number(m[1]); var estHz = mult * 44100; return fmtMHz(estHz); } var all = mdAll(); for (var j = 0; j < all.length; j++) { var s = String(all[j]); var mhz = s.match(/(\d+(?:\.\d+)?)\s*MHz/i); if (mhz) return mhz[1] + 'M'; var khz = s.match(/(\d{4,6})\s*Hz/i); if (khz) return fmtMHz(khz[1]); } } catch (e) { } return ""; }
    function computeDateStr() { var v = playerProp(["date","xesam:contentCreated","xesam:date","xesam:contentcreated"]); var s = toFlatString(v); if (s) return s; try { if (fileAudioMeta && fileAudioMeta.tags && fileAudioMeta.tags.date) return toFlatString(fileAudioMeta.tags.date); } catch (e) {} return ""; }
    function computeContainer() { try { if (fileAudioMeta && fileAudioMeta.container) return String(fileAudioMeta.container).toUpperCase(); } catch (e) {} return ""; }
    function fmtBytes(n) { var num = Number(n); if (isNaN(num) || num <= 0) return ""; var units = ["B", "KB", "MB", "GB", "TB"]; var i = 0; while (num >= 1024 && i < units.length-1) { num /= 1024; i++; } var fixed = (num >= 100 || i <= 1) ? 0 : 1; return num.toFixed(fixed) + " " + units[i]; }
    function computeFileSizeStr() { try { if (fileAudioMeta && fileAudioMeta.fileSizeBytes) return fmtBytes(fileAudioMeta.fileSizeBytes); } catch (e) {} return ""; }
    function computeChannelLayout() { try { if (fileAudioMeta && fileAudioMeta.channelLayout) return String(fileAudioMeta.channelLayout); } catch (e) {} return ""; }
    function computeQualitySummary() { var parts = []; var codec = trackCodec ? String(trackCodec).toUpperCase() : ""; var isDsd = (codec.indexOf('DSD') !== -1); if (isDsd) { codec = computeDsdVariant(codec, trackSampleRateStr); } if (codec) parts.push(codec); var lossy = (function(c){ c = String(c).toUpperCase(); if (!c) return false; if (/(FLAC|ALAC|PCM|WAV|AIFF|DSD|APE|WV)/.test(c)) return false; return true; })(codec); if (lossy && trackBitrateStr) { var br = String(trackBitrateStr).trim(); var mBr = br.match(/(\d+(?:\.\d+)?)/); if (mBr) br = mBr[1]; parts.push(br); } if (!isDsd && trackSampleRateStr) parts.push(trackSampleRateStr); if (trackBitDepthStr && String(trackBitDepthStr) !== "16") parts.push(trackBitDepthStr); if (trackChannelsStr && String(trackChannelsStr) !== "2") parts.push(trackChannelsStr); return parts.filter(function(p){ return p && String(p).length > 0; }).join("/"); }

    // File path + introspection
    function pathFromUrl(u) { if (!u) return ""; var s = String(u); if (s.startsWith("file://")) { try { return decodeURIComponent(s.replace(/^file:\/\//, "")); } catch (e) { return s.replace(/^file:\/\//, ""); } } if (s.startsWith("/")) return s; return ""; }
    function isBusy() {
        try { return ffprobeProcess.running || mediainfoProcess.running || soxinfoProcess.running; } catch (e) { return false; }
    }
    function startIntrospection(p) {
        _lastPath = p;
        _pendingPath = "";
        ffprobeProcess.targetPath = p;
        ffprobeProcess.cmd = ["ffprobe", "-v", "quiet", "-print_format", "json", "-show_streams", "-show_format", p];
        ffprobeProcess.start();
    }
    function processChainFinished() {
        // If a new path was queued while busy, start it now
        if (_pendingPath && _pendingPath !== _lastPath) {
            startIntrospection(_pendingPath);
        }
    }
    function introspectCurrentTrack() {
        if (!introspectAudioEnabled) return;
        const p = pathFromUrl(trackUrlStr);
        if (!p) { resetFileMeta(); _lastPath = ""; _pendingPath = ""; return; }
        if (p === _lastPath) return; // no change
        if (isBusy()) { _pendingPath = p; return; }
        startIntrospection(p);
    }
    onTrackUrlStrChanged: introspectCurrentTrack()

    // Initial population
    Component.onCompleted: recalcAll()

    // Recompute on player changes and common metadata updates; ignoreUnknownSignals for portability
    Connections {
        target: root.currentPlayer
        ignoreUnknownSignals: true
        function onMetadataChanged()          { root.scheduleRecalc() }
        function onTrackTitleChanged()        { root.scheduleRecalc() }
        function onTrackArtistChanged()       { root.scheduleRecalc() }
        function onTrackAlbumChanged()        { root.scheduleRecalc() }
        function onTrackArtUrlChanged()       { root.scheduleRecalc() }
        function onLengthChanged()            { root.scheduleRecalc() }
        function onPlaybackStateChanged()     { root.scheduleRecalc() }
    }
    onCurrentPlayerChanged: scheduleRecalc()

    // Update fields when file introspection updates land
    onFileAudioMetaChanged: scheduleRecalc()

    // Process chain: ffprobe → mediainfo → sox --i
    ProcessRunner {
        id: ffprobeProcess
        property string targetPath: ""
        cmd: ["ffprobe", "-v", "quiet", "-print_format", "json", "-show_streams", "-show_format"]
        parseJson: true
        autoStart: false
        onJson: (obj) => {
            try {
                const meta = parseFfprobe(obj);
                if (meta) { fileAudioMeta = meta; processChainFinished(); return; }
            } catch (e) { }
            mediainfoProcess.targetPath = targetPath;
            mediainfoProcess.start();
        }
        onExited: (code, status) => {
            if (code !== 0) { mediainfoProcess.targetPath = targetPath; mediainfoProcess.start(); }
        }
    }
    ProcessRunner {
        id: mediainfoProcess
        property string targetPath: ""
        cmd: ["mediainfo", "--Output=JSON"]
        parseJson: true
        autoStart: false
        onJson: (obj) => {
            try {
                const meta = parseMediainfo(obj);
                if (meta) { fileAudioMeta = meta; processChainFinished(); return; }
            } catch (e) { }
            soxinfoProcess.targetPath = targetPath;
            soxinfoProcess.start();
        }
        onExited: (code, status) => {
            if (code !== 0) { soxinfoProcess.targetPath = targetPath; soxinfoProcess.start(); }
        }
    }
    ProcessRunner {
        id: soxinfoProcess
        property string targetPath: ""
        property string _buf: ""
        cmd: ["sox", "--i"]
        autoStart: false
        restartOnExit: false
        onLine: (s) => { _buf += (s + "\n") }
        onExited: (code, status) => {
            if (code === 0) {
                const text = String(_buf || "");
                const meta = parseSoxInfo(text);
                if (meta) { fileAudioMeta = meta; processChainFinished(); _buf = ""; return; }
            }
            _buf = "";
            resetFileMeta();
            processChainFinished();
        }
    }

    function parseFfprobe(obj) {
        if (!obj) return null;
        let audio = null;
        try {
            const streams = obj.streams || [];
            for (let i = 0; i < streams.length; i++) { if (streams[i] && streams[i].codec_type === 'audio') { audio = streams[i]; break; } }
        } catch (e) { }
        const fmt = obj.format || {};
        const out = { codec: "", codecLong: "", profile: "", sampleFormat: "", sampleRate: "", bitrateKbps: "", channels: "", bitDepth: "", tags: {}, fileSizeBytes: 0, container: "", channelLayout: "", encoder: "" };
        try { out.codec = (audio && audio.codec_name) || ""; const fmtname = (fmt.format_name || "").split(',')[0]; if (!out.codec && fmtname) out.codec = fmtname; } catch (e) {}
        try { out.codecLong = (audio && audio.codec_long_name) || ""; } catch (e) {}
        try { out.profile = (audio && (audio.profile || audio.profile_name)) || ""; } catch (e) {}
        try { out.sampleFormat = (audio && (audio.sample_fmt || audio.sample_format)) || ""; } catch (e) {}
        try { const sr = (audio && audio.sample_rate) ? Number(audio.sample_rate) : (fmt.sample_rate ? Number(fmt.sample_rate) : NaN); if (!isNaN(sr)) out.sampleRate = fmtKHz(sr); } catch (e) {}
        try { const br = (audio && audio.bit_rate) || fmt.bit_rate || ""; if (br) out.bitrateKbps = fmtKbps(br); } catch (e) {}
        try { const ch = (audio && audio.channels) || 0; if (ch === 1) out.channels = "Mono"; else if (ch === 2) out.channels = "Stereo"; else if (ch > 2) out.channels = String(ch); } catch (e) {}
        try { const bps = (audio && (audio.bits_per_raw_sample || audio.bits_per_sample)) || ""; if (bps) out.bitDepth = String(bps); } catch (e) {}
        try { const sr2 = (fmt.sample_rate ? Number(fmt.sample_rate) : NaN); if (!isNaN(sr2) && !out.sampleRate) out.sampleRate = fmtKHz(sr2); } catch (e) {}
        try { out.container = (fmt.format_name || "").split(',')[0].toUpperCase(); } catch (e) {}
        try { out.fileSizeBytes = (fmt.size ? Number(fmt.size) : 0) || 0; } catch (e) {}
        try { const tags = (fmt.tags || {}); out.tags = tags; } catch (e) {}
        try { if (audio && audio.channel_layout) out.channelLayout = String(audio.channel_layout); } catch (e) {}
        try { if (fmt && fmt.encoder) out.encoder = String(fmt.encoder); } catch (e) {}
        return out;
    }
    function parseMediainfo(obj) {
        try {
            const root = (obj && obj.media) ? obj.media : {};
            const t = Array.isArray(root.track) ? root.track : [];
            let a = null, g = null;
            for (let i = 0; i < t.length; i++) {
                const tr = t[i];
                if (tr && tr['@type'] === 'Audio' && !a) a = tr;
                if (tr && tr['@type'] === 'General' && !g) g = tr;
            }
            const out = { codec: "", codecLong: "", profile: "", sampleFormat: "", sampleRate: "", bitrateKbps: "", channels: "", bitDepth: "", tags: {}, fileSizeBytes: 0, container: "", channelLayout: "", encoder: "" };
            if (a) {
                if (a.CodecID) out.codec = String(a.CodecID);
                if (a.Format) out.codecLong = String(a.Format);
                if (a.Format_Profile) out.profile = String(a.Format_Profile);
                if (a.BitDepth) out.bitDepth = String(a.BitDepth);
                if (a.SamplingRate) out.sampleRate = fmtKHz(a.SamplingRate);
                if (a.BitRate) out.bitrateKbps = fmtKbps(a.BitRate);
                if (a.Channels) {
                    const ch = Number(a.Channels);
                    if (ch === 1) out.channels = 'Mono'; else if (ch === 2) out.channels = 'Stereo'; else if (ch > 2) out.channels = String(ch);
                }
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
            return out;
        } catch (e) { return null; }
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
            if (kv['sample encoding']) {
                const enc = kv['sample encoding'];
                if (/flac/i.test(enc)) out.codec = 'FLAC';
                else if (/mpeg/i.test(enc)) out.codec = 'MPEG';
                else if (/dsd|direct\s*stream\s*digital/i.test(enc)) out.codec = 'DSD';
                else out.codec = enc;
            }
            if (kv['channels']) {
                const chs = kv['channels'];
                if (/^1\b|mono/i.test(chs)) out.channels = 'Mono';
                else if (/^2\b|stereo/i.test(chs)) out.channels = 'Stereo';
                else {
                    const m = chs.match(/(\d+)/);
                    out.channels = m ? (m[1] + ' ch') : chs;
                }
            }
            if (kv['sample rate']) {
                const sr = kv['sample rate'].replace(/[^0-9.]/g, '');
                if (sr) out.sampleRate = fmtKHz(sr);
            }
            if (kv['precision']) {
                const m2 = kv['precision'].match(/(\d{1,2})/);
                if (m2) out.bitDepth = m2[1] + ' bit';
            }
            if (kv['bit rate']) {
                const br = kv['bit rate'];
                const n = br.match(/(\d+(?:\.\d+)?)/);
                if (n) { let val = Number(n[1]); out.bitrateKbps = Math.round(val) + ' kbps'; } else { out.bitrateKbps = br; }
            }
            if (kv['input file']) {
                const f = kv['input file'];
                const m3 = f.match(/\.(\w+)$/);
                if (m3) out.container = m3[1].toUpperCase();
            }
            return out;
        } catch (e) { return null; }
    }
}
