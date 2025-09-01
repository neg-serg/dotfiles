import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Components
import qs.Settings

PanelWithOverlay {
    id: sidebarPopup
    // Give the side panel a namespace so Hyprland can apply blur rules
    WlrLayershell.namespace: "quickshell-sidepanel"
    property var shell: null
    function showAt() { sidebarPopupRect.showAt(); }
    function hidePopup() { sidebarPopupRect.hidePopup(); }
    function show() { sidebarPopupRect.showAt(); }
    function dismiss() { sidebarPopupRect.hidePopup(); }
    Component.onCompleted: { // Trigger initial weather loading when component is completed
        // Load initial weather data after a short delay to ensure all components are ready
        Qt.callLater(function() { if (weather && weather.fetchCityWeather) weather.fetchCityWeather(); });
    }

        Rectangle {
            // Access the shell's SettingsWindow instead of creating a new one
            id: sidebarPopupRect
        property real slideOffset: width
        property bool isAnimating: false
        property int leftPadding: 20 * Theme.scale(screen)
        property int bottomPadding: 20 * Theme.scale(screen)
        function showAt() {
            if (!sidebarPopup.visible) {
                sidebarPopup.visible = true;
                forceActiveFocus();
                slideAnim.from = width;
                slideAnim.to = 0;
                slideAnim.running = true;
                if (weather)
                    weather.startWeatherFetch();
            }
        }

        function hidePopup() {
            if (sidebarPopup.visible) {
                slideAnim.from = 0;
                slideAnim.to = width;
                slideAnim.running = true;
            }
        }

        // Make popup size follow content to reduce empty space
        // Fallback to legacy sizes if content is not yet available
        width: Math.round((contentCol ? (contentCol.implicitWidth + leftPadding) : (480 * Theme.scale(screen))))
        height: Math.round((contentCol ? (contentCol.implicitHeight + bottomPadding) : (660 * Theme.scale(screen))))
        visible: parent.visible
        color: "transparent"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        MouseArea { anchors.fill: parent; } // Prevent closing when clicking in the panel bg
        NumberAnimation {
            id: slideAnim
            target: sidebarPopupRect
            property: "slideOffset"
            duration: 300
            easing.type: Easing.OutCubic
            onStopped: {
                if (sidebarPopupRect.slideOffset === sidebarPopupRect.width) {
                    sidebarPopup.visible = false;
                    if (weather) weather.stopWeatherFetch();
                }
                sidebarPopupRect.isAnimating = false;
            }
            onStarted: {
                sidebarPopupRect.isAnimating = true;
            }
        }

        Rectangle {
            id: mainRectangle
            // anchors.top: sidebarPopupRect.top
            width: sidebarPopupRect.width - sidebarPopupRect.leftPadding
            height: sidebarPopupRect.height - sidebarPopupRect.bottomPadding
            x: sidebarPopupRect.leftPadding + sidebarPopupRect.slideOffset
            y: 0
            // Panel backdrop: very transparent black
            color: Qt.rgba(0, 0, 0, 0.10)
            bottomLeftRadius: 20
            Behavior on x {
                enabled: !sidebarPopupRect.isAnimating
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }

            }

        }

        // Content layer
        Item {
            anchors.fill: mainRectangle
            z: 1
            x: sidebarPopupRect.slideOffset
            Keys.onEscapePressed: sidebarPopupRect.hidePopup()
            ColumnLayout {
                id: contentCol
                anchors.fill: parent
                spacing: 8 * Theme.scale(screen)
                Weather {
                    id: weather
                    width: 420 * Theme.scale(screen)
                    height: 180 * Theme.scale(screen)
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout { // Music and System Monitor row
                    spacing: 8 * Theme.scale(screen)
                    Layout.fillWidth: true
                    // Stretch music module to panel edges
                    Music {
                        Layout.fillWidth: true
                        height: 250 * Theme.scale(screen)
                    }
                }

                RowLayout {
                    spacing: 8 * Theme.scale(screen)
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    height: 8 * Theme.scale(screen)
                    color: "transparent"
                }

            }

            Behavior on x {
                enabled: !sidebarPopupRect.isAnimating
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
        }

    }
}
