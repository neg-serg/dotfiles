// Minimal shared HTTP helper for JSON GET with optional headers
// Usage from QML JS: Qt.include("Http.js"); httpGetJson(url, timeoutMs, onSuccess, onError, userAgent)

function httpGetJson(url, timeoutMs, success, fail, userAgent) {
    try {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        if (timeoutMs !== undefined && timeoutMs !== null) xhr.timeout = timeoutMs;
        try {
            if (xhr.setRequestHeader) {
                try { xhr.setRequestHeader('Accept', 'application/json'); } catch (e1) {}
                if (userAgent) { try { xhr.setRequestHeader('User-Agent', String(userAgent)); } catch (e2) {} }
            }
        } catch (e) { /* ignore header setting failures */ }
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

