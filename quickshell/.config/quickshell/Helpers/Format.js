.pragma library

// Helpers/Format.js — common lightweight formatting utilities

function htmlEscape(s) {
    s = (s === undefined || s === null) ? "" : String(s);
    return s
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

// Return a colored inline separator span (default '/') for rich text
function sepSpan(colorCss, ch) {
    var c = (colorCss === undefined || colorCss === null) ? "inherit" : String(colorCss);
    var s = (ch === undefined || ch === null) ? '/' : String(ch);
    return "<span style='color:" + c + "'>" + htmlEscape(s) + "</span>";
}

// Convert a QML color (or CSS color string) to CSS rgba() string.
// Accepts: Qt.rgba object (with r,g,b,a 0..1) or string like "#RRGGBB".
// Optional alphaOverride (0..1) forces the alpha channel.
function colorCss(color, alphaOverride) {
    try {
        var c = color;
        if (typeof c === 'string') {
            // Let QML parse string to color by assigning to a temporary Rectangle if needed.
            // Here assume #RRGGBB or #AARRGGBB; parse manually for performance.
            var s = c.trim();
            if (/^#([0-9a-fA-F]{6})$/.test(s)) {
                var n = parseInt(s.slice(1), 16);
                var r = (n >> 16) & 0xFF, g = (n >> 8) & 0xFF, b = n & 0xFF;
                var a = (alphaOverride !== undefined && alphaOverride !== null) ? alphaOverride : 1;
                return "rgba(" + r + "," + g + "," + b + "," + a + ")";
            } else if (/^#([0-9a-fA-F]{8})$/.test(s)) {
                var n8 = parseInt(s.slice(1), 16);
                var a8 = (n8 >> 24) & 0xFF;
                var r8 = (n8 >> 16) & 0xFF, g8 = (n8 >> 8) & 0xFF, b8 = n8 & 0xFF;
                var a = (alphaOverride !== undefined && alphaOverride !== null) ? alphaOverride : (a8 / 255);
                return "rgba(" + r8 + "," + g8 + "," + b8 + "," + a + ")";
            }
            // Fallback: return string as-is
            return s;
        }
        // Assume Qt.rgba-like object
        var r255 = Math.round(c.r * 255), g255 = Math.round(c.g * 255), b255 = Math.round(c.b * 255);
        var a = (alphaOverride !== undefined && alphaOverride !== null) ? alphaOverride : c.a;
        if (!(a >= 0 && a <= 1)) a = 1;
        return "rgba(" + r255 + "," + g255 + "," + b255 + "," + a + ")";
    } catch (e) {
        return "rgba(0,0,0,1)";
    }
}

// Format milliseconds to m:ss or h:mm:ss
// - Negative/invalid values clamp to 0:00
// - Rounds down to whole seconds for stability in UIs
function fmtTime(ms) {
    if (ms === undefined || ms === null || !isFinite(ms)) return "0:00";
    var totalMs = Math.max(0, Math.floor(ms));
    var totalSec = Math.floor(totalMs / 1000);
    var s = totalSec % 60;
    var mTotal = Math.floor(totalSec / 60);
    var h = Math.floor(mTotal / 60);
    var m = mTotal % 60;
    var mm = (h > 0) ? (m < 10 ? "0" + m : "" + m) : ("" + m);
    var ss = (s < 10 ? "0" + s : "" + s);
    return (h > 0) ? (h + ":" + mm + ":" + ss) : (mm + ":" + ss);
}

// QML JavaScript modules expose top-level functions via the import alias.
