import QtQuick
import "../../Helpers/Utils.js" as Utils
import QtQuick.Layouts
import QtQuick.Controls
import qs.Settings
import qs.Components
import "../../Helpers/Color.js" as Color
import "../../Helpers/Weather.js" as WeatherHelper
 
Rectangle {
    id: weatherRoot
    width: Math.round(Theme.sidePanelWeatherWidth * Theme.scale(Screen))
    height: Math.round(Theme.sidePanelWeatherHeight * Theme.scale(Screen))
    color: "transparent"
    anchors.horizontalCenterOffset: -2
 
    property string city: Settings.settings.weatherCity !== undefined ? Settings.settings.weatherCity : ""
    property var weatherData: null
    property string errorString: ""
    property bool isVisible: false
    property int lastFetchTime: 0
    property bool isLoading: false
 
    // Auto-refetch weather when city changes
    Connections {
        target: Settings.settings
        function onWeatherCityChanged() {
            if (isVisible && city !== "") {
                // Force refresh when city changes
                lastFetchTime = 0;
                fetchCityWeather();
            }
        }
    }
 
    Component.onCompleted: {
        if (isVisible) {
            fetchCityWeather()
        }
    }
 
    function fetchCityWeather() {
        if (!city || city.trim() === "") {
            errorString = "No city configured";
            return;
        }
 
        // Check if we should fetch new data (avoid fetching too frequently)
        var currentTime = Date.now();
        var timeSinceLastFetch = currentTime - lastFetchTime;
 
        // Only skip if we have recent data AND lastFetchTime is not 0 (initial state)
        if (lastFetchTime > 0 && timeSinceLastFetch < 60000) { // 1 minute
            return; // Skip if last fetch was less than 1 minute ago
        }
 
        isLoading = true;
        errorString = "";
 
        WeatherHelper.fetchCityWeather(city,
            function(result) {
                weatherData = result.weather;
                lastFetchTime = currentTime;
                errorString = "";
                isLoading = false;
            },
            function(err) {
                errorString = err;
                isLoading = false;
            },
            { userAgent: Settings.settings.userAgent, debug: Settings.settings.debugNetwork }
        );
    }
 
    function startWeatherFetch() {
        isVisible = true
        // Force refresh when panel opens, regardless of time check
        lastFetchTime = 0;
        fetchCityWeather();
    }
 
    function stopWeatherFetch() {
        isVisible = false
    }

    // Optional contrast warnings for debug
    function warnContrast(bg, fg, label) {
        try {
            if (!(Settings.settings && Settings.settings.debugContrast)) return;
            var ratio = Color.contrastRatio(bg, fg);
            var th = (Settings.settings && Settings.settings.contrastWarnRatio) ? Settings.settings.contrastWarnRatio : 4.5;
            if (ratio < th) console.warn('[Contrast]', label || 'text', 'ratio', ratio.toFixed(2));
        } catch (e) {}
    }
 
    Rectangle {
        id: card
        anchors.fill: parent
        // Dark accent background with alpha; unify with theme tokens
        color: Color.withAlpha(Theme.accentDarkStrong, 0.85)
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
                    // Width proportionate to panel width for responsiveness
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
                                color: Color.contrastOn(card.color, Theme.textPrimary, Theme.textSecondary, Theme.contrastThreshold)
                            }
                            Text {
                                text: weatherData && weatherData.timezone_abbreviation ? `(${weatherData.timezone_abbreviation})` : ""
                                font.family: Theme.fontFamily
                                    font.pixelSize: Math.round(Theme.tooltipFontPx * Theme.tooltipSmallScaleRatio * Theme.scale(Screen))
                                color: Color.contrastOn(card.color, Theme.textPrimary, Theme.textSecondary, Theme.contrastThreshold)
                                leftPadding: Math.round(Theme.sidePanelSpacingSmall * 0.5 * Theme.scale(Screen))
                            }
                        }
                        Text {
                            text: weatherData && weatherData.current_weather ? ((Settings.settings.useFahrenheit !== undefined ? Settings.settings.useFahrenheit : false) ? `${Math.round(weatherData.current_weather.temperature * 9/5 + 32)}°F` : `${Math.round(weatherData.current_weather.temperature)}°C`) : ((Settings.settings.useFahrenheit !== undefined ? Settings.settings.useFahrenheit : false) ? "--°F" : "--°C")
                            font.family: Theme.fontFamily
                            font.pixelSize: Math.round(Theme.fontSizeHeader * 0.75 * Theme.scale(Screen))
                            font.bold: true
                            color: Color.contrastOn(card.color, Theme.textPrimary, Theme.textSecondary, Theme.contrastThreshold)
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
                // Use theme subtle border for divider
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
                            color: Color.contrastOn(card.color, Theme.textPrimary, Theme.textSecondary, Theme.contrastThreshold)
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
