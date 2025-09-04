.pragma library

// Helpers/Time.js — time conversion utilities shared across services

// Normalize MPRIS-like time values to milliseconds.
// Accepts values that may be in:
// - nanoseconds   (> 1e12)
// - microseconds  (> 1e9)
// - seconds (possibly fractional) or milliseconds otherwise
// Heuristic mirrors existing usage in MusicManager/MusicPosition to avoid regressions.
function mprisToMs(v) {
    if (v === undefined || v === null || !isFinite(v)) return 0;

    if (v > 1e12) return Math.round(v / 1e6); // ns -> ms
    if (v > 1e9)  return Math.round(v / 1e3); // µs -> ms

    var hasFraction = Math.abs(v - Math.round(v)) > 0.0005;
    if (hasFraction || v < 36000) {            // <10h or fractional -> assume seconds
        return Math.round(v * 1000);           // s -> ms
    }

    // Otherwise treat as already ms
    return Math.round(v);
}

// Exported symbols
var __exports__ = { mprisToMs: mprisToMs }

