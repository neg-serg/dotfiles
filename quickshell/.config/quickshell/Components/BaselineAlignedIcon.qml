import QtQuick
import qs.Components
import qs.Settings
import "../Helpers/Utils.js" as Utils

// Baseline-aligned icon helper. Aligns either a text glyph or a Material icon
// to the baseline (or optical center) of a reference label, with adjustable scale and baseline offset.
Item {
    id: root
    // Reference label whose baseline we align to
    property var labelRef
    // Preferred token-style API (optional). Leave undefined to fall back to legacy props.
    property var  scaleToken: undefined
    property var  baselineOffsetToken: undefined
    // Legacy direct props (kept for compatibility)
    property real scale: 1.0
    // Additional manual baseline adjustment (added to token)
    property int  baselineAdjust: 0
    // Mode: "text" | "material"
    property string mode: "text"
    // Auto-tune size to match label visual height
    // Derives a scale factor from measured content heights at the label's pixel size
    property bool autoTune: true

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
    // Optional target icon to align vertical center offset with (same baseline vs label)
    property var alignTarget: null
    // Optional ascent compensation (legacy). Usually not needed when using optical.
    property bool compensateMetrics: false
    property real compensationFactor: 1.0

    // Effective inputs (prefer token-style when provided). Token adds to direct prop.
    readonly property real _effScale: (typeof scaleToken === 'number') ? scaleToken : scale
    readonly property int  _effBaselineOffset: ((typeof baselineOffsetToken === 'number') ? baselineOffsetToken : 0) + baselineAdjust

    // Fallback base size when labelRef is not available
    readonly property int _labelPx: (labelRef && labelRef.font && labelRef.font.pixelSize)
        ? labelRef.font.pixelSize : Theme.fontSizeSmall

    implicitWidth: (mode === "material") ? materialItem.implicitWidth : textItem.implicitWidth
    implicitHeight: (mode === "material") ? materialItem.implicitHeight : textItem.implicitHeight

    // Label metrics
    FontMetrics { id: fmLabel; font: (root.labelRef && root.labelRef.font) ? root.labelRef.font : Qt.font({ pixelSize: root._labelPx }) }
    // Probes for auto-tuning scale in material mode (measured at label pixel size)
    // Hidden and non-intrusive
    Text {
        id: labelProbe
        visible: false
        text: "H"
        font: (root.labelRef && root.labelRef.font) ? root.labelRef.font : Qt.font({ pixelSize: root._labelPx })
    }
    // Measure the material icon glyph at label size to estimate visual height
    MaterialIcon {
        id: matProbe
        visible: false
        icon: root.icon
        size: root._labelPx
    }
    // Measure the text glyph at label size to estimate visual height
    Text {
        id: textProbe
        visible: false
        text: root.text
        font.family: root.fontFamily || Theme.fontFamily
        font.styleName: root.fontStyleName
        font.pixelSize: root._labelPx
    }
    // Derived auto scale ratio based on measured content heights
    readonly property real _autoScale:
        (autoTune && mode === "material" && labelProbe.contentHeight > 0 && matProbe.contentHeight > 0)
            ? Utils.clamp(labelProbe.contentHeight / matProbe.contentHeight, 0.6, 1.2)
        : (autoTune && mode === "text" && labelProbe.contentHeight > 0 && textProbe.contentHeight > 0)
            ? Utils.clamp(labelProbe.contentHeight / textProbe.contentHeight, 0.6, 1.2)
        : 1.0
    // Helpers to compute vertical center offsets (positive is downward)
    function centerOffset(ascent, descent) { return (descent - ascent) / 2.0 }
    function computeCenterOffset(iconAscent, iconDescent) {
        var off = root._effBaselineOffset;
        var labelCenter = centerOffset(fmLabel.ascent, fmLabel.descent);
        var iconCenter  = centerOffset(iconAscent, iconDescent);
        if (root.alignMode === "optical") {
            // Align visual centers
            off = off + (labelCenter - iconCenter);
        } else {
            // Align baselines using center math
            off = off - (labelCenter - iconCenter);
            if (root.compensateMetrics) {
                off = off + (fmLabel.ascent - iconAscent) * root.compensationFactor;
            }
        }
        return Math.round(off);
    }
    // Expose current computed offset so others can align to it
    readonly property real currentOffset: (function(){
        if (root.mode === 'material') return computeCenterOffset(fmMat.ascent, fmMat.descent);
        return computeCenterOffset(fmText.ascent, fmText.descent);
    })()

    // Text glyph mode
    Text {
        id: textItem
        visible: root.mode === "text"
        text: root.text
        color: root.color
        padding: root.padding
        font.family: root.fontFamily || Theme.fontFamily
        font.styleName: root.fontStyleName
        font.pixelSize: Math.max(1, Math.round(root._labelPx * root._effScale * root._autoScale))
        renderType: Text.NativeRendering
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: (root.alignTarget && root.alignTarget.currentOffset !== undefined)
            ? root.alignTarget.currentOffset
            : computeCenterOffset(fmText.ascent, fmText.descent)
        FontMetrics { id: fmText; font: textItem.font }
    }

    // Material icon mode
    MaterialIcon {
        id: materialItem
        visible: root.mode === "material"
        icon: root.icon
        rounded: root.rounded
        size: Math.max(1, Math.round(root._labelPx * root._effScale * root._autoScale))
        color: root.color
        screen: root.screen
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: (root.alignTarget && root.alignTarget.currentOffset !== undefined)
            ? root.alignTarget.currentOffset
            : computeCenterOffset(fmMat.ascent, fmMat.descent)
        FontMetrics { id: fmMat; font: materialItem.font }
    }

    // Baseline for anchoring from outside (distance from top of this item to baseline)
    // Combine the child baseline and any requested adjustment tokens
    // Keep it available for possible external consumers, though we align via verticalCenter by default
    property real baselineOffset: (mode === 'material')
        ? (materialItem.baselineOffset + _effBaselineOffset)
        : (textItem.baselineOffset + _effBaselineOffset)

    // Expose visual baseline delta (label center minus icon center) for external alignment
    readonly property real baselineVisualDelta: (function(){
        var lc = centerOffset(fmLabel.ascent, fmLabel.descent);
        if (root.mode === 'material') {
            return lc - centerOffset(fmMat.ascent, fmMat.descent);
        } else {
            return lc - centerOffset(fmText.ascent, fmText.descent);
        }
    })()
}
