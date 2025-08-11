import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Components
import qs.Settings

PanelWithOverlay {
    id: sidebarPopup

    property var shell: null

    function showAt() {
        sidebarPopupRect.showAt();
    }

    function hidePopup() {
        sidebarPopupRect.hidePopup();
    }

    function show() {
        sidebarPopupRect.showAt();
    }

    function dismiss() {
        sidebarPopupRect.hidePopup();
    }

    // Trigger initial weather loading when component is completed
    Component.onCompleted: {
        // Load initial weather data after a short delay to ensure all components are ready
        Qt.callLater(function() {
            if (weather && weather.fetchCityWeather)
                weather.fetchCityWeather();

        });
    }

    Rectangle {
        // Access the shell's SettingsWindow instead of creating a new one
        id: sidebarPopupRect
        property real slideOffset: width
        property bool isAnimating: false
        property int leftPadding: 20 * Theme.scale(screen)
        property int bottomPadding: 20 * Theme.scale(screen)
        // Recording properties
        property bool isRecording: false
        function checkRecordingStatus() {
            if (isRecording)
                checkRecordingProcess.running = true;

        }

        function showAt() {
            if (!sidebarPopup.visible) {
                sidebarPopup.visible = true;
                forceActiveFocus();
                slideAnim.from = width;
                slideAnim.to = 0;
                slideAnim.running = true;
                if (weather)
                    weather.startWeatherFetch();

                if (systemWidget)
                    systemWidget.panelVisible = true;

            }
        }

        function hidePopup() {
            if (sidebarPopup.visible) {
                slideAnim.from = 0;
                slideAnim.to = width;
                slideAnim.running = true;
            }
        }

        width: 480 * Theme.scale(screen)
        height: 660 * Theme.scale(screen)
        visible: parent.visible
        color: "transparent"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        // Clean up processes on destruction
        Component.onDestruction: {
            if (isRecording)
                stopRecording();

        }

        Process {
            id: checkRecordingProcess

            command: ["pgrep", "-f", "gpu-screen-recorder.*portal"]
            onExited: function(exitCode, exitStatus) {
                var isActuallyRecording = exitCode === 0;
                if (isRecording && !isActuallyRecording)
                    isRecording = isActuallyRecording;

            }
        }

        // Prevent closing when clicking in the panel bg
        MouseArea {
            anchors.fill: parent
        }

        NumberAnimation {
            id: slideAnim

            target: sidebarPopupRect
            property: "slideOffset"
            duration: 300
            easing.type: Easing.OutCubic
            onStopped: {
                if (sidebarPopupRect.slideOffset === sidebarPopupRect.width) {
                    sidebarPopup.visible = false;
                    if (weather)
                        weather.stopWeatherFetch();

                    if (systemWidget)
                        systemWidget.panelVisible = false;

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
            color: Theme.backgroundPrimary
            bottomLeftRadius: 20

            Behavior on x {
                enabled: !sidebarPopupRect.isAnimating

                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }

            }

        }

        Item {
            anchors.fill: mainRectangle
            x: sidebarPopupRect.slideOffset
            Keys.onEscapePressed: sidebarPopupRect.hidePopup()

            ColumnLayout {
                anchors.fill: parent
                spacing: 8 * Theme.scale(screen)

                System {
                    id: systemWidget

                    width: 420 * Theme.scale(screen)
                    height: 80 * Theme.scale(screen)
                    settingsModal: settingsModal
                    Layout.alignment: Qt.AlignHCenter
                }

                Weather {
                    id: weather

                    width: 420 * Theme.scale(screen)
                    height: 180 * Theme.scale(screen)
                    Layout.alignment: Qt.AlignHCenter
                }

                // Music and System Monitor row
                RowLayout {
                    spacing: 8 * Theme.scale(screen)
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter

                    Music {
                        width: 332 * Theme.scale(screen)
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
