import QtQuick
import "../../Helpers/Utils.js" as Utils
import QtQuick.Layouts
import QtQuick.Controls
import qs.Settings
import qs.Components
import "../../Helpers/Color.js" as Color
import qs.Services as Services
 
Rectangle {
    id: weatherRoot
    width: Math.round(Theme.sidePanelWeatherWidth * Theme.scale(Screen))
    height: Math.round(Theme.sidePanelWeatherHeight * Theme.scale(Screen))
    color: "transparent"
    anchors.horizontalCenterOffset: Theme.weatherCenterOffset
 
    property string city: Settings.settings.weatherCity !== undefined ? Settings.settings.weatherCity : ""
    property var weatherData: Services.Weather.weatherData
    property string errorString: Services.Weather.errorString
    property bool isVisible: false
    property int lastFetchTime: 0
    property bool isLoading: Services.Weather.isLoading
 
    Connections { target: Services.Weather; function onWeatherDataChanged() { weatherRoot.weatherData = Services.Weather.weatherData } }
 
    Component.onCompleted: { if (isVisible) Services.Weather.start() }
 
    function fetchCityWeather() { Services.Weather.start() }
 
    function startWeatherFetch() { isVisible = true; Services.Weather.start() }
 
    function stopWeatherFetch() { isVisible = false; Services.Weather.stop() }

    function warnContrast(bg, fg, label) {
        try {
            if (!(Settings.settings && Settings.settings.debugContrast)) return;
            var ratio = Color.contrastRatio(bg, fg);
            var th = (Settings.settings && Settings.settings.contrastWarnRatio) ? Settings.settings.contrastWarnRatio : 4.5;
            if (ratio < th) console.debug('[Contrast]', label || 'text', 'ratio', ratio.toFixed(2));
        } catch (e) {}
    }
 
    Rectangle {
        id: card
        anchors.fill: parent
        color: Color.withAlpha(Theme.accentDarkStrong, Theme.weatherCardOpacity)
        border.color: Theme.borderSubtle
        border.width: Theme.uiBorderWidth
        radius: Math.round(Theme.sidePanelCornerRadius * Theme.scale(Screen))
 
        ColumnLayout {
            anchors.fill: parent
        anchors.margins: Math.round(Theme.panelSideMargin * Theme.scale(Screen))
            spacing: Math.round(Theme.sidePanelSpacing * Theme.scale(Screen))
 
 
            RowLayout {
                spacing: Math.round(Theme.sidePanelSpacing * Theme.scale(Screen))
                Layout.fillWidth: true
 
 
                RowLayout {
                    spacing: Math.round(Theme.sidePanelSpacing * Theme.scale(Screen))
                    Layout.preferredWidth: Math.round(weatherRoot.width * Theme.sidePanelWeatherLeftColumnRatio)
 
 
                    Spinner {
                        id: loadingSpinner
                        running: isLoading
                        color: Theme.accentPrimary
                        size: Math.round(Theme.uiIconSizeLarge * Theme.scale(Screen))
                        Layout.alignment: Qt.AlignVCenter
                        visible: isLoading
                    }

                    MaterialIcon {
                        id: weatherIcon
                        visible: !isLoading
                        icon: weatherData && weatherData.current_weather ? materialSymbolForCode(weatherData.current_weather.weathercode) : "cloud"
                        size: Math.round(Theme.uiIconSizeLarge * Theme.scale(Screen))
                        color: Theme.accentPrimary
                        Layout.alignment: Qt.AlignVCenter
                    }
 
                    ColumnLayout {
                        spacing: Math.round(Theme.sidePanelSpacingSmall * Theme.scale(Screen))
                        RowLayout {
                            spacing: Math.round(Theme.sidePanelSpacingSmall * Theme.scale(Screen))
                            Text {
                                text: city
                                font.family: Theme.fontFamily
                                font.pixelSize: Math.round(Theme.fontSizeSmall * Theme.scale(Screen))
                                font.bold: true
                                color: Theme.textOn(card.color)
                            }
                            Text {
                                text: weatherData && weatherData.timezone_abbreviation ? `(${weatherData.timezone_abbreviation})` : ""
                                font.family: Theme.fontFamily
                                    font.pixelSize: Math.round(Theme.tooltipFontPx * Theme.tooltipSmallScaleRatio * Theme.scale(Screen))
                                color: Theme.textOn(card.color)
                                leftPadding: Math.round(Theme.sidePanelSpacingSmall * 0.5 * Theme.scale(Screen))
                            }
                        }
                        Text {
                            text: weatherData && weatherData.current_weather ? ((Settings.settings.useFahrenheit !== undefined ? Settings.settings.useFahrenheit : false) ? `${Math.round(weatherData.current_weather.temperature * 9/5 + 32)}°F` : `${Math.round(weatherData.current_weather.temperature)}°C`) : ((Settings.settings.useFahrenheit !== undefined ? Settings.settings.useFahrenheit : false) ? "--°F" : "--°C")
                            font.family: Theme.fontFamily
                            font.pixelSize: Math.round(Theme.fontSizeHeader * Theme.weatherHeaderScale * Theme.scale(Screen))
                            font.bold: true
                            color: Theme.textOn(card.color)
                            Component.onCompleted: weatherRoot.warnContrast(card.color, color, 'weather.current')
                        }
                    }
                }
 
                Item {
                    Layout.fillWidth: true
                }
            }
 
 
            Rectangle {
                width: parent.width
                height: Utils.clamp(Math.round(Theme.tooltipBorderWidth * Theme.scale(Screen)), 1, 64)
                color: Theme.borderSubtle
                radius: Theme.uiSeparatorRadius
                Layout.fillWidth: true
                Layout.topMargin: Math.round(Theme.sidePanelSpacingSmall * 0.5 * Theme.scale(Screen))
                Layout.bottomMargin: Math.round(Theme.sidePanelSpacingSmall * 0.5 * Theme.scale(Screen))
            }
 
 
            RowLayout {
                spacing: Math.round(Theme.sidePanelSpacing * Theme.scale(Screen))
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                visible: weatherData && weatherData.daily && weatherData.daily.time
 
                Repeater {
                    model: weatherData && weatherData.daily && weatherData.daily.time ? 5 : 0
                    delegate: ColumnLayout {
                        spacing: Math.round(Theme.sidePanelSpacingSmall * Theme.scale(Screen))
                        Layout.alignment: Qt.AlignHCenter
                        Text {

                            text: Qt.formatDateTime(new Date(weatherData.daily.time[index]), "ddd")
                            font.family: Theme.fontFamily
                            font.pixelSize: Math.round(Theme.fontSizeCaption * Theme.scale(Screen))
                            color: Theme.textOn(card.color)
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                            Component.onCompleted: weatherRoot.warnContrast(card.color, color, 'weather.dailyLabel')
                        }
                        MaterialIcon {
                            icon: materialSymbolForCode(weatherData.daily.weathercode[index])
                            size: Math.round(Theme.panelPillIconSize * Theme.scale(Screen))
                            color: Theme.accentPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {

                            text: weatherData && weatherData.daily ? ((Settings.settings.useFahrenheit !== undefined ? Settings.settings.useFahrenheit : false) ? `${Math.round(weatherData.daily.temperature_2m_max[index] * 9/5 + 32)}° / ${Math.round(weatherData.daily.temperature_2m_min[index] * 9/5 + 32)}°` : `${Math.round(weatherData.daily.temperature_2m_max[index])}° / ${Math.round(weatherData.daily.temperature_2m_min[index])}°`) : ((Settings.settings.useFahrenheit !== undefined ? Settings.settings.useFahrenheit : false) ? "--° / --°" : "--° / --°")
                            font.family: Theme.fontFamily
                            font.pixelSize: Math.round(Theme.fontSizeCaption * Theme.scale(Screen))
                            color: Theme.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                            Component.onCompleted: weatherRoot.warnContrast(card.color, color, 'weather.daily')
                        }
                    }
                }
            }
 
 
            Text {
                text: errorString
                color: Theme.error
                visible: errorString !== ""
                font.family: Theme.fontFamily
                font.pixelSize: Math.round(Theme.tooltipFontPx * 0.71 * Theme.scale(Screen))
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
 
 
    function materialSymbolForCode(code) {
        if (code === 0) return "sunny";
        if (code === 1 || code === 2) return "partly_cloudy_day";
        if (code === 3) return "cloud";
        if (code >= 45 && code <= 48) return "foggy";
        if (code >= 51 && code <= 67) return "rainy";
        if (code >= 71 && code <= 77) return "weather_snowy";
        if (code >= 80 && code <= 82) return "rainy";
        if (code >= 95 && code <= 99) return "thunderstorm";
        return "cloud";
    }
    function weatherDescriptionForCode(code) {
        if (code === 0) return "Clear sky";
        if (code === 1) return "Mainly clear";
        if (code === 2) return "Partly cloudy";
        if (code === 3) return "Overcast";
        if (code === 45 || code === 48) return "Fog";
        if (code >= 51 && code <= 67) return "Drizzle";
        if (code >= 71 && code <= 77) return "Snow";
        if (code >= 80 && code <= 82) return "Rain showers";
        if (code >= 95 && code <= 99) return "Thunderstorm";
        return "Unknown";
    }
} 
