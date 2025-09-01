import QtQuick
import qs.Settings

Canvas {
    id: root
    // Spectrum values 0..1
    property var values: []

    // Base geometry (half side of square)
    property real half: 36 * Theme.scale(Screen)
    // Max outward offset for deformation
    property real offsetScale: 12 * Theme.scale(Screen)
    property real lineWidth: 2 * Theme.scale(Screen)
    property color strokeColor: Theme.accentPrimary
    property real alpha: 1.0

    // Smoothing (exponential half-life)
    property real halfLifeMs: 200
    property int fps: 60
    property var smooth: []
    property double lastTs: 0

    width: (half + offsetScale + lineWidth) * 2
    height: width

    onValuesChanged: {
        if (!values) { smooth = []; return; }
        if (!smooth || smooth.length !== values.length)
            smooth = Array(values.length).fill(0)
    }

    Timer {
        interval: Math.max(16, 1000 / root.fps)
        running: true
        repeat: true
        onTriggered: root.tick()
    }

    function tick() {
        const now = Date.now();
        const dt = (lastTs > 0) ? (now - lastTs) : (1000 / fps);
        lastTs = now;
        if (!values || values.length === 0) { requestPaint(); return; }
        const k = Math.exp(-Math.LN2 * dt / Math.max(1, halfLifeMs));
        const n = values.length;
        for (let i = 0; i < n; i++) {
            const v = Math.max(0, Math.min(1, values[i] || 0));
            const prev = smooth[i] || 0;
            smooth[i] = (v > prev) ? v : prev * k;
        }
        requestPaint();
    }

    function bandAverages(count) {
        const n = smooth && smooth.length ? smooth.length : 0;
        const out = new Array(count).fill(0);
        if (n === 0) return out;
        const step = Math.max(1, Math.floor(n / count));
        for (let b = 0; b < count; b++) {
            let sum = 0, c = 0;
            const start = b * step;
            const end = (b === count - 1) ? n : Math.min(n, start + step);
            for (let i = start; i < end; i++) { sum += smooth[i]; c++; }
            out[b] = c > 0 ? sum / c : 0;
        }
        return out;
    }

    onPaint: {
        const ctx = getContext('2d');
        ctx.reset();
        ctx.clearRect(0, 0, width, height);

        const cx = width / 2;
        const cy = height / 2;

        // 8 bands: top, top-right, right, bottom-right, bottom, bottom-left, left, top-left
        const bands = bandAverages(8);
        const H = half;
        const oT = offsetScale * (bands[0] || 0);
        const oTR = offsetScale * (bands[1] || 0);
        const oR = offsetScale * (bands[2] || 0);
        const oBR = offsetScale * (bands[3] || 0);
        const oB = offsetScale * (bands[4] || 0);
        const oBL = offsetScale * (bands[5] || 0);
        const oL = offsetScale * (bands[6] || 0);
        const oTL = offsetScale * (bands[7] || 0);

        // Direction helpers
        const s2 = Math.SQRT1_2; // 1/sqrt(2)

        // Points around perimeter (start at top mid, clockwise)
        const pts = [];
        // top mid
        pts.push([cx + 0,           cy - H - oT]);
        // top-right corner
        pts.push([cx + ( H + oTR * s2), cy - ( H + oTR * s2)]);
        // right mid
        pts.push([cx + H + oR,      cy + 0]);
        // bottom-right corner
        pts.push([cx + ( H + oBR * s2), cy + ( H + oBR * s2)]);
        // bottom mid
        pts.push([cx + 0,           cy + H + oB]);
        // bottom-left corner
        pts.push([cx - ( H + oBL * s2), cy + ( H + oBL * s2)]);
        // left mid
        pts.push([cx - H - oL,      cy + 0]);
        // top-left corner
        pts.push([cx - ( H + oTL * s2), cy - ( H + oTL * s2)]);

        ctx.beginPath();
        for (let i = 0; i < pts.length; i++) {
            const p = pts[i];
            if (i === 0) ctx.moveTo(p[0], p[1]); else ctx.lineTo(p[0], p[1]);
        }
        ctx.closePath();
        ctx.lineWidth = lineWidth;
        ctx.strokeStyle = `rgba(${Math.round(strokeColor.r * 255)},${Math.round(strokeColor.g * 255)},${Math.round(strokeColor.b * 255)},${alpha})`;
        ctx.stroke();
    }
}

