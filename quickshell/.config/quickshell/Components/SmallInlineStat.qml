import QtQuick
import QtQuick.Controls
import qs.Components
import qs.Settings
import "../Helpers/Utils.js" as Utils

Item {
    id: root
    // Sizing
    property int desiredHeight: 28
    property int fontPixelSize: 0
    property int textPadding: Theme.panelRowSpacingSmall
    property int iconSpacing: Theme.panelRowSpacingSmall
    // Icon
    property string iconMode: "glyph" // "glyph" | "material"
    // Glyph mode
    property string iconGlyph: ""                  // Text glyph
    property string iconFontFamily: ""
    property string iconStyleName: ""
    // Material mode
    property string materialIconName: ""
    property bool materialIconRounded: false
    // Icon tuning
    property real iconScale: 1.0
    property int iconVAdjust: 0
    property color iconColor: Theme.textSecondary
    // Label
    property bool labelVisible: true
    property string labelText: ""
    property color labelColor: Theme.textPrimary
    property string labelFontFamily: Theme.fontFamily
    property bool labelIsRichText: false
    // Misc
    property var screen: null
    property color bgColor: "transparent"
    // Fine vertical nudge for whole block (px)
    property int centerOffset: 0

    readonly property int computedFontPx: fontPixelSize > 0
        ? fontPixelSize
        : Utils.computedInlineFontPx(desiredHeight, textPadding, Theme.panelComputedFontScale)

    implicitHeight: desiredHeight
    implicitWidth: lineBox.implicitWidth
    width: lineBox.implicitWidth
    height: desiredHeight

    Rectangle { anchors.fill: parent; color: bgColor; visible: bgColor !== "transparent" }

    Row {
        id: lineBox
        spacing: iconSpacing
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.centerOffset
        anchors.left: parent.left

        // Icon container keeps vertical centering consistent
        Item {
            id: iconBox
            implicitHeight: root.desiredHeight
            implicitWidth: iconGlyphItem.implicitWidth

            // Glyph mode (Text)
            Text {
                id: glyphItem
                visible: root.iconMode === "glyph"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: root.iconVAdjust
                text: root.iconGlyph
                color: root.iconColor
                font.family: root.iconFontFamily
                font.styleName: root.iconStyleName
                font.weight: Font.Normal
                font.pixelSize: Utils.clamp(Math.round(root.computedFontPx * root.iconScale), 8, 2048)
                renderType: Text.NativeRendering
            }

            // Material icon mode
            MaterialIcon {
                id: materialItem
                visible: root.iconMode === "material"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: root.iconVAdjust
                icon: root.materialIconName
                rounded: root.materialIconRounded
                size: Utils.clamp(Math.round(root.computedFontPx * root.iconScale), 8, 2048)
                color: root.iconColor
            }

            // Helper for implicit width regardless of mode
            Item { id: iconGlyphItem; implicitWidth: (root.iconMode === "glyph" ? glyphItem.implicitWidth : materialItem.width) }
        }

        Label {
            id: label
            visible: root.labelVisible
            textFormat: root.labelIsRichText ? Text.RichText : Text.PlainText
            text: root.labelText
            color: root.labelColor
            font.family: root.labelFontFamily
            font.pixelSize: root.computedFontPx
            padding: textPadding
            verticalAlignment: Text.AlignVCenter
        }
    }
}
