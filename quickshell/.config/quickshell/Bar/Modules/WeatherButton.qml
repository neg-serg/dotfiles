
import QtQuick
import qs.Components
import Quickshell.Wayland
import qs.Settings
import qs.Widgets.SidePanel

Item {
    id: root
    property bool expanded: false

    height: Math.round(Theme.panelIconSize * Theme.scale(Screen))
    width: Math.round(Theme.panelIconSize * Theme.scale(Screen))

    IconButton {
        id: weatherBtn
        anchors.centerIn: parent
        size: Math.round(Theme.panelIconSize * Theme.scale(Screen))
        icon: "partly_cloudy_day"
        cornerRadius: Theme.cornerRadiusSmall
        accentColor: Theme.accentPrimary
        iconNormalColor: Theme.textPrimary
        iconHoverColor: Theme.onAccent
        onClicked: root.toggle()
        hoverEnabled: true
        onEntered: {
            try { weather.startWeatherFetch(); } catch (e) {}
        }
    }

    function toggle() {
        expanded = !expanded;
        if (expanded) {
            weatherOverlay.show();
        } else {
            weatherOverlay.dismiss();
        }
    }

    PanelWithOverlay {
        id: weatherOverlay
        visible: false
        WlrLayershell.namespace: "sideleft-weather"
        onVisibleChanged: {
            if (visible) {
                try { weather.startWeatherFetch(); } catch (e) {}
            } else {
                try { weather.stopWeatherFetch(); } catch (e) {}
            }
        }
        Rectangle {
            id: popup
            radius: Math.round(Theme.panelOverlayRadius * Theme.scale(Screen))
            color: Theme.overlayWeak
            border.color: Theme.borderSubtle
            border.width: Theme.uiBorderWidth
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: Math.round(Theme.sidePanelSpacingMedium * Theme.scale(Screen))
            anchors.leftMargin: Math.round(Theme.panelSideMargin * Theme.scale(Screen))

            Weather {
                id: weather
                width: Math.round(Theme.sidePanelWeatherWidth * Theme.scale(Screen))
                height: Math.round(Theme.sidePanelWeatherHeight * Theme.scale(Screen))
            }
        }
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: { root.expanded = false; weatherOverlay.dismiss(); }
        }
    }

    // Tooltip with city and current temperature (if available)
    StyledTooltip {
        id: weatherTip
        targetItem: weatherBtn
        positionAbove: false
        delay: Theme.tooltipDelayMs
        tooltipVisible: weatherBtn.hovering
        text: root.tooltipText()
    }

    function tooltipText() {
        try {
            const city = Settings.settings.weatherCity || "";
            const data = weather.weatherData;
            if (data && data.current_weather && typeof data.current_weather.temperature === 'number') {
                const c = Math.round(data.current_weather.temperature);
                const useF = Settings.settings.useFahrenheit || false;
                const t = useF ? Math.round(c * 9/5 + 32) + "°F" : c + "°C";
                return (city ? (city + ": ") : "") + t;
            }
            return city ? ("Погода: " + city) : "Погода";
        } catch (e) {
            return "Погода";
        }
    }

    Connections {
        target: weather
        function onWeatherDataChanged() { weatherTip.text = root.tooltipText(); }
    }
}
