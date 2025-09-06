// Minimal shared HTTP helper for JSON GET with optional headers
// Usage from QML JS: Qt.include("Http.js"); httpGetJson(url, timeoutMs, onSuccess, onError, userAgent)

// Track which hosts we've warned for to avoid log spam
var _uaWarnedHosts = {};

function _coerceUA(ua) {
    try {
        var s = (ua === undefined || ua === null) ? '' : String(ua).trim();
        return s ? s : 'Quickshell';
    } catch (e) { return 'Quickshell'; }
}

function _hostOf(u) {
    try { return (new URL(u)).host || ''; } catch (e) {}
    try { var m = String(u).match(/^https?:\/\/([^\/#?]+)/i); return m ? m[1] : ''; } catch (e2) {}
    return '';
}

function httpGetJson(url, timeoutMs, success, fail, userAgent) {
    try {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        if (timeoutMs !== undefined && timeoutMs !== null) xhr.timeout = timeoutMs;
        try {
            if (xhr.setRequestHeader) {
                try { xhr.setRequestHeader('Accept', 'application/json'); } catch (e1) {}
                var _ua = _coerceUA(userAgent);
                try { xhr.setRequestHeader('User-Agent', _ua); } catch (e2) {}
            }
        } catch (e) { /* ignore header setting failures */ }
        // Advisory: some geocoding APIs require a descriptive User-Agent with contact info
        try {
            var host = _hostOf(url).toLowerCase();
            var needsContactUA = (host.indexOf('nominatim.openstreetmap.org') !== -1);
            if (needsContactUA) {
                var uastr = String(userAgent || '').trim();
                var key = host + '|' + uastr.toLowerCase();
                if (!(_uaWarnedHosts[key])) {
                    if (!uastr || /^quickshell$/i.test(uastr) || /^negpanel$/i.test(uastr)) {
                        try {
                            try { if (Settings && Settings.settings && Settings.settings.debugLogs) console.debug('[Http] Geocoding service recommends a descriptive User-Agent with contact. Set Settings.userAgent, e.g.: "NegPanel/1.0 (contact: you@example.com)"'); } catch (_e1) {}
                        } catch (_e) {}
                    }
                    _uaWarnedHosts[key] = true;
                }
            }
        } catch (e4) {}
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            var status = xhr.status;
            if (status === 200) {
                try {
                    success && success(JSON.parse(xhr.responseText));
                } catch (e) {
                    fail && fail({ type: "parse", message: "Failed to parse JSON" });
                }
            } else {
                var retryAfter = 0;
                try {
                    var ra = xhr.getResponseHeader && xhr.getResponseHeader('Retry-After');
                    if (ra) retryAfter = Number(ra) * 1000;
                } catch (e3) {}
                fail && fail({ type: "http", status: status, retryAfter: retryAfter });
            }
        };
        xhr.ontimeout = function() { fail && fail({ type: "timeout" }); };
        xhr.onerror = function() { fail && fail({ type: "network" }); };
        xhr.send();
    } catch (e) {
        fail && fail({ type: "exception", message: String(e) });
    }
}
