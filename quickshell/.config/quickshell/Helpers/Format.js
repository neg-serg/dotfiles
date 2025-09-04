.pragma library

// Helpers/Format.js — common lightweight formatting utilities

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
