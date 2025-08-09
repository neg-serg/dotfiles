import QtQuick 
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick.Effects
import qs.Settings
import qs.Services
import qs.Components

Item {
    id: mediaControl
    width: visible ? mediaRow.width : 0
    height: 36 * Theme.scale(Screen)
    visible: Settings.settings.showMediaInBar && MusicManager.currentPlayer

    RowLayout {
        id: mediaRow
        height: parent.height
        spacing: 8

        // AlbumArtWidget.qml
        // Compact album art + circular spectrum + play/pause overlay with aggressive debug logging
        // Expects a Singleton named MusicManager (pragma Singleton) that exposes coverUrl, cavaValues, playback state, etc.
        // Comments are in English as requested.
        Item {
            id: albumArtContainer
            // External layout sizing
            width: 24 * Theme.scale(Screen)
            height: 24 * Theme.scale(Screen)
            Layout.alignment: Qt.AlignVCenter

            // --- DEBUG: container is ready ---
            Component.onCompleted: {
                console.log("[albumArtContainer] completed",
                "scale:", Theme.scale(Screen),
                "player? ", !!MusicManager.currentPlayer)
            }

            // Circular spectrum visualizer
            CircularSpectrum {
                id: spectrum
                values: MusicManager.cavaValues
                anchors.centerIn: parent
                innerRadius: 10 * Theme.scale(Screen)
                outerRadius: 18 * Theme.scale(Screen)
                fillColor: Theme.accentPrimary
                strokeColor: Theme.accentPrimary
                strokeWidth: 0
                z: 0

                // // --- DEBUG: ensure CAVA values are coming ---
                // Component.onCompleted: {
                //     console.log("[spectrum] CAVA values length:", values ? values.length : -1)
                // }
                // onValuesChanged: {
                //     if (values && values.length)
                //     console.log("[spectrum] values[0..3]:", values[0], values[1], values[2], values[3])
                // }
            }

            // Album art frame (rounded, antialiased, clipped to circle)
            Rectangle {
                id: albumArtwork
                width: 20 * Theme.scale(Screen)
                height: 20 * Theme.scale(Screen)
                anchors.centerIn: parent
                radius: width / 2             // perfect circle
                color: Qt.darker(Theme.surface, 1.1)
                border.color: Qt.rgba(Theme.accentPrimary.r, Theme.accentPrimary.g, Theme.accentPrimary.b, 0.3)
                border.width: 1
                z: 1

                // --- Smoothing for rounded clip edges ---
                clip: true
                antialiasing: true            // smooth rounded border/clip
                layer.enabled: true
                layer.smooth: true            // linear filtering on layer scaling
                layer.samples: 4              // MSAA; consider 8 if GPU allows

                // --- DEBUG: size & DPR info ---
                Component.onCompleted: {
                    console.log("[albumArtwork] size:", width, "x", height,
                    "dpr:", Screen.devicePixelRatio, "radius:", radius)
                }

                // Album art image (with HiDPI-friendly settings)
                Image {
                    id: cover
                    anchors.fill: parent
                    source: MusicManager.coverUrl

                    // Image quality knobs
                    smooth: true               // linear filtering on texture
                    mipmap: true               // better minification transitions
                    // Request higher rasterization for HiDPI
                    sourceSize: Qt.size(
                        Math.round(width  * Screen.devicePixelRatio),
                        Math.round(height * Screen.devicePixelRatio)
                    )
                    fillMode: Image.PreserveAspectCrop
                    cache: true

                    // --- DEBUG: log URL, status, progress ---
                    onSourceChanged: console.log("[cover] source ->", source)
                    onStatusChanged: {
                        // 1: Loading, 2: Ready, 3: Error, 0: Null
                        console.log("[cover] status:", status,
                        status === Image.Null    ? "Null"    :
                        status === Image.Loading ? "Loading" :
                        status === Image.Ready   ? "Ready"   : "Error",
                        "progress:", progress)
                        if (status === Image.Error) {
                            console.warn("[cover] ERROR:", cover.errorString, "url:", source)
                        }
                    }
                    onProgressChanged: console.log("[cover] progress:", progress)

                    // Show only when ready
                    visible: status === Image.Ready
                }

                // React to MusicManager/player changes (for logs)
                Connections {
                    target: MusicManager.currentPlayer
                    enabled: !!MusicManager.currentPlayer

                    function onTrackArtUrlChanged() {
                        const u = MusicManager.currentPlayer ? MusicManager.currentPlayer.trackArtUrl : "<none>"
                        console.log("[player] trackArtUrl changed:", u)
                    }
                    function onMetadataChanged() {
                        try {
                            const md = MusicManager.currentPlayer ? MusicManager.currentPlayer.metadata : null
                            const art = md ? (md["mpris:artUrl"] || md["xesam:artUrl"]) : ""
                            console.log("[player] metadata changed; artUrl:", art,
                            "title:", MusicManager.trackTitle,
                            "artist:", MusicManager.trackArtist)
                        } catch (e) {
                            console.warn("[player] metadata change: exception:", e)
                        }
                    }
                    function onIsPlayingChanged() {
                        console.log("[player] isPlaying:", MusicManager.isPlaying)
                    }
                    function onPositionChanged() {
                        console.log("[player] position:", MusicManager.currentPosition, "/", MusicManager.trackLength)
                    }
                }

                // Fallback icon when image isn't ready
                Text {
                    id: fallbackIcon
                    anchors.centerIn: parent
                    text: "music_note"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 14 * Theme.scale(Screen)
                    color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.4)
                    visible: !cover.visible
                    Component.onCompleted: console.log("[fallbackIcon] visible:", visible)
                    onVisibleChanged: console.log("[fallbackIcon] visible:", visible)
                }

                // Play/Pause overlay (visible on hover)
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Qt.rgba(0, 0, 0, 0.5)
                    visible: playButton.containsMouse
                    z: 2

                    Text {
                        anchors.centerIn: parent
                        text: MusicManager.isPlaying ? "pause" : "play_arrow"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 14 * Theme.scale(Screen)
                        color: "white"
                    }
                }

                MouseArea {
                    id: playButton
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    enabled: MusicManager.canPlay || MusicManager.canPause
                    onClicked: {
                        console.log("[playButton] click; toggling play/pause")
                        MusicManager.playPause()
                    }
                    onEntered: console.log("[playButton] hover enter")
                    onExited: console.log("[playButton] hover exit")
                }
            }

            // Extra logs when MusicManager signals change
            Connections {
                target: MusicManager
                function onCoverUrlChanged() {
                    console.log("[MusicManager] coverUrl ->", MusicManager.coverUrl)
                }
                function onCurrentPlayerChanged() {
                    console.log("[MusicManager] currentPlayer changed ->",
                    MusicManager.currentPlayer ? MusicManager.currentPlayer.identity : "<none>",
                    "canControl:", MusicManager.currentPlayer ? MusicManager.currentPlayer.canControl : false)
                }
            }
        }

        // Track info
        Text {
            text:  MusicManager.trackArtist + " - " +  MusicManager.trackTitle
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.weight: Font.Medium
            font.pixelSize: Theme.fontSizeSmall  * Theme.scale(Screen)
            elide: Text.ElideRight
            Layout.maximumWidth: 900
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
