import QtQuick
import QtQuick.Controls
import qs.Components
import "../../Helpers/Color.js" as Color
import qs.Settings
import "../../Helpers/Utils.js" as Utils
import qs.Services as Services

// Amnezia VPN status indicator (polls `ip -j -br a`)
Item {
    id: root

    property int   desiredHeight: Math.round(Theme.panelHeight * Theme.scale(Screen))
    // Match network usage label size with standard small font
    property int   fontPixelSize: Math.round(Theme.fontSizeSmall * Theme.scale(Screen))
    property bool  useTheme: true
    property bool  showLabel: true
    property int   iconSpacing: Theme.vpnIconSpacing
    property int   textPadding: Theme.vpnTextPadding
    property int   iconVAdjust: Theme.vpnIconVAdjust
    property real  iconScale: Theme.vpnIconScale
    property color bgColor: "transparent"
    property string iconName: "verified_user"
    property bool   iconRounded: false

    property real accentSaturateBoost: Theme.vpnAccentSaturateBoost
    property real accentLightenTowardWhite: Theme.vpnAccentLightenTowardWhite
    property color onColor:  Color.towardsWhite(Color.saturate(Theme.accentPrimary, accentSaturateBoost), accentLightenTowardWhite)
    property color offColor: useTheme ? Theme.textDisabled  : Theme.textDisabled
    property real  desaturateAmount: Theme.vpnDesaturateAmount
    property color accentBase: Color.saturate(Theme.accentPrimary, accentSaturateBoost)
    property color accentColor: desaturateColor(accentBase, desaturateAmount)

    property real connectedOpacity: Theme.vpnConnectedOpacity
    property real disconnectedOpacity: Theme.vpnDisconnectedOpacity
    property bool connected: false
    property string matchedIf: ""

    visible: connected
    implicitHeight: desiredHeight
    width: inlineView.implicitWidth
    height: desiredHeight

    SmallInlineStat {
        id: inlineView
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        desiredHeight: root.desiredHeight
        fontPixelSize: root.fontPixelSize
        textPadding: root.textPadding
        iconSpacing: root.iconSpacing
        iconMode: "material"
        materialIconName: root.iconName
        materialIconRounded: root.iconRounded
        iconScale: root.iconScale
        iconVAdjust: root.iconVAdjust
        iconColor: root.iconColor()
        labelVisible: root.showLabel
        labelText: "VPN"
        labelColor: root.iconColor()
    }

    Connections {
        target: Services.Connectivity
        function onInterfacesChanged() {
            try { checkInterfaces(Services.Connectivity.interfaces) }
            catch (e) { root.connected = false; root.matchedIf = "" }
        }
    }

    function mixColor(a, b, t) {
        return Qt.rgba(
            a.r * (1 - t) + b.r * t,
            a.g * (1 - t) + b.g * t,
            a.b * (1 - t) + b.b * t,
            a.a * (1 - t) + b.a * t
        )
    }
    function grayOf(c) {
        const y = 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
        return Qt.rgba(y, y, y, c.a)
    }
    function desaturateColor(c, amount) {
        amount = Utils.clamp(amount || 0, 0, 1)
        return mixColor(c, grayOf(c), amount)
    }

    function checkInterfaces(arr) {
        if (!Array.isArray(arr)) { root.connected = false; root.matchedIf = ""; return }
        let found = false
        let name = ""
        for (let it of arr) {
            const ifname = (it && it.ifname) ? String(it.ifname) : ""
            const nlow = ifname.toLowerCase()
            const looksAmnezia = nlow.includes("awg") || nlow.includes("amnez")
            if (!looksAmnezia) continue
            const addrs = Array.isArray(it.addr_info) ? it.addr_info : []
            if (addrs.length > 0) { found = true; name = ifname; break }
        }
        root.connected = found
        root.matchedIf = name
    }

    property bool  muted: true
    property bool  hovered: false
    opacity: hovered ? 1.0 : (connected ? connectedOpacity : disconnectedOpacity)
    function iconColor() {
        if (!connected) return offColor
        return accentColor
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onEntered:  root.hovered = true
        onExited:   root.hovered = false
        cursorShape: Qt.ArrowCursor
    }

    Component.onCompleted: { try { checkInterfaces(Services.Connectivity.interfaces) } catch (_) {} }
}
