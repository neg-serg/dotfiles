import "../../Helpers/Holidays.js" as Holidays
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
 
import qs.Components
import qs.Settings
import "../../Helpers/Color.js" as Color

PanelWithOverlay {
    id: calendarOverlay
    
    showOverlay: false

    Rectangle {
        color: Theme.background
        radius: Math.round(Theme.cornerRadiusLarge / 3)
        border.color: Theme.borderSubtle
        border.width: Theme.calendarBorderWidth
        width: Theme.calendarWidth
        height: Theme.calendarHeight
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: Theme.calendarPopupMargin
        anchors.rightMargin: Theme.calendarPopupMargin

        
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.calendarSideMargin
            spacing: Theme.calendarRowSpacing

            // Header with navigation
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
                    opacity: Theme.calendarTitleOpacity
                    font.pixelSize: Math.round(Theme.calendarTitleFontPx * Theme.scale(screen))
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
                spacing: Theme.calendarDowSpacing
                Layout.leftMargin: Theme.calendarDowSideMargin
                Layout.rightMargin: Theme.calendarDowSideMargin

                delegate: Text {
                    text: shortName
                    color: Theme.textSecondary
                    opacity: Theme.calendarDowOpacity
                    font.pixelSize: Math.round(Theme.calendarDowFontPx * Theme.scale(screen))
                    font.family: Theme.fontFamily
                    font.weight: Font.Normal
                    font.underline: Theme.calendarDowUnderline
                    font.italic: Theme.calendarDowItalic
                    horizontalAlignment: Text.AlignHCenter
                    width: Theme.calendarCellSize
                }

            }

            MonthGrid {
                id: calendar

                property var holidays: []
                // Selected date
                property int selectedYear: -1
                property int selectedMonth: -1
                property int selectedDay: -1

                // Fetch holidays on open and on month/year changes
                function updateHolidays() {
                    Holidays.getHolidaysForMonth(calendar.year, calendar.month, function(holidays) {
                        calendar.holidays = holidays;
                    }, null, { userAgent: Settings.settings.userAgent, debug: Settings.settings.debugNetwork });
                }

                Layout.fillWidth: true
                Layout.leftMargin: Theme.calendarSideMargin
                Layout.rightMargin: Theme.calendarSideMargin
                spacing: Theme.calendarGridSpacing
                month: Time.date.getMonth()
                year: Time.date.getFullYear()
                onMonthChanged: updateHolidays()
                onYearChanged: updateHolidays()
                Component.onCompleted: updateHolidays()

                // Update when panel visibility changes
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
                    property bool isSelected: model.year === calendar.selectedYear && model.month === calendar.selectedMonth && model.day === calendar.selectedDay
                    property var holidayInfo: calendar.holidays.filter(function(h) {
                        var d = new Date(h.date);
                        return d.getDate() === model.day && d.getMonth() === model.month && d.getFullYear() === model.year;
                    })
                    property bool isHoliday: holidayInfo.length > 0

                    width: Theme.calendarCellSize
                    height: Theme.calendarCellSize
                radius: Math.round(Theme.cornerRadius * Theme.calendarCellRadiusFactor)
                    // Today/selected/hover use explicit darkened accent (tunable factor)
                    color: (model.today || isSelected || mouseArea2.containsMouse)
                        ? Color.towardsBlack(Theme.accentPrimary, Theme.calendarAccentDarken)
                        : "transparent"
                    // Accent border on today/hover/selected
                    border.color: (model.today || isSelected || mouseArea2.containsMouse) ? Theme.accentPrimary : "transparent"
                    border.width: (model.today || isSelected || mouseArea2.containsMouse) ? 1 : 0

                    // Holiday dot indicator
                    Rectangle {
                        visible: isHoliday
                        width: Theme.calendarHolidayDotSize
                        height: Theme.calendarHolidayDotSize
                        radius: Math.round(Theme.calendarHolidayDotSize * Theme.calendarHolidayDotRadiusFactor)
                        color: Theme.accentPrimary
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: Theme.calendarPopupMargin
                        anchors.rightMargin: Theme.calendarPopupMargin
                        z: 2
                    }

                    // Contrast guard for highlighted cells
                    ContrastGuard { id: dayCg; bg: parent.color; label: 'CalendarDay' }

                    Text {
                        anchors.centerIn: parent
                        text: model.day
                        // Ensure readable text on highlight
                        color: (model.today || isSelected || mouseArea2.containsMouse) ? dayCg.fg : Theme.textPrimary
                        opacity: model.month === calendar.month ? (mouseArea2.containsMouse ? 1 : Theme.calendarTitleOpacity) : Theme.calendarOtherMonthDayOpacity
                        font.pixelSize: Math.round(Theme.calendarDayFontPx * Theme.scale(screen))
                        font.family: Theme.fontFamily
                        font.weight: Font.Bold
                        font.underline: model.today
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
                            // ContrastGuard handles optional warnings when debugContrast is set
                        }
                        onExited: holidayTooltip.tooltipVisible = false
                        onClicked: {
                            calendar.selectedYear = model.year;
                            calendar.selectedMonth = model.month;
                            calendar.selectedDay = model.day;
                        }
                    }

                    StyledTooltip {
                        id: holidayTooltip

                        text: ""
                        tooltipVisible: false
                        targetItem: null
                        delay: Theme.tooltipDelayMs
                    }

                    

                }

            }

        }

    }

}
