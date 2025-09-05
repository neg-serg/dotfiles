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
