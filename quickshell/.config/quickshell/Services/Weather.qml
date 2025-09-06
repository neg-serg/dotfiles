pragma Singleton
import QtQuick
import qs.Settings
import qs.Services as Services
import "../Helpers/Weather.js" as WeatherHelper

// Weather service with TTL caching; consumers set enabled and read weatherData/errorString
Item {
    id: root

    // Inputs
    property string city: (Settings.settings && Settings.settings.weatherCity) ? Settings.settings.weatherCity : ""
    property int ttlMs: 60000
    property bool enabled: false

    // State
    property var weatherData: null
    property string errorString: ""
    property bool isLoading: false
    property int lastFetchTime: 0

    function fetchNow() {
        if (!root.city || String(root.city).trim() === "") { root.errorString = "No city configured"; return; }
        var now = Date.now();
        if (root.lastFetchTime > 0 && (now - root.lastFetchTime) < ttlMs) return;
        root.isLoading = true;
        root.errorString = "";
        WeatherHelper.fetchCityWeather(root.city,
            function(result) {
                root.weatherData = result.weather;
                root.lastFetchTime = now;
                root.errorString = "";
                root.isLoading = false;
            },
            function(err) {
                root.errorString = String(err || "Weather error");
                root.isLoading = false;
            },
            { userAgent: Settings.settings.userAgent, debug: Settings.settings.debugNetwork }
        );
    }

    function start() { enabled = true; fetchNow(); }
    function stop() { enabled = false; }

    Connections {
        target: Settings.settings
        function onWeatherCityChanged() { try { root.city = Settings.settings.weatherCity || ""; root.lastFetchTime = 0; if (enabled) fetchNow(); } catch (e) {} }
    }

    // Periodic TTL check using consolidated timers
    Connections {
        target: Services.Timers
        function onTick2s() { if (enabled) fetchNow(); }
    }
}

