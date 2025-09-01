
import QtQuick
import qs.Components
import qs.Settings
import qs.Widgets.SidePanel

Item {
    id: root
    property bool expanded: false

    height: 24 * Theme.scale(Screen)
    width: 24 * Theme.scale(Screen)

    IconButton {
        id: weatherBtn
        anchors.centerIn: parent
        size: 24 * Theme.scale(Screen)
        icon: "partly_cloudy_day"
        cornerRadius: 4
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
        onVisibleChanged: {
            if (visible) {
                try { weather.startWeatherFetch(); } catch (e) {}
            } else {
                try { weather.stopWeatherFetch(); } catch (e) {}
            }
        }
        Rectangle {
            id: popup
            radius: 9 * Theme.scale(Screen)
            color: Qt.rgba(0, 0, 0, 0.10)
            border.color: Theme.backgroundTertiary
            border.width: 1
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 8 * Theme.scale(Screen)
            anchors.leftMargin: 18 * Theme.scale(Screen)

            Weather {
                id: weather
                width: 420 * Theme.scale(Screen)
                height: 180 * Theme.scale(Screen)
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
        delay: 350
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
