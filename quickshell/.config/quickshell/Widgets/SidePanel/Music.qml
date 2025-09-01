import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs.Settings
import qs.Components
import qs.Services

Rectangle {
    id: musicCard
    color: "transparent"

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
        color: Qt.rgba(
            baseR * desat + lum * (1 - desat),
            baseG * desat + lum * (1 - desat),
            baseB * desat + lum * (1 - desat),
            cardAlpha
        )
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
                    font.pixelSize: playerUI.musicFontPx
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Main player UI
        ColumnLayout {
            id: playerUI
            anchors.fill: parent
            anchors.margins: 18 * Theme.scale(screen)
            spacing: 4 * Theme.scale(screen)
            visible: !!MusicManager.currentPlayer

            // Unified typography for music widget
            property int musicFontPx: Math.round(13 * Theme.scale(screen))
            property color musicTextColor: Theme.textPrimary
            property int musicFontWeight: Font.Medium

            // Player selector
            // Build a de-duplicated list of players by identity/id
            property var uniquePlayers: []
            readonly property bool showCombo: uniquePlayers && uniquePlayers.length > 1
            readonly property bool showSingleLabel: uniquePlayers && uniquePlayers.length === 1
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
                model: uniquePlayers
                textRole: "identity"
                currentIndex: 0
                onActivated: (index) => {
                    try {
                        if (uniquePlayers && uniquePlayers[index]) {
                            MusicManager.selectedPlayerIndex = uniquePlayers[index].idx;
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
                    font.pixelSize: playerUI.musicFontPx
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
                        font.pixelSize: playerUI.musicFontPx
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
                Layout.preferredHeight: visible ? 40 * Theme.scale(screen) : 0
                height: visible ? implicitHeight : 0
                text: playerUI.showSingleLabel ? playerUI.uniquePlayers[0].identity : ""
                color: playerUI.musicTextColor
                font.family: Theme.fontFamily
                font.pixelSize: playerUI.musicFontPx
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
                    // Container sized to the outline, so centering keeps left edge flush
                    width: albumArtwork.width + 4 * Theme.scale(screen)
                    height: albumArtwork.height + 4 * Theme.scale(screen)
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    // (Visualizer removed for this view as per request)

                    // Album art image (square with slight rounding)
                    Rectangle {
                        id: albumArtwork
                        // Cover at 200px (scaled)
                        width: 200 * Theme.scale(screen)
                        height: 200 * Theme.scale(screen)
                        anchors.centerIn: parent
                        radius: 8 * Theme.scale(screen)
                        color: Qt.darker(Theme.surface, 1.1)
                        border.color: Qt.rgba(Theme.accentPrimary.r, Theme.accentPrimary.g, Theme.accentPrimary.b, 0.3)
                        border.width: 1 * Theme.scale(screen)

                        Image {
                            id: albumArt
                            anchors.fill: parent
                            anchors.margins: 2 * Theme.scale(screen)
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
                    // Accent glow/shadow for better separation without explicit outline
                    MultiEffect {
                        id: coverGlow
                        anchors.fill: albumArtwork
                        source: ShaderEffectSource {
                            sourceItem: albumArtwork
                            // Keep original cover visible; draw glow above it
                            hideSource: false
                            recursive: true
                            live: true
                            smooth: true
                        }
                        shadowEnabled: true
                        shadowColor: Qt.rgba(Theme.accentPrimary.r, Theme.accentPrimary.g, Theme.accentPrimary.b, 0.65)
                        shadowBlur: 0.8
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0
                        z: 0.4
                    }
                }

                // Track metadata
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2 * Theme.scale(screen)

                    Text {
                        text: MusicManager.trackTitle
                        color: playerUI.musicTextColor
                        font.family: Theme.fontFamily
                        font.pixelSize: playerUI.musicFontPx
                        font.weight: playerUI.musicFontWeight
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        Layout.fillWidth: true
                    }

                    Text {
                        text: MusicManager.trackArtist
                        color: playerUI.musicTextColor
                        font.family: Theme.fontFamily
                        font.pixelSize: playerUI.musicFontPx
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: MusicManager.trackAlbum
                        color: playerUI.musicTextColor
                        font.family: Theme.fontFamily
                        font.pixelSize: playerUI.musicFontPx
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            // (Progress bar and media controls removed as requested)
        }
    }
}
