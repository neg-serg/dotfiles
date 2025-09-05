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

