.pragma library

// Helpers/RichText.js — small utilities for QML RichText composition

function esc(s) {
    s = (s === undefined || s === null) ? "" : String(s);
    return s
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

// Colored inline separator span (default '/') for RichText
function sepSpan(colorCss, ch, bold) {
    var c = (colorCss === undefined || colorCss === null) ? "inherit" : String(colorCss);
    var s = (ch === undefined || ch === null) ? '/' : String(ch);
    var fw = (bold === true) ? "; font-weight:bold" : "";
    return "<span style='color:" + c + fw + "'>" + esc(s) + "</span>";
}

// Colored bracket span helper (semantic helper over sepSpan)
function bracketSpan(colorCss, ch) {
    return sepSpan(colorCss, ch);
}

// Return a pair of bracket characters according to style keyword
// style: "round" | "square" | "lenticular" | "lenticular_black" | "angle" | "tortoise"
function bracketPair(style) {
    var s = (style || "square").toLowerCase();
    switch (s) {
        case "round": return { l: "(",    r: ")"     };
        case "lenticular": return { l: "\u3016", r: "\u3017" };
        case "lenticular_black": return { l: "\u3010", r: "\u3011" };
        case "angle": return { l: "\u27E8", r: "\u27E9" };
        case "tortoise": return { l: "\u3014", r: "\u3015" };
        case "square":
        default: return { l: "[",    r: "]"     };
    }
}

// Wrap provided text in a time-styled span with color
function timeSpan(colorCss, text) {
    var c = (colorCss === undefined || colorCss === null) ? "inherit" : String(colorCss);
    var t = esc(text);
    return "<span style='vertical-align: middle; line-height:1; color:" + c + "'>" + t + "</span>";
}

// Generic colored span for arbitrary text
function colorSpan(colorCss, text) {
    var c = (colorCss === undefined || colorCss === null) ? "inherit" : String(colorCss);
    return "<span style='color:" + c + "'>" + esc(text) + "</span>";
}

// Export functions
// (QML JavaScript library functions are available by import alias)
// Also expose a namespaced object for Qt.include usage in other JS libs
var RichRT = {
    esc: esc,
    sepSpan: sepSpan,
    bracketPair: bracketPair,
    bracketSpan: bracketSpan,
    timeSpan: timeSpan,
    colorSpan: colorSpan
};
