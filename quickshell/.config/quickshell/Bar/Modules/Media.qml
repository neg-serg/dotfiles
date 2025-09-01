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

    // Format ms -> m:ss or h:mm:ss
    function fmtTime(ms) {
        if (ms === undefined || ms < 0) return "0:00";
        var s = Math.floor(ms / 1000);
        var m = Math.floor(s / 60);
        var h = Math.floor(m / 60);
        s = s % 60; m = m % 60;
        var mm = h > 0 ? (m < 10 ? "0"+m : ""+m) : ""+m;
        var ss = s < 10 ? "0"+s : ""+s;
        return h > 0 ? (h + ":" + mm + ":" + ss) : (mm + ":" + ss);
    }

    RowLayout {
        id: mediaRow
        height: parent.height
        spacing: 12

        // --- Album art + overlay ---
        Item {
            id: albumArtContainer
            width: 24 * Theme.scale(Screen)
            height: 24 * Theme.scale(Screen)
            Layout.alignment: Qt.AlignVCenter

            CircularSpectrum {
                id: spectrum
                values: MusicManager.cavaValues
                anchors.centerIn: parent
                visualizerType: "roundedSquare"
                amplitudeScale: 0.5
                innerRadius: 14 * Theme.scale(Screen)
                outerRadius: 26 * Theme.scale(Screen)
                fillColor: Theme.accentPrimary
                strokeColor: Theme.accentPrimary
                strokeWidth: 0
                // Render behind album art to avoid overlaying the image
                z: 0
            }

            Rectangle {
                id: albumArtwork
                width: 24 * Theme.scale(Screen)
                height: 24 * Theme.scale(Screen)
                anchors.centerIn: parent
                color: Qt.darker(Theme.surface, 1.1)
                border.color: Qt.rgba(Theme.accentPrimary.r, Theme.accentPrimary.g, Theme.accentPrimary.b, 0.3)
                z: 1
                clip: true
                antialiasing: true
                layer.enabled: true
                layer.smooth: true
                layer.samples: 4

                Image {
                    id: cover
                    anchors.fill: parent
                    source: MusicManager.coverUrl
                    smooth: true
                    mipmap: true
                    sourceSize: Qt.size(
                        Math.round(width  * Screen.devicePixelRatio),
                        Math.round(height * Screen.devicePixelRatio)
                    )
                    fillMode: Image.PreserveAspectCrop
                    cache: true
                    visible: status === Image.Ready
                }

                Text {
                    id: fallbackIcon
                    anchors.centerIn: parent
                    text: "music_note"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 14 * Theme.scale(Screen)
                    color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.4)
                    visible: !cover.visible
                }

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
                    onClicked: MusicManager.playPause()
                }
            }
        }

        // --- Track info + inline time (concatenated) ---
        Text {
            text: (MusicManager.trackArtist || MusicManager.trackTitle)
                  ? [MusicManager.trackArtist, MusicManager.trackTitle]
                        .filter(function(x){ return !!x; })
                        .join(" - ")
                    + " ["
                    + fmtTime(MusicManager.currentPosition || 0)
                    + "/" + fmtTime(MusicManager.mprisToMs(MusicManager.trackLength || 0)) + "]"
                  : ""
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.weight: Font.Medium
            font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
            elide: Text.ElideRight
            Layout.maximumWidth: 1000
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
