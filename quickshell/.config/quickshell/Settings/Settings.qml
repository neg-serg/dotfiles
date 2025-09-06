pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property string shellName: "quickshell"
    property string settingsDir: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/" + shellName + "/"
    property string settingsFile: (settingsDir + "Settings.json")
    property string themeFile: (settingsDir + "Theme.json")
    property var settings: settingAdapter

    Item {
        Component.onCompleted: {
            Quickshell.execDetached(["mkdir", "-p", settingsDir]);
        }
    }

    FileView {
        id: settingFileView
        path: settingsFile
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        Component.onCompleted: function() {
            reload()
        }
        onLoadFailed: function(error) {
            settingAdapter = {}
            writeAdapter()
        }
        JsonAdapter {
            id: settingAdapter
            property string weatherCity: "Moscow"
            property string userAgent: "NegPanel"
            property string profileImage: Quickshell.env("HOME") + "/.face"
            property bool debugNetwork: false
            property bool strictThemeTokens: false
            property bool useFahrenheit: false
            property bool showMediaInBar: false
            // Weather button in bar
            property bool showWeatherInBar: false
            property string visualizerType: "radial"
            property bool reverseDayMonth: false
            property bool use12HourClock: false
            property bool dimPanels: true
            property real fontSizeMultiplier: 1.0  // Font size multiplier (1.0 = normal, 1.2 = 20% larger, 0.8 = 20% smaller)
            property var pinnedExecs: []

            // Media spectrum / CAVA
            property int cavaBars:86
            // CAVA tuning
            property int cavaFramerate:24
            property bool cavaMonstercat: false
            property int cavaGravity:150000
            property int cavaNoiseReduction:12
            property bool spectrumUseGradient: false
            property bool spectrumMirror: false
            property bool showSpectrumTopHalf: false
            property real spectrumFillOpacity: 0.35
            property real spectrumHeightFactor: 1.2
            property real spectrumOverlapFactor: 0.2
            property real spectrumBarGap: 1.0
            property real spectrumVerticalRaise: 0.75

            property string activeVisualizerProfile: "classic"
            property var visualizerProfiles: ({
                classic: {
                    cavaBars: 86,
                    cavaFramerate: 24,
                    cavaMonstercat: false,
                    cavaGravity: 150000,
                    cavaNoiseReduction: 12,
                    spectrumFillOpacity: 0.35,
                    spectrumHeightFactor: 1.2,
                    spectrumOverlapFactor: 0.2,
                    spectrumBarGap: 1.0,
                    spectrumVerticalRaise: 0.75
                }
            })

            // Media time brackets styling
            property string timeBracketStyle: "round"
            property string mediaTitleSeparator: "—"

            // Displays
            property var barMonitors: []
            property var dockMonitors: []
            property var monitorScaleOverrides: {}

            property bool collapseSystemTray: true
            property string collapsedTrayIcon: "expand_more"
            property string trayFallbackIcon: "broken_image"

            // Global contrast
            property real contrastThreshold: 0.5
            property bool enforceContrastWarnings: false
            property bool debugContrast: false
            property real contrastWarnRatio: 4.5

            // Music player selection
            property var pinnedPlayers: []
            property var ignoredPlayers: []
            property string trayAccentColor: "#3b7bb3" // Accent color for tray button/icon
            // Tray popup background darkness blend (0 = surfaceVariant, 1 = background)
            property real trayPopupDarkness: 0.65
            // Tray button accent brightness relative to calendar accent (0..1)
            property real trayAccentBrightness: 0.25

            // Media visualizer (CAVA/LinearSpectrum) toggle
            property bool showMediaVisualizer: false

            // Player selection priority
            property var playerSelectionPriority: [
                "mpdPlaying",
                "anyPlaying",
                "mpdRecent",
                "recent",
                "manual",
                "first"
            ]
            property string playerSelectionPreset: "default"

            // Music popup sizing
            property int musicPopupWidth:840     // logical px, scaled
            property int musicPopupHeight:250    // logical px, scaled (used when content height unknown)
            property int musicPopupPadding:12    // logical px, scaled (inner content padding)

            property int networkPingIntervalMs:30000
            property string networkNoInternetColor: "#FF6E00"
            property string networkNoLinkColor: "#D81B60"
        }
    }

    
}
