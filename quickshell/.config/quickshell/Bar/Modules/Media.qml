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
        spacing: 12
        // AlbumArtWidget.qml Compact album art + circular spectrum + play/pause overlay with aggressive debug logging Expects a Singleton
        // named MusicManager (pragma Singleton) that exposes coverUrl, cavaValues, playback state, etc.
        Item {
            id: albumArtContainer
            width: 24 * Theme.scale(Screen)
            height: 24 * Theme.scale(Screen)
            Layout.alignment: Qt.AlignVCenter
            CircularSpectrum { // Circular spectrum visualizer
                id: spectrum
                values: MusicManager.cavaValues
                anchors.centerIn: parent
                innerRadius: 14 * Theme.scale(Screen)
                outerRadius: 26 * Theme.scale(Screen)
                fillColor: Theme.accentPrimary
                strokeColor: Theme.accentPrimary
                strokeWidth: 0
                z: 2
            }

            Rectangle { // Album art frame (rounded, antialiased, clipped to circle)
                id: albumArtwork
                width: 24 * Theme.scale(Screen)
                height: 24 * Theme.scale(Screen)
                anchors.centerIn: parent
                color: Qt.darker(Theme.surface, 1.1)
                border.color: Qt.rgba(Theme.accentPrimary.r, Theme.accentPrimary.g, Theme.accentPrimary.b, 0.3)
                z: 1
                clip: true
                antialiasing: true // smooth rounded border/clip
                layer.enabled: true
                layer.smooth: true // linear filtering on layer scaling
                layer.samples: 4 // MSAA; consider 8 if GPU allows

                // Album art image (with HiDPI-friendly settings)
                Image {
                    id: cover
                    anchors.fill: parent
                    source: MusicManager.coverUrl
                    smooth: true // linear filtering on texture
                    mipmap: true // better minification transitions
                    sourceSize: Qt.size( // Request higher rasterization for HiDPI
                        Math.round(width  * Screen.devicePixelRatio),
                        Math.round(height * Screen.devicePixelRatio)
                    )
                    fillMode: Image.PreserveAspectCrop
                    cache: true
                    visible: status === Image.Ready // Show only when ready
                }

                Text { // Fallback icon when image isn't ready
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

                Rectangle { // Play/Pause overlay (visible on hover)
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
                        MusicManager.playPause()
                    }
                }
            }
        }

        Text { // Track info
            text:  MusicManager.trackArtist + " - " +  MusicManager.trackTitle
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.weight: Font.Medium
            font.pixelSize: Theme.fontSizeSmall  * Theme.scale(Screen)
            elide: Text.ElideRight
            Layout.maximumWidth: 1000
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
