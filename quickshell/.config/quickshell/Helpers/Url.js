// Small, pure URL helpers shared across QML/JS

/**
 * Parse a URL query string into a key/value map.
 * Accepts strings with or without a leading '?'.
 * @param {string} queryString - Raw query string (e.g., "?a=1&b=two").
 * @returns {Object.<string,string>} Decoded params; missing values return as empty strings.
 */
function parseQuery(queryString) {
    try {
        var q = String(queryString || "");
        if (!q) return {};
        if (q.charAt(0) === '?') q = q.slice(1);
        var params = {};
        var parts = q.split('&');
        for (var i = 0; i < parts.length; i++) {
            var part = parts[i];
            if (!part) continue;
            var kv = part.split('=', 2);
            var k = "";
            var v = "";
            try { k = decodeURIComponent(kv[0] || ""); } catch (e1) { k = kv[0] || ""; }
            try { v = kv.length > 1 ? decodeURIComponent(kv[1]) : ""; } catch (e2) { v = kv.length > 1 ? kv[1] : ""; }
            if (!k) continue;
            params[k] = v;
        }
        return params;
    } catch (e) {
        return {};
    }
}

/**
 * Build a file:// URL from a directory path and filename.
 * Leaves the directory path as-is (minus a leading file:// and trailing '/'),
 * and URL-encodes the filename segment.
 * @param {string} dirPath - Directory path (with or without file:// prefix).
 * @param {string} fileName - File name (may include path; only last segment is used).
 * @returns {string} file:// URL or empty string on failure.
 */
function buildFileUrl(dirPath, fileName) {
    try {
        var path = String(dirPath || "");
        var name = String(fileName || "");
        if (!name) return "";
        // Strip directories from name if present
        if (name.indexOf('/') !== -1) name = name.substring(name.lastIndexOf('/') + 1);
        if (path.indexOf('file://') === 0) path = path.slice(7);
        if (path.slice(-1) === '/') path = path.slice(0, -1);
        // Keep conservative encoding: encode file name; leave path as-is
        var encodedName;
        try { encodedName = encodeURIComponent(name); } catch (e) { encodedName = name; }
        return 'file://' + path + '/' + encodedName;
    } catch (e) {
        return "";
    }
}

// Functions are exposed via module scope when imported in QML (e.g., `import ".../Url.js" as Url`).
