import "../../Helpers/Holidays.js" as Holidays
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// Quickshell and Wayland imports not needed here
import qs.Components
import qs.Settings

PanelWithOverlay {
    id: calendarOverlay
    // Disable dim overlay on activation
    showOverlay: false

    Rectangle {
        color: Theme.backgroundPrimary
        radius: Theme.cornerRadiusLarge
        border.color: Theme.backgroundTertiary
        border.width: Theme.calendarBorderWidth
        width: Theme.calendarWidth
        height: Theme.calendarHeight
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: Theme.calendarPopupMargin
        anchors.rightMargin: Theme.calendarPopupMargin

        // Prevent closing when clicking in the panel bg
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.calendarSideMargin
            spacing: Theme.calendarRowSpacing

            // Month/Year header with navigation
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.calendarCellSpacing

                IconButton {
                    icon: "chevron_left"
                    accentColor: Theme.accentPrimary
                    iconNormalColor: Theme.textPrimary
                    iconHoverColor: Theme.onAccent
                    onClicked: {
                        let newDate = new Date(calendar.year, calendar.month - 1, 1);
                        calendar.year = newDate.getFullYear();
                        calendar.month = newDate.getMonth();
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: calendar.title
                    color: Theme.textPrimary
                    opacity: 0.7
                    font.pixelSize: 18 * Theme.scale(screen)
                    font.family: Theme.fontFamily
                    font.weight: Font.Medium
                }

                IconButton {
                    icon: "chevron_right"
                    accentColor: Theme.accentPrimary
                    iconNormalColor: Theme.textPrimary
                    iconHoverColor: Theme.onAccent
                    onClicked: {
                        let newDate = new Date(calendar.year, calendar.month + 1, 1);
                        calendar.year = newDate.getFullYear();
                        calendar.month = newDate.getMonth();
                    }
                }

            }

            DayOfWeekRow {
                Layout.fillWidth: true
                spacing: 0
                Layout.leftMargin: 0 // Align tighter with grid
                Layout.rightMargin: 0

                delegate: Text {
                    text: shortName
                    color: Theme.textPrimary
                    opacity: 0.8
                    font.pixelSize: 18 * Theme.scale(screen)
                    font.family: Theme.fontFamily
                    font.weight: Font.Normal
                    horizontalAlignment: Text.AlignHCenter
                    width: Theme.calendarCellSize
                }

            }

            MonthGrid {
                id: calendar

                property var holidays: []

                // Fetch holidays when calendar is opened or month/year changes
                function updateHolidays() {
                    Holidays.getHolidaysForMonth(calendar.year, calendar.month, function(holidays) {
                        calendar.holidays = holidays;
                    }, null, { userAgent: Settings.settings.userAgent, debug: Settings.settings.debugNetwork });
                }

                Layout.fillWidth: true
                Layout.leftMargin: Theme.calendarSideMargin
                Layout.rightMargin: Theme.calendarSideMargin
                spacing: 0
                month: Time.date.getMonth()
                year: Time.date.getFullYear()
                onMonthChanged: updateHolidays()
                onYearChanged: updateHolidays()
                Component.onCompleted: updateHolidays()

                // Optionally, update when the panel becomes visible
                Connections {
                    function onVisibleChanged() {
                        if (calendarOverlay.visible) {
                            calendar.month = Time.date.getMonth();
                            calendar.year = Time.date.getFullYear();
                            calendar.updateHolidays();
                        }
                    }

                    target: calendarOverlay
                }

                delegate: Rectangle {
                    property var holidayInfo: calendar.holidays.filter(function(h) {
                        var d = new Date(h.date);
                        return d.getDate() === model.day && d.getMonth() === model.month && d.getFullYear() === model.year;
                    })
                    property bool isHoliday: holidayInfo.length > 0

                    width: Theme.calendarCellSize
                    height: Theme.calendarCellSize
                radius: Theme.cornerRadius
                    // Background coloring: today uses full accent; hover uses dimmed accent (30% less brightness)
                    property color _hoverColor: Qt.rgba(
                        Theme.accentPrimary.r * 0.7,
                        Theme.accentPrimary.g * 0.7,
                        Theme.accentPrimary.b * 0.7,
                        Theme.accentPrimary.a
                    )
                    color: model.today ? Theme.accentPrimary : (mouseArea2.containsMouse ? _hoverColor : "transparent")

                    // Holiday dot indicator
                    Rectangle {
                        visible: isHoliday
                        width: Theme.calendarHolidayDotSize
                        height: Theme.calendarHolidayDotSize
                        radius: Theme.cornerRadiusSmall
                        color: Theme.accentTertiary
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: Theme.calendarPopupMargin
                        anchors.rightMargin: Theme.calendarPopupMargin
                        z: 2
                    }

                    Text {
                        anchors.centerIn: parent
                        text: model.day
                        color: model.today ? Theme.onAccent : Theme.textPrimary
                        opacity: model.month === calendar.month ? (mouseArea2.containsMouse ? 1 : 0.7) : 0.3
                        font.pixelSize: 24 * Theme.scale(screen)
                        font.family: Theme.fontFamily
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: mouseArea2

                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            if (isHoliday) {
                                holidayTooltip.text = holidayInfo.map(function(h) {
                                    return h.localName + (h.name !== h.localName ? " (" + h.name + ")" : "") + (h.global ? " [Global]" : "");
                                }).join(", ");
                                holidayTooltip.targetItem = parent;
                                holidayTooltip.tooltipVisible = true;
                            }
                        }
                        onExited: holidayTooltip.tooltipVisible = false
                    }

                    StyledTooltip {
                        id: holidayTooltip

                        text: ""
                        tooltipVisible: false
                        targetItem: null
                        delay: Theme.tooltipDelayMs
                    }

                    // Remove hover color animation for instant response

                }

            }

        }

    }

}
