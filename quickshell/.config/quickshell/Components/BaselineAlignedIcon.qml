import QtQuick
import qs.Components

// Baseline-aligned icon helper. Aligns either a text glyph or a Material icon
// to the baseline (or optical center) of a reference label, with adjustable scale and baseline offset.
Item {
    id: root
    // Reference label whose baseline we align to
    property var labelRef
    // Preferred token-style API (use these when available)
    property real scaleToken: 1.0
    property int  baselineOffsetToken: 0
    // Legacy direct props (kept for compatibility)
    property real scale: 1.0
    property int  baselineOffset: 0
    // Mode: "text" | "material"
    property string mode: "text"

    // Text mode properties
    property string text: ""
    property string fontFamily: ""
    property string fontStyleName: ""
    property color color: "white"
    property int padding: 0

    // Material mode properties
    property string icon: ""
    property bool rounded: false
    property var screen: null

    // Alignment mode: "baseline" (default) or "optical" (center-to-center)
    property string alignMode: "baseline"
    // Optional ascent compensation (legacy). Usually not needed when using optical.
    property bool compensateMetrics: false
    property real compensationFactor: 1.0

    // Effective inputs (prefer token-style when provided)
    readonly property real _effScale: (scaleToken !== undefined && scaleToken !== null) ? scaleToken : scale
    readonly property int  _effBaselineOffset: (baselineOffsetToken !== undefined && baselineOffsetToken !== null) ? baselineOffsetToken : baselineOffset

    // Fallback base size when labelRef is not available
    readonly property int _labelPx: (labelRef && labelRef.font && labelRef.font.pixelSize)
        ? labelRef.font.pixelSize : Theme.fontSizeSmall

    implicitWidth: (mode === "material") ? materialItem.implicitWidth : textItem.implicitWidth
    implicitHeight: (mode === "material") ? materialItem.implicitHeight : textItem.implicitHeight

    // Label metrics
    FontMetrics { id: fmLabel; font: (root.labelRef && root.labelRef.font) ? root.labelRef.font : Qt.font({ pixelSize: root._labelPx }) }
    // Helpers to compute center offsets relative to baselines (positive is downward)
    function centerOffsetFromBaseline(ascent, descent) {
        return (descent - ascent) / 2.0;
    }
    function computeOffset(iconAscent, iconDescent) {
        var off = root._effBaselineOffset;
        if (root.alignMode === "optical") {
            var labelCenter = centerOffsetFromBaseline(fmLabel.ascent, fmLabel.descent);
            var iconCenter  = centerOffsetFromBaseline(iconAscent, iconDescent);
            off = off + (labelCenter - iconCenter);
        } else if (root.compensateMetrics) {
            off = off + (fmLabel.ascent - iconAscent) * root.compensationFactor;
        }
        return Math.round(off);
    }

    // Text glyph mode
    Text {
        id: textItem
        visible: root.mode === "text"
        text: root.text
        color: root.color
        padding: root.padding
        font.family: root.fontFamily || Theme.fontFamily
        font.styleName: root.fontStyleName
        font.pixelSize: Math.max(1, Math.round(root._labelPx * root._effScale))
        renderType: Text.NativeRendering
        anchors.baseline: (root.labelRef && root.labelRef.baseline !== undefined) ? root.labelRef.baseline : undefined
        FontMetrics { id: fmText; font: textItem.font }
        anchors.baselineOffset: computeOffset(fmText.ascent, fmText.descent)
    }

    // Material icon mode
    MaterialIcon {
        id: materialItem
        visible: root.mode === "material"
        icon: root.icon
        rounded: root.rounded
        size: Math.max(1, Math.round(root._labelPx * root._effScale))
        color: root.color
        screen: root.screen
        anchors.baseline: (root.labelRef && root.labelRef.baseline !== undefined) ? root.labelRef.baseline : undefined
        FontMetrics { id: fmMat; font: materialItem.font }
        anchors.baselineOffset: computeOffset(fmMat.ascent, fmMat.descent)
    }
}
