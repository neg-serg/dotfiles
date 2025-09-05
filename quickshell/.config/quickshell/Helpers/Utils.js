// Minimal general-purpose helpers for QML/JS

function clamp(value, min, max) {
    try {
        var v = Number(value);
        if (!isFinite(v)) v = Number(min);
        var a = Number(min), b = Number(max);
        if (!isFinite(a)) a = v;
        if (!isFinite(b)) b = v;
        if (a > b) { var t = a; a = b; b = t; }
        return Math.min(b, Math.max(a, v));
    } catch (e) { return min; }
}

function coerceInt(value, deflt) {
    try {
        var v = Math.round(Number(value));
        return isFinite(v) ? v : (deflt !== undefined ? Math.round(Number(deflt)) : 0);
    } catch (e) { return (deflt !== undefined ? Math.round(Number(deflt)) : 0); }
}

function coerceReal(value, deflt) {
    try {
        var v = Number(value);
        return isFinite(v) ? v : (deflt !== undefined ? Number(deflt) : 0);
    } catch (e) { return (deflt !== undefined ? Number(deflt) : 0); }
}

// Compute inline font pixel size for compact modules (icons + short text).
// height: desired component height in px
// padding: total vertical padding (px) applied to text block (top+bottom)
// scaleToken: multiplier from theme (defaults to Theme.panelComputedFontScale at callsite)
function computedInlineFontPx(height, padding, scaleToken) {
    try {
        var h = Math.max(0, Number(height) || 0);
        var pad = Math.max(0, Number(padding) || 0);
        var scale = Number(scaleToken);
        if (!isFinite(scale) || scale <= 0) scale = 1.0;
        var inner = Math.max(0, h - 2 * pad);
        // Clamp to a sane range to avoid extremes on misconfig
        return clamp(Math.round(inner * scale), 8, 4096);
    } catch (e) {
        return 12;
    }
}

// Export helpers for QML import
var Utils = {
    clamp,
    coerceInt,
    coerceReal,
    computedInlineFontPx,
};

// QML JS engine exposes top-level functions; also export for clarity
// (Some environments may rely on the named exports pattern.)
export { clamp, coerceInt, coerceReal, computedInlineFontPx };
