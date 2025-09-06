import QtQuick
import QtQuick.Controls
import qs.Settings
import "../../Helpers/Format.js" as Format
import "../../Helpers/Utils.js" as Utils
import qs.Components
import qs.Services as Services

Item {
    id: root
    property var    screen: null
    property int    desiredHeight: Math.round(Theme.panelHeight * Theme.scale(Screen))
    // Use standard small font size to match other bar text
    property int    fontPixelSize: Math.round(Theme.fontSizeSmall * Theme.scale(Screen))
    property color  textColor: Theme.textPrimary
    property color  separatorColor: Theme.accentHover
    property color  bgColor:   "transparent"
    property int    iconSpacing: Theme.panelRowSpacingSmall
    property string deviceMatch: ""
    property string displayText: "0"
    property bool   useTheme: true
    property bool   hasLink: Services.Connectivity.hasLink
    property bool   hasInternet: Services.Connectivity.hasInternet

    property real   iconScale: Theme.networkIconScale
    property color  iconColor: useTheme ? Theme.textSecondary : Theme.textSecondary
    property int    iconVAdjust: Theme.networkIconVAdjust   // vertical nudge (px)
    property string iconText: ""
    property string iconFontFamily: "Font Awesome 6 Free"
    property string iconStyleName: "Solid"

    property int    textPadding: Theme.panelRowSpacingSmall

    implicitHeight: desiredHeight
    width: inlineView.implicitWidth
    height: desiredHeight

    Rectangle {
        anchors.fill: parent
        color: bgColor
        visible: bgColor !== "transparent"
    }

    readonly property int computedFontPx: fontPixelSize > 0
        ? fontPixelSize
        : Utils.computedInlineFontPx(desiredHeight, textPadding, Theme.panelComputedFontScale)

    SmallInlineStat {
        id: inlineView
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        desiredHeight: root.desiredHeight
        fontPixelSize: root.fontPixelSize
        textPadding: root.textPadding
        iconSpacing: root.iconSpacing
        iconMode: "glyph"
        iconGlyph: iconText
        iconFontFamily: iconFontFamily
        iconStyleName: iconStyleName
        iconScale: root.iconScale
        iconVAdjust: root.iconVAdjust
        iconColor: currentIconColor()
        labelIsRichText: true
        labelText: displayText && displayText.indexOf('/') !== -1
                   ? displayText.replace('/', Format.sepSpan(separatorColor, '/'))
                   : displayText
        labelColor: textColor
        labelFontFamily: Theme.fontFamily
    }

    function fmtKiBps(kib) { return kib.toFixed(1) }
    function formatRxTx(rx, tx) {
        try {
            if (!isFinite(rx)) rx = 0; if (!isFinite(tx)) tx = 0;
            if (rx === 0 && tx === 0) return "0";
            return `${fmtKiBps(rx)}/${fmtKiBps(tx)}K`;
        } catch (e) { return "0"; }
    }
    Connections {
        target: Services.Connectivity
        function onRxKiBpsChanged() { root.displayText = formatRxTx(Services.Connectivity.rxKiBps, Services.Connectivity.txKiBps) }
        function onTxKiBpsChanged() { root.displayText = formatRxTx(Services.Connectivity.rxKiBps, Services.Connectivity.txKiBps) }
    }
    Component.onCompleted: { displayText = formatRxTx(Services.Connectivity.rxKiBps, Services.Connectivity.txKiBps) }

    function currentIconColor() {
        if (!root.hasLink) return (Settings.settings.networkNoLinkColor || Theme.error)
        if (!root.hasInternet) return (Settings.settings.networkNoInternetColor || Theme.warning)
        return root.iconColor
    }
}
