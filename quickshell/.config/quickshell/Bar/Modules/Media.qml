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
            // Provide implicit size from single combined text (old display)
            implicitWidth: trackText.implicitWidth
            // keep container height to the text's height so row layout remains unchanged
            height: trackText.implicitHeight

            // Hidden measurer for title (so spectrum width doesn't intrude into time)
            Text {
                id: titleMeasure
                visible: false
                text: (MusicManager.trackArtist || MusicManager.trackTitle)
                      ? [MusicManager.trackArtist, MusicManager.trackTitle]
                            .filter(function(x){ return !!x; })
                            .join(" - ")
                      : ""
                font.family: Theme.fontFamily
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
            }

            // Linear spectrum rendered behind the text (bottom half only)
            LinearSpectrum {
                id: linearSpectrum
                anchors.left: parent.left
                // Place the spectrum just below the text, slightly overlapping upward
                anchors.top: trackText.bottom
                anchors.topMargin: -Math.round(trackText.font.pixelSize * Settings.settings.spectrumOverlapFactor)
                height: Math.round(trackText.font.pixelSize * Settings.settings.spectrumHeightFactor)
                // Limit spectrum width to the measured title text width
                width: Math.ceil(titleMeasure.width)
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
                height: Math.round(trackText.font.pixelSize * 1.15)
                radius: 4 * Theme.scale(Screen)
                color: Qt.rgba(Theme.backgroundPrimary.r, Theme.backgroundPrimary.g, Theme.backgroundPrimary.b, 0.25)
                z: 1
            }

            // No separate top-half spectrum by default (can enable via settings)

            // Combined text (artist - title [time]) with colored separators (old display)
            Text {
                id: trackText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                textFormat: Text.RichText
                renderType: Text.NativeRendering
                // Build HTML with colored separators and escaped content
                function esc(s) {
                    s = (s === undefined || s === null) ? "" : String(s);
                    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
                }
                property string sepColor: "#3b7bb3"
                property string titlePart: (MusicManager.trackArtist || MusicManager.trackTitle)
                    ? [MusicManager.trackArtist, MusicManager.trackTitle].filter(function(x){return !!x;}).join(" - ")
                    : ""
                function bracketPair() {
                    const s = (Settings.settings.timeBracketStyle || "square").toLowerCase();
                    switch (s) {
                        // Small-form round parentheses for tighter spacing
                        case "round":              return { l: "\uFE59", r: "\uFE5A" }; // ﹙ ﹚
                        case "lenticular":        return { l: "\u3016", r: "\u3017" }; // 〖 〗
                        case "lenticular_black":  return { l: "\u3010", r: "\u3011" }; // 【 】
                        case "angle":             return { l: "\u27E8", r: "\u27E9" }; // ⟨ ⟩
                        case "square":            return { l: "[",    r: "]"     };
                        case "tortoise":          return { l: "\u3014", r: "\u3015" }; // 〔 〕
                        default:                   return { l: "[",    r: "]"     };
                    }
                }
                text: (function(){
                    if (!trackText.titlePart) return "";
                    const t = trackText.esc(trackText.titlePart).replace(/\s-\s/g, " <span style='color:" + trackText.sepColor + "'>-</span> ");
                    const cur = fmtTime(MusicManager.currentPosition || 0);
                    const tot = fmtTime(MusicManager.mprisToMs(MusicManager.trackLength || 0));
                    const timeSize = Math.max(1, Math.round(trackText.font.pixelSize * 0.8));
                    const bp = trackText.bracketPair();
                    // No extra space before bracket to minimize gap; shrink bracket size; raise time via <sup>
                    return t
                           + " &#8201;<span style='color:" + trackText.sepColor + "'>" + bp.l + "</span>"
                           + "<span style='font-size:" + timeSize + "px; vertical-align: middle; line-height:1'>" + cur + "</span>"
                           + "<span style='color:" + trackText.sepColor + "'>/</span>"
                           + "<span style='font-size:" + timeSize + "px; vertical-align: middle; line-height:1'>" + tot + "</span>"
                           + "<span style='color:" + trackText.sepColor + "'>" + bp.r + "</span>";
                })()
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
                elide: Text.ElideRight
                maximumLineCount: 1
                z: 2
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

            // (Time is embedded in trackText; no separate right block)
        }
    }
}
