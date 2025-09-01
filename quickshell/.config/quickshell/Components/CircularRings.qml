import QtQuick
import qs.Settings

Canvas {
    id: root
    // Input spectrum (0..1)
    property var values: []

    // Rings layout
    property int ringCount: 5
    property real baseRadius: 34 * Theme.scale(Screen)
    property real ringSpacing: 4 * Theme.scale(Screen)
    property real amplitudeScale: 9 * Theme.scale(Screen)
    property real lineWidth: 2 * Theme.scale(Screen)

    // Color and fading across rings (outermost is 1.0)
    property color strokeColor: Theme.accentPrimary
    property real fadeInner: 0.6

    // Smoothing (exponential half-life decay)
    property real halfLifeMs: 260
    property int fps: 60
    // Breathing modulation (applies to amplitudeScale)
    property real breathSpeed: 1.1         // Hz
    property real breathDepth: 0.25        // 0..1 fraction of amplitudeScale
    property real breathPhase: 0
    property var smooth: []
    property double lastTs: 0

    width: (baseRadius + (ringCount - 1) * ringSpacing + amplitudeScale + lineWidth) * 2
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
        // advance breathing phase
        breathPhase += 2 * Math.PI * breathSpeed * (dt / 1000);
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
        const bands = bandAverages(ringCount);
        const breath = 1 + breathDepth * Math.sin(breathPhase);

        for (let r = 0; r < ringCount; r++) {
            const base = baseRadius + r * ringSpacing;
            const amp = bands[r] || 0;
            const radius = base + amplitudeScale * breath * amp;
            ctx.beginPath();
            ctx.arc(cx, cy, Math.max(0, radius), 0, Math.PI * 2, false);
            const t = ringCount > 1 ? (r / (ringCount - 1)) : 1; // 0 inner -> 1 outer
            const a = fadeInner + (1 - fadeInner) * t;
            ctx.lineWidth = lineWidth;
            ctx.strokeStyle = `rgba(${Math.round(strokeColor.r * 255)},${Math.round(strokeColor.g * 255)},${Math.round(strokeColor.b * 255)},${a})`;
            ctx.stroke();
        }
    }
}
