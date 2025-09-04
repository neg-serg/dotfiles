import QtQuick 
import QtQuick.Controls
import QtQuick.Layouts
// Quickshell.Widgets not needed
// (Io import removed)
import QtQuick.Effects
import "../../Helpers/Format.js" as Format
import "../../Helpers/Time.js" as Time
import qs.Settings
import qs.Services
import qs.Components

Item {
    id: mediaControl
    property var sidePanelPopup: null
    implicitWidth: mediaRow.implicitWidth
    height: 36 * Theme.scale(Screen)
    visible: Settings.settings.showMediaInBar
             && MusicManager.currentPlayer
             && !MusicManager.isStopped
             && (MusicManager.isPlaying
                 || MusicManager.isPaused
                 || (MusicManager.trackTitle && MusicManager.trackTitle.length > 0))

    property int musicTextPx: Math.round(Theme.fontSizeSmall * Theme.scale(Screen))

    // Time formatting moved to Helpers/Format.js
    RowLayout {
        id: mediaRow
        height: parent.height
        spacing: 12

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
                    size: 14 * Theme.scale(Screen)
                    color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.4)
                    visible: !cover.visible
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Qt.rgba(0, 0, 0, 0.5)
                    visible: playButton.containsMouse
                    z: 2
                    MaterialIcon {
                        anchors.centerIn: parent
                        icon: MusicManager.isPlaying ? "pause" : "play_arrow"
                        size: 14 * Theme.scale(Screen)
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

        
        Item {
            id: trackContainer
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            // Fill row height immediately to avoid post-start drift when text metrics settle
            Layout.fillHeight: true
            // Keep implicit sizes tied to content for layout, but do not bind height to text
            implicitWidth: trackText.implicitWidth
            implicitHeight: mediaControl.height

            // (MPD detection centralized in MusicManager)

            // Debug logging removed

            // (MPD flags moved to Bar/Bar.qml as a separate section)

            // Hover-to-open with dwell; click also opens
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
                    interval: 320
                    repeat: false
                    onTriggered: {
                        try {
                            if (!trackSidePanelClick._armed) return;
                            const stillMs = Date.now() - trackSidePanelClick._lastMoveTs;
                            if (stillMs < 180) { restart(); return; }
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

            // Hidden measurer for title (so spectrum width doesn't intrude into time)
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

            // Linear spectrum rendered behind the text (bottom half only)
            LinearSpectrum {
                id: linearSpectrum
                visible: Settings.settings.showMediaVisualizer === true && MusicManager.isPlaying && (trackText.text && trackText.text.length > 0)
                anchors.left: parent.left
                // Place the spectrum behind the text area, slightly raised into it
                anchors.top: textFrame.bottom
                // Use active profile overrides if present
                anchors.topMargin: -Math.round(trackText.font.pixelSize * (
                    (Settings.settings.visualizerProfiles
                     && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile]
                     && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumOverlapFactor !== undefined)
                        ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumOverlapFactor
                        : Settings.settings.spectrumOverlapFactor
                    
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
                barGap: ((Settings.settings.visualizerProfiles && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile] && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumBarGap !== undefined) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumBarGap : Settings.settings.spectrumBarGap) * Theme.scale(Screen)
                minBarWidth: 2 * Theme.scale(Screen)
                mirror: (Settings.settings.visualizerProfiles && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile] && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumMirror !== undefined) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumMirror : Settings.settings.spectrumMirror
                drawTop: (Settings.settings.visualizerProfiles && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile] && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].showSpectrumTopHalf !== undefined) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].showSpectrumTopHalf : Settings.settings.showSpectrumTopHalf
                drawBottom: true
                fillOpacity: (Settings.settings.visualizerProfiles && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile] && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumFillOpacity !== undefined) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumFillOpacity : Settings.settings.spectrumFillOpacity
                peakOpacity: 0.7
                useGradient: (Settings.settings.visualizerProfiles && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile] && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumUseGradient !== undefined) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile].spectrumUseGradient : Settings.settings.spectrumUseGradient
                barColor: Theme.accentPrimary
                // Push spectrum to the very bottom within this container
                z: -1
            }

            // Clip text to avoid overlap with flags; frame reserves space up to mpdSlot
            Item {
                id: textFrame
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                clip: true

                // Backdrop under text removed to avoid darkening the title area

                // Single rich text line: title + [cur/tot] inline; clipped by frame
                Text {
                    id: trackText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    textFormat: Text.RichText
                    renderType: Text.NativeRendering
                    wrapMode: Text.NoWrap
                    // Build HTML with colored separators and escaped content
                    function esc(s) {
                        s = (s === undefined || s === null) ? "" : String(s);
                        return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
                    }
                    // Separator color (dash and slash): almost as dark as brackets
                    // Use a slightly higher brightness factor than brackets
                    // 165% lighter than brackets (clamped)
                    property real sepB: Math.min(1, bracketB * 2.65)
                    property string sepColor: (
                        "rgba(" 
                        + Math.round(Theme.accentPrimary.r * sepB * 255) + ","
                        + Math.round(Theme.accentPrimary.g * sepB * 255) + ","
                        + Math.round(Theme.accentPrimary.b * sepB * 255) + ",1)"
                    )
                    // Bracket color only: dark accent derived from calendar/tray
                    property real bracketB: (Settings.settings.trayAccentBrightness !== undefined ? Settings.settings.trayAccentBrightness : 0.25)
                    // Make brackets 1.5x lighter (clamped to 1.0)
                    property real bracketLight: Math.min(1, bracketB * 1.5)
                    property string bracketColor: (
                        "rgba(" 
                        + Math.round(Theme.accentPrimary.r * bracketLight * 255) + ","
                        + Math.round(Theme.accentPrimary.g * bracketLight * 255) + ","
                        + Math.round(Theme.accentPrimary.b * bracketLight * 255) + ",1)"
                    )
                    // Time color: dim and desaturate when paused
                    property string timeColor: (function(){
                        var c = MusicManager.isPlaying ? Theme.textPrimary : Theme.textSecondary;
                        var a = MusicManager.isPlaying ? 1.0 : 0.8;
                        return (
                            "rgba(" + Math.round(c.r * 255) + ","
                                     + Math.round(c.g * 255) + ","
                                     + Math.round(c.b * 255) + "," + a + ")"
                        );
                    })()
                    property string titlePart: (MusicManager.trackArtist || MusicManager.trackTitle)
                        ? [MusicManager.trackArtist, MusicManager.trackTitle].filter(function(x){return !!x;}).join(" - ")
                        : ""
                    function bracketPair() {
                        const s = (Settings.settings.timeBracketStyle || "square").toLowerCase();
                        switch (s) {
                            case "round":              return { l: "(",    r: ")"     };
                            case "lenticular":        return { l: "\u3016", r: "\u3017" };
                            case "lenticular_black":  return { l: "\u3010", r: "\u3011" };
                            case "angle":             return { l: "\u27E8", r: "\u27E9" };
                            case "square":            return { l: "[",    r: "]"     };
                            case "tortoise":          return { l: "\u3014", r: "\u3015" };
                            default:                   return { l: "[",    r: "]"     };
                        }
                    }
                    text: (function(){
                        if (!trackText.titlePart) return "";
                        const t = trackText.esc(trackText.titlePart)
                                   .replace(/\s(?:-|–|—)\s/g, "&#8201;<span style='color:" + trackText.sepColor + "; font-weight:bold'>—</span>&#8201;");
                        const cur = Format.fmtTime(MusicManager.currentPosition || 0);
                        const tot = Format.fmtTime(Time.mprisToMs(MusicManager.trackLength || 0));
                        const timeSize = Math.max(1, Math.round(trackText.font.pixelSize * 0.8));
                        const bp = trackText.bracketPair();
                        return t
                               + " &#8201;<span style='color:" + trackText.bracketColor + "'>" + bp.l + "</span>"
                               + "<span style='font-size:" + timeSize + "px; vertical-align: middle; line-height:1; color:" + trackText.timeColor + "'>" + cur + "</span>"
                               + "<span style='color:" + trackText.sepColor + "; font-weight:bold'>/</span>"
                               + "<span style='font-size:" + timeSize + "px; vertical-align: middle; line-height:1; color:" + trackText.timeColor + "'>" + tot + "</span>"
                               + "<span style='color:" + trackText.bracketColor + "'>" + bp.r + "</span>";
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
                        shadowOpacity: 0.6
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 1
                        shadowBlur: 0.8
                    }
                }
            }

            // (Time is embedded in trackText; no separate right block)
        }
    }

    // Tooltip removed

    // --- Fancy info builder removed -------------------------
}
