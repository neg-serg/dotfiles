import QtQuick
import qs.Settings

Canvas {
    id: root
    property var values: []              // 0..1 values from CAVA
    property real rx: 48 * Theme.scale(Screen)
    property real ry: 36 * Theme.scale(Screen)
    property real amplitudeA: 0.35       // scale for outer curve
    property real amplitudeB: 0.20       // scale for inner curve
    property real lineWidthA: 2 * Theme.scale(Screen)
    property real lineWidthB: 1.25 * Theme.scale(Screen)
    property color strokeA: Theme.accentPrimary
    property color strokeB: Qt.rgba(Theme.accentPrimary.r, Theme.accentPrimary.g, Theme.accentPrimary.b, 0.7)
    property real halfLifeMs: 260        // half-life decay for falling values
    property int  fps: 60

    // smoothed values with exponential (half-life) decay
    property var smooth: []
    property double lastTs: 0

    width: Math.max(1, (rx + rx * (1 + amplitudeA)) * 2)
    height: Math.max(1, (ry + ry * (1 + amplitudeA)) * 2)

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
        // update smoothing per bin
        for (let i = 0; i < n; i++) {
            const v = Math.max(0, Math.min(1, values[i] || 0));
            const prev = smooth[i] || 0;
            smooth[i] = (v > prev) ? v : prev * k;
        }
        requestPaint();
    }

    onPaint: {
        const ctx = getContext('2d');
        ctx.reset();
        ctx.clearRect(0, 0, width, height);

        if (!smooth || smooth.length === 0) return;
        const n = smooth.length;
        const cx = width / 2;
        const cy = height / 2;

        // helper to draw one curve based on (rx, ry) and amplitude
        function drawCurve(ax, ay, amp, lw, col) {
            ctx.beginPath();
            for (let i = 0; i <= n; i++) {
                const idx = (i === n) ? 0 : i;
                const t = (idx / n) * Math.PI * 2;
                const s = smooth[idx];
                // scale outward along elliptical radii (approx normal)
                const sx = ax * (1 + amp * s);
                const sy = ay * (1 + amp * s);
                const x = cx + sx * Math.cos(t);
                const y = cy + sy * Math.sin(t);
                if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
            }
            ctx.closePath();
            ctx.lineWidth = lw;
            ctx.strokeStyle = col;
            ctx.stroke();
        }

        // outer curve (A) and inner curve (B) using slightly different axes
        drawCurve(rx, ry, amplitudeA, lineWidthA, strokeA);
        drawCurve(rx * 0.92, ry * 0.92, amplitudeB, lineWidthB, strokeB);
    }
}

