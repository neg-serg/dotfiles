pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Singleton {
    property string shellName: "quickshell"
    property string settingsDir: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/" + shellName + "/"
    property string settingsFile: (settingsDir + "Settings.json")
    property string themeFile: (settingsDir + "Theme.json")
    property var settings: settingAdapter

    Item {
        Component.onCompleted: {
            Quickshell.execDetached(["mkdir", "-p", settingsDir]); // ensure settings dir
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
        onLoaded: function() {
            Qt.callLater(function () {
                WallpaperManager.setCurrentWallpaper(settings.currentWallpaper, true);
            })
        }
        onLoadFailed: function(error) {
            settingAdapter = {}
            writeAdapter()
        }
        JsonAdapter {
            id: settingAdapter
            property string weatherCity: "Moscow"
            property string profileImage: Quickshell.env("HOME") + "/.face"
            property bool useFahrenheit: false
            property string wallpaperFolder: "~/pic/wl/"
            property string currentWallpaper: ""
            property string videoPath: "~/vid/"
            property bool showSystemInfoInBar: false
            property bool showMediaInBar: false
            property bool useSWWW: false
            property bool randomWallpaper: false
            property bool useWallpaperTheme: false
            property int wallpaperInterval: 300
            property string wallpaperResize: "crop"
            property int transitionFps: 60
            property string transitionType: "random"
            property real transitionDuration: 1.1
            property string visualizerType: "radial"
            property bool reverseDayMonth: false
            property bool use12HourClock: false
            property bool dimPanels: true
            property real fontSizeMultiplier: 1.0  // Font size multiplier (1.0 = normal, 1.2 = 20% larger, 0.8 = 20% smaller)
            property var pinnedExecs: [] // Added for AppLauncher pinned apps

            property bool showDock: true
            property bool dockExclusive: false
            property bool wifiEnabled: false
            property bool bluetoothEnabled: false
            property int recordingFrameRate: 60
            property string recordingQuality: "very_high"
            property string recordingCodec: "h264"
            property string audioCodec: "opus"
            property bool showCursor: true
            property string colorRange: "limited"

            // Media spectrum / CAVA visualization
            property int  cavaBars: 64
            property bool spectrumUseGradient: false
            property bool spectrumMirror: false
            property bool showSpectrumTopHalf: false
            property real spectrumFillOpacity: 0.35
            property real spectrumHeightFactor: 1.2
            property real spectrumOverlapFactor: 0.2  // how much overlaps upward from baseline (0..1 of font size)
            property real spectrumBarGap: 1.0         // gap between bars in px (scaled later)

            // Media time brackets styling
            // Options: "round" (( )), "tortoise" (〔 〕), "lenticular" (〖 〗), "lenticular_black" (【 】),
            //          "angle" (⟨ ⟩), "square" ([ ])
            property string timeBracketStyle: "round"

            // Monitor/Display Settings
            property string panelPosition: "top" // "top" or "bottom" panel location
            property var barMonitors: [] // Array of monitor names to show the bar on
            property var dockMonitors: [] // Array of monitor names to show the dock on
            property var monitorScaleOverrides: {} // Map of monitor name -> scale override (e.g., 0.8..2.0). When set, Theme.scale() returns this value
        }
    }

    Connections {
        target: settingAdapter
        function onRandomWallpaperChanged() { WallpaperManager.toggleRandomWallpaper() }
        function onWallpaperIntervalChanged() { WallpaperManager.restartRandomWallpaperTimer() }
        function onWallpaperFolderChanged() { WallpaperManager.loadWallpapers() }
    }
}
