import QtQuick
import qs.Components

// Baseline-aligned icon helper. Aligns either a text glyph or a Material icon
// to the baseline of a reference label, with adjustable scale and baseline offset.
Item {
    id: root
    // Reference label whose baseline we align to
    property var labelRef
    // Size relative to labelRef font pixel size
    property real scale: 1.0
    // Additional baseline offset (px)
    property int baselineOffset: 0
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

    // Optional ascent compensation to stabilize alignment across scales/fonts
    // When true, adds (label.ascent - icon.ascent) * compensationFactor to baselineOffset
    property bool compensateMetrics: true
    property real compensationFactor: 1.0

    // Fallback base size when labelRef is not available
    readonly property int _labelPx: (labelRef && labelRef.font && labelRef.font.pixelSize)
        ? labelRef.font.pixelSize : Theme.fontSizeSmall

    implicitWidth: (mode === "material") ? materialItem.implicitWidth : textItem.implicitWidth
    implicitHeight: (mode === "material") ? materialItem.implicitHeight : textItem.implicitHeight

    // Label metrics for compensation
    FontMetrics { id: fmLabel; font: (root.labelRef && root.labelRef.font) ? root.labelRef.font : Qt.font({ pixelSize: root._labelPx }) }

    // Text glyph mode
    Text {
        id: textItem
        visible: root.mode === "text"
        text: root.text
        color: root.color
        padding: root.padding
        font.family: root.fontFamily || Theme.fontFamily
        font.styleName: root.fontStyleName
        font.pixelSize: Math.max(1, Math.round(root._labelPx * root.scale))
        renderType: Text.NativeRendering
        anchors.baseline: (root.labelRef && root.labelRef.baseline !== undefined) ? root.labelRef.baseline : undefined
        FontMetrics { id: fmText; font: textItem.font }
        anchors.baselineOffset: Math.round(root.baselineOffset + (root.compensateMetrics ? (fmLabel.ascent - fmText.ascent) * root.compensationFactor : 0))
    }

    // Material icon mode
    MaterialIcon {
        id: materialItem
        visible: root.mode === "material"
        icon: root.icon
        rounded: root.rounded
        size: Math.max(1, Math.round(root._labelPx * root.scale))
        color: root.color
        screen: root.screen
        anchors.baseline: (root.labelRef && root.labelRef.baseline !== undefined) ? root.labelRef.baseline : undefined
        FontMetrics { id: fmMat; font: materialItem.font }
        anchors.baselineOffset: Math.round(root.baselineOffset + (root.compensateMetrics ? (fmLabel.ascent - fmMat.ascent) * root.compensationFactor : 0))
    }
}
