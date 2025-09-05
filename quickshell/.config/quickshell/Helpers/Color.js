// Small color helpers
// contrastOn(bg[, light, dark, threshold]): returns light or dark color string based on bg luminance
// withAlpha(color, a): returns Qt.rgba with alpha 0..1
// mix(a,b,t): linear blend between two colors, t in [0,1]
// towardsBlack(color,t): mix color toward black by t
// towardsWhite(color,t): mix color toward white by t

function _toRgb(obj) {
    try {
        if (obj === undefined || obj === null) return null;
        if (typeof obj === 'string') {
            var s = obj.trim();
            // #AARRGGBB or #RRGGBB
            var m8 = s.match(/^#([0-9a-f]{8})$/i);
            if (m8) {
                var a = parseInt(m8[1].slice(0,2),16)/255.0;
                var r = parseInt(m8[1].slice(2,4),16)/255.0;
                var g = parseInt(m8[1].slice(4,6),16)/255.0;
                var b = parseInt(m8[1].slice(6,8),16)/255.0;
                return { r:r, g:g, b:b, a:a };
            }
            var m6 = s.match(/^#([0-9a-f]{6})$/i);
            if (m6) {
                var r6 = parseInt(m6[1].slice(0,2),16)/255.0;
                var g6 = parseInt(m6[1].slice(2,4),16)/255.0;
                var b6 = parseInt(m6[1].slice(4,6),16)/255.0;
                return { r:r6, g:g6, b:b6, a:1.0 };
            }
            // Fallback: unknown string
            return null;
        }
        if (typeof obj === 'object' && obj.r !== undefined && obj.g !== undefined && obj.b !== undefined) {
            return { r: Number(obj.r), g: Number(obj.g), b: Number(obj.b), a: (obj.a !== undefined ? Number(obj.a) : 1.0) };
        }
    } catch(e) {}
    return null;
}

function _luminance(rgb) {
    // WCAG relative luminance
    var rs = rgb.r, gs = rgb.g, bs = rgb.b;
    function lin(c){ return (c <= 0.03928) ? (c/12.92) : Math.pow((c+0.055)/1.055, 2.4); }
    var r = lin(Math.max(0, Math.min(1, rs)));
    var g = lin(Math.max(0, Math.min(1, gs)));
    var b = lin(Math.max(0, Math.min(1, bs)));
    return 0.2126*r + 0.7152*g + 0.0722*b;
}

function contrastOn(bg, light, dark, threshold) {
    try {
        var rgb = _toRgb(bg);
        var lum = rgb ? _luminance(rgb) : 0.5;
        var th = (threshold === undefined || threshold === null) ? 0.5 : Number(threshold);
        if (!(th >= 0 && th <= 1)) { th = 0.5; }
        var lightColor = light || '#FFFFFF';
        var darkColor = dark || '#000000';
        return (lum < th) ? lightColor : darkColor;
    } catch(e) {
        return light || '#FFFFFF';
    }
}

function withAlpha(c, a) {
    try {
        var rgb = _toRgb(c);
        var alpha = Number(a);
        if (!(alpha >= 0 && alpha <= 1)) alpha = (alpha && alpha > 1) ? (alpha / 255.0) : 1.0;
        if (!rgb) return c;
        return Qt.rgba(rgb.r, rgb.g, rgb.b, alpha);
    } catch (e) { return c; }
}

function mix(a, b, t) {
    try {
        var ca = _toRgb(a), cb = _toRgb(b);
        var tt = Number(t); if (!(tt >= 0 && tt <= 1)) tt = 0.5;
        if (!ca || !cb) return a;
        return Qt.rgba(
            ca.r * (1-tt) + cb.r * tt,
            ca.g * (1-tt) + cb.g * tt,
            ca.b * (1-tt) + cb.b * tt,
            ca.a * (1-tt) + cb.a * tt
        );
    } catch (e) { return a; }
}

function towardsBlack(c, t) {
    return mix(c, Qt.rgba(0,0,0,1), t);
}

function towardsWhite(c, t) {
    return mix(c, Qt.rgba(1,1,1,1), t);
}
