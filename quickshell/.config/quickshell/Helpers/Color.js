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

// Relative contrast ratio (WCAG) between two colors in RGB space
function contrastRatio(a, b) {
    try {
        var ca = _toRgb(a), cb = _toRgb(b);
        if (!ca || !cb) return 1;
        var La = _luminance(ca) + 0.05;
        var Lb = _luminance(cb) + 0.05;
        var high = Math.max(La, Lb);
        var low  = Math.min(La, Lb);
        return high / low;
    } catch (e) { return 1; }
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

// --- HSL conversions and adjustments ---
function _clamp01(x){ x = Number(x); if (!(x>=0)) x = 0; if (x>1) x = 1; return x }

function _rgbToHsl(rgb) {
    var r = _clamp01(rgb.r), g = _clamp01(rgb.g), b = _clamp01(rgb.b);
    var max = Math.max(r,g,b), min = Math.min(r,g,b);
    var h = 0, s = 0, l = (max + min) / 2;
    if (max !== min) {
        var d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        switch (max) {
            case r: h = (g - b) / d + (g < b ? 6 : 0); break;
            case g: h = (b - r) / d + 2; break;
            case b: h = (r - g) / d + 4; break;
        }
        h /= 6;
    }
    return { h: h, s: s, l: l, a: (rgb.a !== undefined ? _clamp01(rgb.a) : 1) };
}

function _hslToRgb(hsl) {
    var h = hsl.h - Math.floor(hsl.h); if (h<0) h += 1; // wrap
    var s = _clamp01(hsl.s), l = _clamp01(hsl.l), a = (hsl.a !== undefined ? _clamp01(hsl.a) : 1);
    function hue2rgb(p, q, t){
        if (t < 0) t += 1; if (t > 1) t -= 1;
        if (t < 1/6) return p + (q - p) * 6 * t;
        if (t < 1/2) return q;
        if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
        return p;
    }
    if (s === 0) { return Qt.rgba(l, l, l, a); }
    var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    var p = 2 * l - q;
    var r = hue2rgb(p, q, h + 1/3);
    var g = hue2rgb(p, q, h);
    var b = hue2rgb(p, q, h - 1/3);
    return Qt.rgba(r, g, b, a);
}

function toHsl(c) {
    try { var rgb = _toRgb(c); if (!rgb) return null; return _rgbToHsl(rgb); } catch(e){ return null }
}
function fromHsl(h, s, l, a) { try { return _hslToRgb({ h: Number(h)/360, s: s, l: l, a: a }); } catch(e){ return c } }

function lighten(c, t) {
    try {
        var hsl = toHsl(c); if (!hsl) return c; hsl.l = _clamp01(hsl.l + Number(t)); return _hslToRgb(hsl);
    } catch(e){ return c }
}
function darken(c, t) {
    try {
        var hsl = toHsl(c); if (!hsl) return c; hsl.l = _clamp01(hsl.l - Number(t)); return _hslToRgb(hsl);
    } catch(e){ return c }
}
function saturate(c, t) {
    try {
        var hsl = toHsl(c); if (!hsl) return c; hsl.s = _clamp01(hsl.s + Number(t)); return _hslToRgb(hsl);
    } catch(e){ return c }
}
function desaturate(c, t) {
    try {
        var hsl = toHsl(c); if (!hsl) return c; hsl.s = _clamp01(hsl.s - Number(t)); return _hslToRgb(hsl);
    } catch(e){ return c }
}
function shiftHue(c, deg) {
    try {
        var hsl = toHsl(c); if (!hsl) return c; hsl.h = hsl.h + (Number(deg)/360); return _hslToRgb(hsl);
    } catch(e){ return c }
}

// OKLCH stubs with HSL fallback to keep API stable
function toOklch(c) {
    try { var hsl = toHsl(c); if (!hsl) return null; return { l: hsl.l, c: hsl.s, h: hsl.h*360, a: (hsl.a!==undefined?hsl.a:1) }; } catch(e){ return null }
}
function fromOklch(l, c, h, a) {
    try { return fromHsl(h, Math.max(0, Math.min(1, c)), Math.max(0, Math.min(1, l)), a); } catch(e){ return Qt.rgba(0,0,0,1) }
}
