import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Window 2.15
import qs.Settings
import qs.Components
import qs.Services
import "../../Helpers/Color.js" as Color
import "../../Helpers/Format.js" as Format
import "../../Helpers/RichText.js" as Rich

Rectangle {
    id: musicCard
    // Use attached Window.window when available; fallback to Screen
    property var screen: (Window.window && Window.window.screen) ? Window.window.screen : Screen
    color: "transparent"
    implicitHeight: playerUI.implicitHeight

    function warnContrast(bg, fg, label) {
        try {
            if (!(Settings.settings && Settings.settings.enforceContrastWarnings)) return;
            var ratio = Color.contrastRatio(bg, fg);
            var th = (Settings.settings && Settings.settings.contrastWarnRatio) ? Settings.settings.contrastWarnRatio : 4.5;
            if (ratio < th) console.warn('[Music] Low contrast', label || 'text', ratio.toFixed(2));
        } catch (e) {}
    }

        Rectangle {
            id: card
            anchors.fill: parent
            color: Theme.background
            border.color: "transparent"
            border.width: Theme.uiBorderNone
            radius: Math.round(Theme.sidePanelCornerRadius * Theme.scale(Screen))

        Item {
            width: parent.width
            height: parent.height
            visible: !MusicManager.currentPlayer

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Math.round(Theme.sidePanelSpacing * 1.33 * Theme.scale(screen))

                Text {
                    text: "music_note"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: Theme.fontSizeHeader * Theme.scale(screen)
                    color: Theme.textOn(card.color, Theme.textSecondary, Theme.textPrimary)
                    Layout.alignment: Qt.AlignHCenter
                    Component.onCompleted: musicCard.warnContrast(card.color, color, 'fallbackIcon')
                }

                Text {
                    text: MusicManager.hasPlayer ? "No controllable player selected" : "No music player detected"
                    color: playerUI.musicTextColor
                    font.family: Theme.fontFamily
                    font.pixelSize: playerUI.musicTextPx
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        ColumnLayout {
            id: playerUI
            anchors.fill: parent
            anchors.leftMargin: Theme.uiMarginNone
            anchors.rightMargin: Theme.uiMarginNone
            anchors.topMargin: Theme.uiMarginNone
            anchors.bottomMargin: Theme.uiMarginNone
            spacing: Math.round(Theme.sidePanelSpacingSmall * Theme.scale(screen))
            visible: !!MusicManager.currentPlayer

            // Typography
            property int musicFontPx: Math.round(Theme.fontSizeSmall * Theme.scale(screen))
            property int musicTextPx: Math.round(Theme.fontSizeSmall * Theme.scale(screen))
            property color musicTextColor: Theme.textOn(card.color)
            Component.onCompleted: musicCard.warnContrast(card.color, musicTextColor, 'musicText')
            property int musicFontWeight: Font.Medium

            

            // Player selector
            property var uniquePlayers: []
            readonly property bool showCombo: false
            readonly property bool showSingleLabel: false
            function dedupePlayers() {
                try {
                    const list = MusicManager.getAvailablePlayers() || [];
                    function nameOf(p, i) {
                        if (!p) return `Player ${i+1}`;
                        return p.identity || p.name || p.id || `Player ${i+1}`;
                    }
                    const seen = Object.create(null);
                    const out = [];
                    for (let i = 0; i < list.length; i++) {
                        const p = list[i];
                        if (!p) continue;
                        const key = (p.identity || p.name || p.id || ("idx_"+i));
                        if (seen[key]) continue;
                        seen[key] = true;
                        out.push({ identity: nameOf(p, i), idx: i });
                    }
                    uniquePlayers = out;
                    // Try to keep current selection in sync
                    if (MusicManager.currentPlayer) {
                        const curKey = (MusicManager.currentPlayer.identity || MusicManager.currentPlayer.name || MusicManager.currentPlayer.id);
                        let idx = 0;
                        for (let j = 0; j < uniquePlayers.length; j++) {
                            const upName = uniquePlayers[j] && uniquePlayers[j].identity;
                            if (upName === curKey) { idx = j; break; }
                        }
                        playerSelector.currentIndex = idx;
                    }
                } catch (e) {
                    // ignore
                }
            }
            // Refresh list periodically and on player change (centralized timer)
            Connections { target: Timers; function onTick2s() { playerUI.dedupePlayers() } }
            Connections { target: MusicManager; function onCurrentPlayerChanged() { playerUI.dedupePlayers() } }
            ComboBox {
                id: playerSelector
                Layout.fillWidth: true
                Layout.preferredHeight: playerUI.showCombo ? 40 * Theme.scale(screen) : 0
                visible: playerUI.showCombo
                height: visible ? implicitHeight : 0
                model: playerUI.uniquePlayers
                textRole: "identity"
                currentIndex: 0
                onActivated: (index) => {
                    try {
                        if (playerUI.uniquePlayers && playerUI.uniquePlayers[index]) {
                            MusicManager.selectedPlayerIndex = playerUI.uniquePlayers[index].idx;
                            MusicManager.updateCurrentPlayer();
                        }
                    } catch (e) { /* ignore */ }
                }
            
                background: Rectangle {
                    implicitWidth: Math.round(Theme.sidePanelSelectorMinWidth * Theme.scale(screen))
                    implicitHeight: Math.round(Theme.uiControlHeight * Theme.scale(screen))
                    // Match window/card palette
                    color: card.color
                    border.color: "transparent"
                    border.width: Theme.uiBorderNone
                    radius: Math.round(Theme.sidePanelCornerRadius * Theme.scale(Screen))
                }

                contentItem: Text {
                    leftPadding: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                    rightPadding: playerSelector.indicator.width + playerSelector.spacing
                    text: playerSelector.displayText
                    font.pixelSize: playerUI.musicTextPx
                    color: playerUI.musicTextColor
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                indicator: Text {
                    x: playerSelector.width - width - Math.round(Theme.sidePanelSpacing * Theme.scale(screen))
                    y: playerSelector.topPadding + (playerSelector.availableHeight - height) / 2
                    text: "arrow_drop_down"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: playerUI.musicTextPx
                    color: playerUI.musicTextColor
                }

                popup: Popup {
                    y: playerSelector.height
                    width: playerSelector.width
                    implicitHeight: contentItem.implicitHeight
                    padding: Math.round(Theme.uiGapTiny * Theme.scale(screen))

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: playerSelector.popup.visible ? playerSelector.delegateModel : null
                        currentIndex: playerSelector.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator {}
                    }

                    background: Rectangle {
                        color: card.color
                        border.color: "transparent"
                        border.width: Theme.uiBorderNone
                        radius: Math.round(Theme.sidePanelCornerRadius * Theme.scale(Screen))
                    }
                }

                delegate: ItemDelegate {
                    width: playerSelector.width
                    contentItem: Text {
                        text: modelData.identity
                        font.weight: playerUI.musicFontWeight
                        font.pixelSize: playerUI.musicTextPx
                        color: playerUI.musicTextColor
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    highlighted: playerSelector.highlightedIndex === index

                    background: ThemedHoverRect {
                        colorToken: Theme.surfaceHover
                        radiusFactor: 0
                        epsToken: Theme.uiVisibilityEpsilon
                        intensity: highlighted ? 1.0 : 0.0
                    }
                }

            Text {
                visible: playerUI.showSingleLabel
                Layout.preferredHeight: visible ? (28 * Theme.scale(screen)) : 0
                height: visible ? implicitHeight : 0
                text: playerUI.showSingleLabel ? playerUI.uniquePlayers[0].identity : ""
                color: playerUI.musicTextColor
                font.family: Theme.fontFamily
                font.pixelSize: playerUI.musicTextPx
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            }

            RowLayout {
                spacing: Math.round(Theme.sidePanelSpacingSmall * Theme.scale(screen))
                Layout.fillWidth: true

                Item {
                    id: albumArtContainer
                    width: albumArtwork.width
                    height: albumArtwork.height
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    

                    Rectangle {
                        id: albumArtwork
                            width: Math.round(Theme.sidePanelAlbumArtSize * Theme.scale(screen))
                            height: Math.round(Theme.sidePanelAlbumArtSize * Theme.scale(screen))
                            anchors.fill: parent
                            radius: Math.round(Theme.sidePanelCornerRadius * Theme.scale(screen))
                            color: "transparent"
                            border.color: "transparent"
                            border.width: Theme.uiBorderNone

                        HiDpiImage {
                            id: albumArt
                            anchors.fill: parent
                            anchors.margins: Theme.uiMarginNone
                            fillMode: Image.PreserveAspectCrop
                            cache: false
                            source: (MusicManager.coverUrl || "")
                            visible: source && source.toString() !== ""
                            onStatusChanged: { if (status === Image.Ready) accentSampler.requestPaint() }

                            // Apply rounded-rect mask (corner radius)
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskSource: mask
                            }
                        }
                        Canvas { id: accentSampler; width: 24; height: 24; visible: false; onPaint: {
                            try {
                                var ctx = getContext('2d');
                                ctx.reset();
                                if (!albumArt.source || albumArt.source.toString() === '') return;
                                ctx.drawImage(albumArt.source, 0, 0, width, height);
                                var img = ctx.getImageData(0, 0, width, height);
                                var data = img.data; var len = data.length;
                                var rs=0, gs=0, bs=0, n=0;
                                for (var i=0; i<len; i+=4) {
                                    var a = data[i+3]; if (a < 128) continue;
                                    var r = data[i], g = data[i+1], b = data[i+2];
                                    var maxv = Math.max(r,g,b), minv = Math.min(r,g,b);
                                    var sat = maxv - minv; if (sat < 15) continue;
                                    var lum = (r+g+b)/3; if (lum < 30 || lum > 230) continue;
                                    rs += r; gs += g; bs += b; ++n;
                                }
                                if (n > 0) {
                                    var rr = Math.min(255, Math.round(rs/n));
                                    var gg = Math.min(255, Math.round(gs/n));
                                    var bb = Math.min(255, Math.round(bs/n));
                                    detailsCol.musicAccent = Qt.rgba(rr/255.0, gg/255.0, bb/255.0, 1);
                                } else {
                                    detailsCol.musicAccent = Theme.accentPrimary;
                                }
                            } catch (e) {}
                        } }

                        Item {
                            id: mask

                            anchors.fill: albumArt
                            layer.enabled: true
                            visible: false

                            Rectangle {
                                width: albumArt.width
                                height: albumArt.height
                                radius: Math.round(Theme.sidePanelCornerRadius * Theme.scale(screen))
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "album"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: Theme.fontSizeBody * Theme.scale(screen)
                            color: Theme.textOn(card.color, Theme.textSecondary, Theme.textPrimary)
                            visible: !albumArt.visible
                        }
                    }
                }

                // Track metadata
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Math.round(Theme.sidePanelSpacingSmall * 0.5 * Theme.scale(screen))

                    // Details block: time + identity + metadata
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: detailsCol.implicitHeight
                        color: card.color
                        radius: Theme.sidePanelInnerRadius
                        border.width: Theme.uiBorderNone
                        anchors.leftMargin: Theme.uiMarginNone
                        anchors.rightMargin: Theme.uiMarginNone

                        ColumnLayout {
                            id: detailsCol
                            anchors.fill: parent
                            anchors.leftMargin: Math.round(Theme.sidePanelSpacingSmall * Theme.scale(screen))
                            anchors.rightMargin: Math.round(Theme.sidePanelSpacingSmall * Theme.scale(screen))
                            anchors.topMargin: Theme.uiMarginNone
                            anchors.bottomMargin: Theme.uiMarginNone
                            spacing: Math.round(Theme.sidePanelSpacingSmall * Theme.scale(screen))
                            // layout follows tokens; no special table-like props
                            property color musicAccent: Theme.accentPrimary
                            property string musicAccentCss: Format.colorCss(musicAccent, 1)
                            

                    

                            // Artist
                            RowLayout {
                                visible: !!MusicManager.trackArtist
                                Layout.fillWidth: true
                            spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                MaterialIcon {
                                    // Artist icon
                                    icon: "person"
                                    color: detailsCol.musicAccent
                                    size: Math.round(playerUI.musicFontPx * 1.05)
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackArtist
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    wrapMode: Text.NoWrap
                                    elide: Text.ElideRight
                                }
                            }

                            // Album artist (if different)
                            RowLayout {
                                visible: !!MusicManager.trackAlbumArtist && MusicManager.trackAlbumArtist !== MusicManager.trackArtist
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                MaterialIcon {
                                    // Album artist icon
                                    icon: "person"
                                    color: detailsCol.musicAccent
                                    size: Math.round(playerUI.musicFontPx * 1.05)
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackAlbumArtist
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    wrapMode: Text.NoWrap
                                    elide: Text.ElideRight
                                }
                            }

                            // Album
                            RowLayout {
                                visible: !!MusicManager.trackAlbum
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                MaterialIcon {
                                    // Album icon
                                    icon: "album"
                                    color: detailsCol.musicAccent
                                    size: Math.round(playerUI.musicFontPx * 1.05)
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackAlbum
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    wrapMode: Text.NoWrap
                                    elide: Text.ElideRight
                                }
                            }

                            

                            // Genre (if available)
                            RowLayout {
                                visible: !!MusicManager.trackGenre
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                MaterialIcon {
                                    // Genre icon
                                    icon: "category"
                                    color: detailsCol.musicAccent
                                    size: Math.round(playerUI.musicFontPx * Theme.mediaIconScaleEmphasis)
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackGenre
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    wrapMode: Text.NoWrap
                                    elide: Text.ElideRight
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            // Year (hide when Date is present)
                            RowLayout {
                                visible: !!MusicManager.trackYear && !MusicManager.trackDateStr
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                MaterialIcon { icon: "calendar_month"; color: detailsCol.musicAccent; size: Math.round(playerUI.musicFontPx * 1.15); Layout.alignment: Qt.AlignVCenter }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackYear
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            // Label/Publisher (if available)
                            RowLayout {
                                visible: !!MusicManager.trackLabel
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                MaterialIcon { icon: "sell"; color: detailsCol.musicAccent; size: Math.round(playerUI.musicFontPx * 1.15); Layout.alignment: Qt.AlignVCenter }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackLabel
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    wrapMode: Text.NoWrap
                                    elide: Text.ElideRight
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            // Composer (if available)
                            RowLayout {
                                visible: !!MusicManager.trackComposer
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                MaterialIcon { icon: "piano"; color: detailsCol.musicAccent; size: Math.round(playerUI.musicFontPx * 1.15); Layout.alignment: Qt.AlignVCenter }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackComposer
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    wrapMode: Text.NoWrap
                                    elide: Text.ElideRight
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            // Codec (hidden; included in Quality)
                            RowLayout {
                                visible: false
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                Text {
                                    text: "Codec"
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackCodecDetail || MusicManager.trackCodec
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    elide: Text.ElideRight
                                }
                            }

                            // Quality summary (combined)
                            RowLayout {
                                visible: !!MusicManager.trackQualitySummary
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                MaterialIcon {
                                    // Quality icon
                                    icon: "high_quality"
                                    color: musicAccent
                                    size: Math.round(playerUI.musicFontPx * Theme.mediaIconScaleEmphasis)
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    Layout.fillWidth: true
                                    // Color the middle dot with accent color; keep rest default
                                    textFormat: Text.RichText
                                    text: (function(){
                                        const s = MusicManager.trackQualitySummary || "";
                                        const c = detailsCol.musicAccentCss;
                                        // Escape full string, then replace escaped middot entity with styled span.
                                        return Rich.esc(s).replace(/&#183;/g, Rich.sepSpan(c, '\u00B7', true));
                                    })()
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    wrapMode: Text.NoWrap
                                    elide: Text.ElideRight
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            // DSD rate (icon + value, consistent with other rows)
                            RowLayout {
                                visible: !!MusicManager.trackDsdRateStr
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                MaterialIcon {
                                    // DSD rate icon
                                    icon: "speed"
                                    color: detailsCol.musicAccent
                                    size: Math.round(playerUI.musicFontPx * 1.15)
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackDsdRateStr
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            // Bit depth (hidden; included in Quality)
                            RowLayout {
                                visible: false
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                Text {
                                    text: "Bit depth"
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackBitDepthStr
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    elide: Text.ElideRight
                                }
                            }

                            // Channels (hidden; included in Quality)
                            RowLayout {
                                visible: false
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                Text {
                                    text: "Channels"
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackChannelsStr
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    elide: Text.ElideRight
                                }
                            }

                            // Channel layout (hide when Quality is shown)
                            RowLayout {
                                visible: !!MusicManager.trackChannelLayout && !MusicManager.trackQualitySummary
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                Text {
                                    text: "Layout"
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: (detailsCol && detailsCol.textWeight !== undefined) ? detailsCol.textWeight : Font.DemiBold
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackChannelLayout
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: (detailsCol && detailsCol.textWeight !== undefined) ? detailsCol.textWeight : Font.DemiBold
                                    elide: Text.ElideRight
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            // Bitrate (hidden; included in Quality)
                            RowLayout {
                                visible: false
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                Text {
                                    text: "Bitrate"
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackBitrateStr
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    elide: Text.ElideRight
                                }
                            }

                            // Track/Disc numbers (hidden by request)
                            RowLayout {
                                visible: false
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                Text {
                                    text: "Track"
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackNumberStr
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    elide: Text.ElideRight
                                }
                            }
                            RowLayout {
                                visible: false
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                Text {
                                    text: "Disc"
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackDiscNumberStr
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    elide: Text.ElideRight
                                }
                            }

                            // Path (if available)
                            

                            // Date (if available)
                            RowLayout {
                                visible: !!MusicManager.trackDateStr
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                MaterialIcon {
                                    // Date icon
                                    icon: "calendar_month"
                                    color: Theme.accentHover
                                    size: Math.round(playerUI.musicFontPx * 1.15)
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackDateStr
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            

                            // ReplayGain (if available)
                            RowLayout {
                                visible: !!MusicManager.trackRgTrackStr
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                Text {
                                    text: "RG track"
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackRgTrackStr
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                            RowLayout {
                                visible: !!MusicManager.trackRgAlbumStr
                                Layout.fillWidth: true
                                spacing: Math.round(Theme.sidePanelSpacingTight * Theme.scale(screen))
                                Text {
                                    text: "RG album"
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: MusicManager.trackRgAlbumStr
                                    color: playerUI.musicTextColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: playerUI.musicTextPx
                                    font.weight: Font.DemiBold
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }

            
        }
    }

}
