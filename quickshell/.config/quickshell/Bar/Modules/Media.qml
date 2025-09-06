import QtQuick
import "../../Helpers/Utils.js" as Utils
import QtQuick.Controls
import QtQuick.Layouts
// Quickshell.Widgets not needed
import QtQuick.Effects
import "../../Helpers/Format.js" as Format
import "../../Helpers/RichText.js" as Rich
import "../../Helpers/Time.js" as Time
import "../../Helpers/Color.js" as Color
import qs.Settings
import qs.Services
import qs.Components

Item {
    id: mediaControl
    property var sidePanelPopup: null
    implicitWidth: mediaRow.implicitWidth
    height: Math.round((Theme.panelModuleHeight !== undefined ? Theme.panelModuleHeight : 36) * Theme.scale(Screen))
    visible: Settings.settings.showMediaInBar
             && MusicManager.currentPlayer
             && !MusicManager.isStopped
             && (MusicManager.isPlaying
                 || MusicManager.isPaused
                 || (MusicManager.trackTitle && MusicManager.trackTitle.length > 0))

    property int musicTextPx: Math.round(Theme.fontSizeSmall * Theme.scale(Screen))

    RowLayout {
        id: mediaRow
        height: parent.height
        spacing: Math.round(Theme.panelWidgetSpacing * Theme.scale(Screen))

        Item {
            id: albumArtContainer
            width: Math.round(Theme.panelIconSize * Theme.scale(Screen))
            height: Math.round(Theme.panelIconSize * Theme.scale(Screen))
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                id: albumArtwork
                width: Math.round(Theme.panelIconSize * Theme.scale(Screen))
                height: Math.round(Theme.panelIconSize * Theme.scale(Screen))
                anchors.centerIn: parent
                color: Theme.surface
                border.color: "transparent"
                border.width: Theme.uiBorderNone
                clip: true
                antialiasing: true
                layer.enabled: true
                layer.smooth: true
                layer.samples: 4

                HiDpiImage {
                    id: cover
                    anchors.fill: parent
                    source: (MusicManager.coverUrl || "")
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                }

                MaterialIcon {
                    id: fallbackIcon
                    anchors.centerIn: parent
                    icon: "music_note"
                    size: Math.round(Theme.panelIconSizeSmall * Theme.scale(Screen))
                    color: Color.withAlpha(Theme.textPrimary, Theme.mediaAlbumArtFallbackOpacity)
                    visible: !cover.visible
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Theme.overlayWeak
                    visible: playButton.containsMouse
                    z: 2
                    MaterialIcon {
                        anchors.centerIn: parent
                        icon: MusicManager.isPlaying ? "pause" : "play_arrow"
                        size: Math.round(Theme.panelIconSizeSmall * Theme.scale(Screen))
                        color: Theme.onAccent
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

        
        Item {
            id: trackContainer
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            // Fill row height immediately to avoid post-start drift when text metrics settle
            Layout.fillHeight: true
            // Keep implicit sizes tied to content for layout, but do not bind height to text
            implicitWidth: trackText.implicitWidth
            implicitHeight: mediaControl.height

            

            MouseArea {
                id: trackSidePanelClick
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                property real _lastMoveTs: 0
                property bool _armed: false
                onEntered: {
                    _lastMoveTs = Date.now();
                    _armed = true;
                    hoverOpenTimer.restart();
                }
                onExited: {
                    _armed = false;
                    if (hoverOpenTimer.running) hoverOpenTimer.stop();
                }
                onPositionChanged: {
                    _lastMoveTs = Date.now();
                    if (!hoverOpenTimer.running) hoverOpenTimer.restart();
                }
                Timer {
                    id: hoverOpenTimer
                    interval: Theme.mediaHoverOpenDelayMs
                    repeat: false
                    onTriggered: {
                        try {
                            if (!trackSidePanelClick._armed) return;
                            const stillMs = Date.now() - trackSidePanelClick._lastMoveTs;
                            if (stillMs < Theme.mediaHoverStillThresholdMs) { restart(); return; }
                            if (mediaControl.sidePanelPopup && trackText.text && trackText.text.length > 0) {
                                mediaControl.sidePanelPopup.showAt();
                            }
                        } catch (e) { /* ignore */ }
                    }
                }
                onClicked: {
                    try {
                        if (mediaControl.sidePanelPopup) {
                            if (mediaControl.sidePanelPopup.visible) mediaControl.sidePanelPopup.hidePopup();
                            else mediaControl.sidePanelPopup.showAt();
                        }
                    } catch (e) { /* ignore */ }
                }
                cursorShape: Qt.PointingHandCursor
            }

            Text {
                id: titleMeasure
                visible: false
                text: (MusicManager.trackArtist || MusicManager.trackTitle)
                      ? [MusicManager.trackArtist, MusicManager.trackTitle]
                            .filter(function(x){ return !!x; })
                            .join(" — ")
                      : ""
                font.family: Theme.fontFamily
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
            }

            LinearSpectrum {
                id: linearSpectrum
                visible: Settings.settings.showMediaVisualizer === true && MusicManager.isPlaying && (trackText.text && trackText.text.length > 0)
                anchors.left: parent.left
                anchors.top: textFrame.bottom
                anchors.topMargin: -Math.round(trackText.font.pixelSize * (
                    (Settings.settings.visualizerProfiles
                     && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile]
                     && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumOverlapFactor !== undefined)
                        ? Utils.clamp(Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumOverlapFactor, 0, 1)
                        : Utils.clamp(Settings.settings.spectrumOverlapFactor, 0, 1)
                    
                    +
                    (Settings.settings.visualizerProfiles
                     && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile]
                     && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumVerticalRaise !== undefined)
                        ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumVerticalRaise
                        : Settings.settings.spectrumVerticalRaise
                ))
                height: Math.round(trackText.font.pixelSize * Settings.settings.spectrumHeightFactor)
                // Limit spectrum width to the measured title text width
                width: Math.ceil(titleMeasure.width)
                values: MusicManager.cavaValues
                amplitudeScale: 1.0
                barGap: (function(){ var raw = (Settings.settings.visualizerProfiles && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile] && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumBarGap !== undefined) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumBarGap : Settings.settings.spectrumBarGap; return Utils.clamp(Utils.coerceReal(raw, 1.0), 0, 10); })() * Theme.scale(Screen)
                minBarWidth: 2 * Theme.scale(Screen)
                mirror: (Settings.settings.visualizerProfiles && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile] && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumMirror !== undefined) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumMirror : Settings.settings.spectrumMirror
                drawTop: (Settings.settings.visualizerProfiles && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile] && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].showSpectrumTopHalf !== undefined) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].showSpectrumTopHalf : Settings.settings.showSpectrumTopHalf
                drawBottom: true
                fillOpacity: (function(){
                    var raw = (Settings.settings.visualizerProfiles
                               && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile]
                               && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumFillOpacity !== undefined)
                        ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumFillOpacity
                        : (Settings.settings.spectrumFillOpacity !== undefined
                           ? Settings.settings.spectrumFillOpacity
                           : Theme.spectrumFillOpacity);
                    return Utils.clamp(Utils.coerceReal(raw, Theme.spectrumFillOpacity), 0, 1);
                })()
                peakOpacity: Theme.spectrumPeakOpacity
                useGradient: (Settings.settings.visualizerProfiles && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile] && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumUseGradient !== undefined) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumUseGradient : Settings.settings.spectrumUseGradient
                barColor: Theme.accentPrimary
                z: -1
            }

            // Clip text to avoid overlap with flags; frame reserves space up to mpdSlot
            Item {
                id: textFrame
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.uiMarginNone
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                clip: true

                

                Text {
                    id: trackText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    textFormat: Text.RichText
                    renderType: Text.NativeRendering
                    wrapMode: Text.NoWrap
                    property string bracketColor: Format.colorCss(Theme.accentDarkStrong, 1)
                    property string timeColor: (function(){
                        var c = MusicManager.isPlaying ? Theme.textPrimary : Theme.textSecondary;
                        var a = MusicManager.isPlaying ? Theme.mediaTimeAlphaPlaying : Theme.mediaTimeAlphaPaused;
                        return Format.colorCss(c, a);
                    })()
                    property string titlePart: (MusicManager.trackArtist || MusicManager.trackTitle)
                        ? [MusicManager.trackArtist, MusicManager.trackTitle].filter(function(x){return !!x;}).join(" - ")
                        : ""
                    text: (function(){
                        if (!trackText.titlePart) return "";
                        const sepChar = (Settings.settings.mediaTitleSeparator || '—');
                        const t = Rich.esc(trackText.titlePart)
                                   .replace(/\s(?:-|–|—)\s/g, function(){
                                       return "&#8201;" + Rich.sepSpan(Theme.accentHover, sepChar) + "&#8201;";
                                   });
                        const cur = Format.fmtTime(MusicManager.currentPosition || 0);
                        const tot = Format.fmtTime(Time.mprisToMs(MusicManager.trackLength || 0));
                        const bp = Rich.bracketPair(Settings.settings.timeBracketStyle || "square");
                        return t
                               + " &#8201;" + Rich.bracketSpan(trackText.bracketColor, bp.l)
                               + Rich.timeSpan(trackText.timeColor, cur)
                               + Rich.sepSpan(Theme.accentHover, '/')
                               + Rich.timeSpan(trackText.timeColor, tot)
                               + Rich.bracketSpan(trackText.bracketColor, bp.r);
                    })()
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.weight: Font.Medium
                    font.pixelSize: mediaControl.musicTextPx
                    maximumLineCount: 1
                    z: 2
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Theme.shadow
                        shadowOpacity: Theme.uiShadowOpacity
                        shadowHorizontalOffset: Theme.uiShadowOffsetX
                        shadowVerticalOffset: Theme.uiShadowOffsetY
                        shadowBlur: Theme.uiShadowBlur
                    }
                }
            }

        }
    }

    

    
}
