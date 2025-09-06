import QtQuick
import qs.Components
import qs.Settings
import "../Helpers/Utils.js" as Utils

// Baseline-aligned icon helper: aligns text glyph or Material icon to label baseline/optical center
Item {
    id: root
    property var labelRef
    // Optional token-style API; falls back to legacy props
    property var scaleToken:undefined
    property var baselineOffsetToken:undefined
    property real scale: 1.0
    property int baselineAdjust:0
    property string mode: "text"
    // Auto-tune size to match label visual height
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

    // Alignment: "baseline" (default) or "optical" (center-to-center)
    property string alignMode: "baseline"
    // Optional target to reuse vertical center offset
    property var alignTarget: null
    // Optional ascent compensation (legacy)
    property bool compensateMetrics: false
    property real compensationFactor: 1.0

    // Effective inputs (token adds to direct prop)
    readonly property real _effScale: (typeof scaleToken === 'number') ? scaleToken : scale
    readonly property int  _effBaselineOffset: ((typeof baselineOffsetToken === 'number') ? baselineOffsetToken : 0) + baselineAdjust

    // Fallback base size when labelRef is missing
    readonly property int _labelPx: (labelRef && labelRef.font && labelRef.font.pixelSize)
        ? labelRef.font.pixelSize : Theme.fontSizeSmall

    implicitWidth: (mode === "material") ? materialItem.implicitWidth : textItem.implicitWidth
    implicitHeight: (mode === "material") ? materialItem.implicitHeight : textItem.implicitHeight

    FontMetrics { id: fmLabel; font: (root.labelRef && root.labelRef.font) ? root.labelRef.font : Qt.font({ pixelSize: root._labelPx }) }
    // Probes for auto-tuning (hidden)
    Text {
        id: labelProbe
        visible: false
        text: "H"
        font: (root.labelRef && root.labelRef.font) ? root.labelRef.font : Qt.font({ pixelSize: root._labelPx })
    }
    MaterialIcon {
        id: matProbe
        visible: false
        icon: root.icon
        size: root._labelPx
    }
    Text {
        id: textProbe
        visible: false
        text: root.text
        font.family: root.fontFamily || Theme.fontFamily
        font.styleName: root.fontStyleName
        font.pixelSize: root._labelPx
    }
    // Auto scale ratio from measured heights
    readonly property real _autoScale:
        (autoTune && mode === "material" && labelProbe.contentHeight > 0 && matProbe.contentHeight > 0)
            ? Utils.clamp(labelProbe.contentHeight / matProbe.contentHeight, 0.6, 1.2)
        : (autoTune && mode === "text" && labelProbe.contentHeight > 0 && textProbe.contentHeight > 0)
            ? Utils.clamp(labelProbe.contentHeight / textProbe.contentHeight, 0.6, 1.2)
            : 1.0
    // Center offsets (positive is downward)
    function centerOffset(ascent, descent) { return (descent - ascent) / 2.0 }
    function computeCenterOffset(iconAscent, iconDescent) {
        var off = root._effBaselineOffset;
        var labelCenter = centerOffset(fmLabel.ascent, fmLabel.descent);
        var iconCenter  = centerOffset(iconAscent, iconDescent);
        if (root.alignMode === "optical") {
            // Align visual centers
            off = off + (labelCenter - iconCenter);
        } else {
            // Align baselines via center math
            off = off - (labelCenter - iconCenter);
            if (root.compensateMetrics) {
                off = off + (fmLabel.ascent - iconAscent) * root.compensationFactor;
            }
        }
        return Math.round(off);
    }
    // Expose current offset for external alignment
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

    // Baseline for external anchoring (distance from top)
    property real baselineOffset: (mode === 'material')
        ? (materialItem.baselineOffset + _effBaselineOffset)
        : (textItem.baselineOffset + _effBaselineOffset)

    // Visual baseline delta for external alignment
    readonly property real baselineVisualDelta: (function(){
        var lc = centerOffset(fmLabel.ascent, fmLabel.descent);
        if (root.mode === 'material') {
            return lc - centerOffset(fmMat.ascent, fmMat.descent);
        } else {
            return lc - centerOffset(fmText.ascent, fmText.descent);
        }
    })()
}
