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
                    color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.6)
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall * Theme.scale(screen)
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Main player UI
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18 * Theme.scale(screen)
            spacing: 12 * Theme.scale(screen)
            visible: !!MusicManager.currentPlayer

            // Player selector
            ComboBox {
                id: playerSelector
                Layout.fillWidth: true
                Layout.preferredHeight: 40 * Theme.scale(screen)
                visible: MusicManager.getAvailablePlayers().length > 1
                model: MusicManager.getAvailablePlayers()
                textRole: "identity"
                currentIndex: MusicManager.selectedPlayerIndex

                background: Rectangle {
                    implicitWidth: 120 * Theme.scale(screen)
                    implicitHeight: 40 * Theme.scale(screen)
                    color: Theme.surfaceVariant
                    border.color: playerSelector.activeFocus ? Theme.accentPrimary : Theme.outline
                    border.width: 1 * Theme.scale(screen)
                    radius: 16 * Theme.scale(Screen)
                }

                contentItem: Text {
                    leftPadding: 12 * Theme.scale(screen)
                    rightPadding: playerSelector.indicator.width + playerSelector.spacing
                    text: playerSelector.displayText
                    font.pixelSize: 13 * Theme.scale(screen)
                    color: Theme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                indicator: Text {
                    x: playerSelector.width - width - 12 * Theme.scale(screen)
                    y: playerSelector.topPadding + (playerSelector.availableHeight - height) / 2
                    text: "arrow_drop_down"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 24 * Theme.scale(screen)
                    color: Theme.textPrimary
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
                        color: Theme.surfaceVariant
                        border.color: Theme.outline
                        border.width: 1 * Theme.scale(screen)
                        radius: 16
                    }
                }

                delegate: ItemDelegate {
                    width: playerSelector.width
                    contentItem: Text {
                        text: modelData.identity
                        font.pixelSize: 13 * Theme.scale(screen)
                        color: Theme.textPrimary
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    highlighted: playerSelector.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? Theme.accentPrimary.toString().replace(/#/, "#1A") : "transparent"
                    }
                }

                onActivated: {
                    MusicManager.selectedPlayerIndex = index;
                    MusicManager.updateCurrentPlayer();
                }
            }

            // Album art with spectrum visualizer
            RowLayout {
                spacing: 12 * Theme.scale(screen)
                Layout.fillWidth: true

                // Album art container with circular spectrum overlay
                Item {
                    id: albumArtContainer
                    width: 96 * Theme.scale(screen)
                    height: 96 * Theme.scale(screen) // enough for spectrum and art (will adjust if needed)
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    // (Visualizer removed for this view as per request)

                    // Album art image (square with slight rounding)
                    Rectangle {
                        id: albumArtwork
                        width: 60 * Theme.scale(screen)
                        height: 60 * Theme.scale(screen)
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
                            sourceSize.width: 60 * Theme.scale(screen)
                            sourceSize.height: 60 * Theme.scale(screen)
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

                    // Sharp square outline 1pt away from cover
                    Rectangle {
                        id: coverOutline
                        anchors.centerIn: parent
                        color: "transparent"
                        radius: 0
                        border.width: 1 * Theme.scale(screen)
                        border.color: Theme.accentPrimary
                        width: albumArtwork.width + 2 * (1 * Theme.scale(screen) + border.width)
                        height: albumArtwork.height + 2 * (1 * Theme.scale(screen) + border.width)
                        z: 0.5
                    }
                }

                // Track metadata
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4 * Theme.scale(screen)

                    Text {
                        text: MusicManager.trackTitle
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall * Theme.scale(screen)
                        font.bold: true
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        Layout.fillWidth: true
                    }

                    Text {
                        text: MusicManager.trackArtist
                        color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.8)
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeCaption * Theme.scale(screen)
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: MusicManager.trackAlbum
                        color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.6)
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeCaption * Theme.scale(screen)
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            // (Progress bar and media controls removed as requested)
        }
    }
}
