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
    // Avoid layout cycles by providing an implicit width
    implicitWidth: mediaRow.implicitWidth
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

        // Album art (no overlay to keep new elongated spectrum clear)
        Item {
            id: albumArtContainer
            width: 24 * Theme.scale(Screen)
            height: 24 * Theme.scale(Screen)
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                id: albumArtwork
                width: 24 * Theme.scale(Screen)
                height: 24 * Theme.scale(Screen)
                anchors.centerIn: parent
                color: Qt.darker(Theme.surface, 1.1)
                border.color: Qt.rgba(Theme.accentPrimary.r, Theme.accentPrimary.g, Theme.accentPrimary.b, 0.3)
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

        // Track info at original position with spectrum below title only
        Item {
            id: trackContainer
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            // Provide implicit width so RowLayout can measure without parent width
            implicitWidth: titleText.implicitWidth + 8 * Theme.scale(Screen) + timeText.implicitWidth
            // keep container height to the text's height so row layout remains unchanged
            height: titleText.implicitHeight

            // Linear spectrum rendered behind the text (bottom half only)
            LinearSpectrum {
                id: linearSpectrum
                anchors.left: parent.left
                // Place the spectrum just below the title text, slightly overlapping upward
                anchors.top: titleText.bottom
                anchors.topMargin: -Math.round(titleText.font.pixelSize * Settings.settings.spectrumOverlapFactor)
                height: Math.round(titleText.font.pixelSize * Settings.settings.spectrumHeightFactor)
                // Limit spectrum width to the actual title text area (does not intrude into time)
                width: Math.ceil(titleText.width)
                values: MusicManager.cavaValues
                amplitudeScale: 1.0
                barGap: Settings.settings.spectrumBarGap * Theme.scale(Screen)
                minBarWidth: 2 * Theme.scale(Screen)
                mirror: Settings.settings.spectrumMirror
                drawTop: Settings.settings.showSpectrumTopHalf
                drawBottom: true
                fillOpacity: Settings.settings.spectrumFillOpacity
                peakOpacity: 0.7
                useGradient: Settings.settings.spectrumUseGradient
                barColor: Theme.accentPrimary
                // Push spectrum to the very bottom within this container
                z: -1
            }

            // Dim the spectrum area under text for readability
            Rectangle {
                id: textBackdrop
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: Math.round(titleText.font.pixelSize * 1.15)
                radius: 4 * Theme.scale(Screen)
                color: Qt.rgba(Theme.backgroundPrimary.r, Theme.backgroundPrimary.g, Theme.backgroundPrimary.b, 0.25)
                z: 1
            }

            // No separate top-half spectrum by default (can enable via settings)

            // Title text (left)
            Text {
                id: titleText
                anchors.left: parent.left
                anchors.right: timeText.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: (MusicManager.trackArtist || MusicManager.trackTitle)
                      ? [MusicManager.trackArtist, MusicManager.trackTitle]
                            .filter(function(x){ return !!x; })
                            .join(" - ")
                      : ""
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
                elide: Text.ElideRight
                maximumLineCount: 1
                z: 2
                renderType: Text.NativeRendering
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Theme.shadow
                    shadowOpacity: 0.6
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 1
                    shadowBlur: 0.8
                }
            }

            // Time text (right)
            Text {
                id: timeText
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: (MusicManager.trackArtist || MusicManager.trackTitle)
                      ? ("[" + fmtTime(MusicManager.currentPosition || 0)
                         + "/" + fmtTime(MusicManager.mprisToMs(MusicManager.trackLength || 0)) + "]")
                      : ""
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
                elide: Text.ElideRight
                maximumLineCount: 1
                z: 2
                renderType: Text.NativeRendering
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Theme.shadow
                    shadowOpacity: 0.6
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 1
                    shadowBlur: 0.8
                }
            }
        }
    }
}
