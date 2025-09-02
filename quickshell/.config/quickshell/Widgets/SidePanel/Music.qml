import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
// (Io import removed)
import qs.Settings
import qs.Components
import qs.Services

Rectangle {
    id: musicCard
    color: "transparent"
    implicitHeight: playerUI.implicitHeight

    // Format ms -> m:ss or h:mm:ss (same as bar media)
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

        Rectangle {
            id: card
            anchors.fill: parent
            // Almost-black with accent hue; reduce saturation by 50%
            property real cardTint: 0.10
            property real cardAlpha: 0.85 // 15% transparent
            property real desat: 0.5
            // Compute tinted base
            property real baseR: Theme.accentPrimary.r * cardTint
            property real baseG: Theme.accentPrimary.g * cardTint
            property real baseB: Theme.accentPrimary.b * cardTint
            // Luminance for neutral grey
            property real lum: 0.2126 * baseR + 0.7152 * baseG + 0.0722 * baseB
            // Mix towards luminance to reduce saturation
            color: "#000000" // Solid black background for music
            radius: 9 * Theme.scale(Screen)

        // Show fallback UI if no player is available
        Item {
            width: parent.width
            height: parent.height
            visible: !MusicManager.currentPlayer

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16 * Theme.scale(screen)

                Text {
                    text: "music_note"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: Theme.fontSizeHeader * Theme.scale(screen)
                    color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.3)
                    Layout.alignment: Qt.AlignHCenter
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

        // Main player UI
        ColumnLayout {
            id: playerUI
            anchors.fill: parent
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            spacing: 4 * Theme.scale(screen)
            visible: !!MusicManager.currentPlayer

            // Unified typography for music widget
            // Base size for icons and calculations (kept as-is)
            property int musicFontPx: Math.round(13 * Theme.scale(screen))
            // Exact text size to match the rest of the panel
            property int musicTextPx: Math.round(Theme.fontSizeSmall * Theme.scale(screen))
            property color musicTextColor: Theme.textPrimary
            property int musicFontWeight: Font.Medium

            // Fancy info removed

            // Player selector
            // Build a de-duplicated list of players by identity/id
            property var uniquePlayers: []
            // Keep header area hidden to prevent layout jumps on player discovery
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
            Component.onCompleted: playerUI.dedupePlayers()
            Timer { interval: 2000; running: true; repeat: true; onTriggered: playerUI.dedupePlayers() }
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
                    implicitWidth: 120 * Theme.scale(screen)
                    implicitHeight: 40 * Theme.scale(screen)
                    // Match window/card palette
                    color: card.color
                    border.color: "transparent"
                    border.width: 0
                    radius: 9 * Theme.scale(Screen)
                }

                contentItem: Text {
                    leftPadding: 6 * Theme.scale(screen)
                    rightPadding: playerSelector.indicator.width + playerSelector.spacing
                    text: playerSelector.displayText
                    font.pixelSize: playerUI.musicTextPx
                    color: playerUI.musicTextColor
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                indicator: Text {
                    x: playerSelector.width - width - 12 * Theme.scale(screen)
                    y: playerSelector.topPadding + (playerSelector.availableHeight - height) / 2
                    text: "arrow_drop_down"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 20 * Theme.scale(screen)
                    color: playerUI.musicTextColor
                }

                popup: Popup {
                    y: playerSelector.height
                    width: playerSelector.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1 * Theme.scale(screen)

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
                        border.width: 0
                        radius: 9 * Theme.scale(Screen)
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

                    background: Rectangle {
                        color: highlighted ? Qt.rgba(Theme.accentPrimary.r, Theme.accentPrimary.g, Theme.accentPrimary.b, 0.15) : "transparent"
                    }
                }

            // Single player label (when no need for ComboBox)
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

            // Album art with spectrum visualizer
            RowLayout {
                spacing: 4 * Theme.scale(screen)
                Layout.fillWidth: true

                // Album art container with circular spectrum overlay
                Item {
                    id: albumArtContainer
                    // Match exactly to artwork to avoid any extra left padding
                    width: albumArtwork.width
                    height: albumArtwork.height
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    // (Visualizer removed for this view as per request)

                    // Album art image (square with slight rounding) — no outer fill/border
                    Rectangle {
                        id: albumArtwork
                            // Cover at 200px (scaled)
                            width: 200 * Theme.scale(screen)
                            height: 200 * Theme.scale(screen)
                            anchors.fill: parent
                            radius: 8 * Theme.scale(screen)
                            color: "transparent"
                            border.color: "transparent"
                            border.width: 0

                        Image {
                            id: albumArt
                            anchors.fill: parent
                            anchors.margins: 0
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            mipmap: true
                            cache: false
                            asynchronous: true
                            // Request image at display pixel size for crisp rendering
                            sourceSize: Qt.size(
                                Math.round(width  * Screen.devicePixelRatio),
                                Math.round(height * Screen.devicePixelRatio)
                            )
                            source: (MusicManager.coverUrl || "")
                            visible: source && source.toString() !== ""

                            // Apply rounded-rect mask (small radius)
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskSource: mask
                            }
                        }

                        Item {
                            id: mask

                            anchors.fill: albumArt
                            layer.enabled: true
                            visible: false

                            Rectangle {
                                width: albumArt.width
                                height: albumArt.height
                                radius: 8 * Theme.scale(screen)
                            }
                        }

                        // Fallback icon when no album art available
                        Text {
                            anchors.centerIn: parent
                            text: "album"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: Theme.fontSizeBody * Theme.scale(screen)
                            color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.4)
                            visible: !albumArt.visible
                        }
                    }
                    // Remove outer glow to avoid any perceived black edge
                }

                // Track metadata
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2 * Theme.scale(screen)

                    // Title intentionally hidden per request

                    // (Upper two lines moved into details block)

                    // Extra details block (time + player identity + metadata)
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: detailsCol.implicitHeight
                        // Match card background, no rounded corners, no border
                        color: card.color
                        radius: 0
                        border.width: 0
                        anchors.leftMargin: 0
                        anchors.rightMargin: 0

                        ColumnLayout {
                            id: detailsCol
                            anchors.fill: parent
                            anchors.leftMargin: 6 * Theme.scale(screen)
                            anchors.rightMargin: 6 * Theme.scale(screen)
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0
                            spacing: 4 * Theme.scale(screen)
                            // (rollback) no special table-like layout properties

                            // (reverted) no category-colored quality block here
                            

                            // Time intentionally hidden per request

                            // Artist
                            RowLayout {
                                visible: !!MusicManager.trackArtist
                                Layout.fillWidth: true
                                spacing: 6 * Theme.scale(screen)
                                Text {
                                    // Artist icon
                                    text: "person"
                                    font.family: "Material Symbols Outlined"
                                    color: "#004E4E"
                                    font.pixelSize: Math.round(playerUI.musicFontPx * 1.05)
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
                                spacing: 6 * Theme.scale(screen)
                                Text {
                                    // Album artist icon
                                    text: "person"
                                    font.family: "Material Symbols Outlined"
                                    color: "#004E4E"
                                    font.pixelSize: Math.round(playerUI.musicFontPx * 1.05)
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
                                spacing: 6 * Theme.scale(screen)
                                Text {
                                    // Album icon
                                    text: "album"
                                    font.family: "Material Symbols Outlined"
                                    color: "#004E4E"
                                    font.pixelSize: Math.round(playerUI.musicFontPx * 1.05)
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

                            // Player line removed by request

                            // Genre (if available)
                            RowLayout {
                                visible: !!MusicManager.trackGenre
                                Layout.fillWidth: true
                                spacing: 6 * Theme.scale(screen)
                                Text {
                                    // Genre icon
                                    text: "category"
                                    font.family: "Material Symbols Outlined"
                                    color: "#004E4E"
                                    font.pixelSize: Math.round(playerUI.musicFontPx * 1.15)
                                    font.weight: Font.Bold
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
                                spacing: 6 * Theme.scale(screen)
                                Text {
                                    // Year icon
                                    text: "calendar_month"
                                    font.family: "Material Symbols Outlined"
                                    color: "#004E4E"
                                    font.pixelSize: Math.round(playerUI.musicFontPx * 1.15)
                                    font.weight: Font.Bold
                                    Layout.alignment: Qt.AlignVCenter
                                }
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
                                spacing: 6 * Theme.scale(screen)
                                Text {
                                    // Label/Publisher icon
                                    text: "sell"
                                    font.family: "Material Symbols Outlined"
                                    color: "#004E4E"
                                    font.pixelSize: Math.round(playerUI.musicFontPx * 1.15)
                                    font.weight: Font.Bold
                                    Layout.alignment: Qt.AlignVCenter
                                }
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
                                spacing: 6 * Theme.scale(screen)
                                Text {
                                    // Composer icon
                                    text: "piano"
                                    font.family: "Material Symbols Outlined"
                                    color: "#004E4E"
                                    font.pixelSize: Math.round(playerUI.musicFontPx * 1.15)
                                    font.weight: Font.Bold
                                    Layout.alignment: Qt.AlignVCenter
                                }
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
                                spacing: 6 * Theme.scale(screen)
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
                                spacing: 6 * Theme.scale(screen)
                                Text {
                                    // Quality icon
                                    text: "high_quality"
                                    font.family: "Material Symbols Outlined"
                                    color: "#004E4E"
                                    font.pixelSize: Math.round(playerUI.musicFontPx * 1.15)
                                    font.weight: Font.Bold
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    Layout.fillWidth: true
                                    // Color the middle dot with accent color; keep rest default
                                    textFormat: Text.RichText
                                    text: (function(){
                                        const s = MusicManager.trackQualitySummary || "";
                                        const c = `rgba(${Math.round(Theme.accentPrimary.r*255)},${Math.round(Theme.accentPrimary.g*255)},${Math.round(Theme.accentPrimary.b*255)},1)`;
                                        return s.replace(/\u00B7/g, `<span style='color:${c}; font-weight:bold'>&#183;</span>`);
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
                                spacing: 6 * Theme.scale(screen)
                                Text {
                                    // DSD rate icon
                                    text: "speed"
                                    font.family: "Material Symbols Outlined"
                                    color: "#004E4E"
                                    font.pixelSize: Math.round(playerUI.musicFontPx * 1.15)
                                    font.weight: Font.Bold
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
                                spacing: 6 * Theme.scale(screen)
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
                                spacing: 6 * Theme.scale(screen)
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
                                spacing: 6 * Theme.scale(screen)
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
                                spacing: 6 * Theme.scale(screen)
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
                                spacing: 6 * Theme.scale(screen)
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
                                spacing: 6 * Theme.scale(screen)
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
                            // Path hidden by request
                            // Row removed

                            // Container hidden by request
                            // Row removed

                            // Size intentionally hidden per request

                            // Date (if available)
                            RowLayout {
                                visible: !!MusicManager.trackDateStr
                                Layout.fillWidth: true
                                spacing: 6 * Theme.scale(screen)
                                Text {
                                    // Date icon
                                    text: "calendar_month"
                                    font.family: "Material Symbols Outlined"
                                    color: "#004E4E"
                                    font.pixelSize: Math.round(playerUI.musicFontPx * 1.15)
                                    font.weight: Font.Bold
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

                            // Encoder row removed by request

                            // ReplayGain (if available)
                            RowLayout {
                                visible: !!MusicManager.trackRgTrackStr
                                Layout.fillWidth: true
                                spacing: 6 * Theme.scale(screen)
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
                                spacing: 6 * Theme.scale(screen)
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

            // (Progress bar and media controls removed as requested)
        }
    }

}
