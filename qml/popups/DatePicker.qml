import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Qt.labs.calendar 1.0
import QtQuick.Controls.Material 2.3
import "../ekke/common"
import "../common"

Popup {
    id: datePickerRoot

    property date selectedDate: new Date()
    property int displayMonth: selectedDate.getMonth()
    property int displayYear: selectedDate.getFullYear()
    property int calendarWidth: isLandscape ? appWindow.width * 0.70 : appWindow.width * 0.94
    property int calendarHeight: isLandscape ? appWindow.height * 0.94 : appWindow.height * 0.9
    property bool isOK: false
    property bool clear: false

    x: (parent.width - calendarWidth) / 2
    y: ((parent.height - calendarHeight) / 2) - 24
    implicitWidth: calendarWidth
    implicitHeight: calendarHeight
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    modal: true
    padding: 0

    ColumnLayout {
        id: calendarColumn

        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: primaryColor
            RowLayout {
                anchors.fill: parent
                spacing: 6
                Item {
                    Layout.leftMargin: 10
                }
                ButtonFlat {
                    leftPadding: 12
                    rightPadding: 12
                    text: "<"
                    textColor: textOnPrimary
                    font.pointSize: fontSizeTitle
                    onClicked: {
                        if (datePickerRoot.displayMonth > 0) {
                            datePickerRoot.displayMonth--
                        } else {
                            datePickerRoot.displayMonth = 11
                            datePickerRoot.displayYear--
                        }
                    }
                }
//                RowLayout {
//                    spacing: 0
//                    Layout.fillWidth: true
//                    LabelTitle {
//                        text: locale.monthName(monthGrid.month)
//                        elide: Text.ElideRight
//                        color: textOnPrimary
//                        horizontalAlignment: Qt.AlignHCenter
//                        Layout.fillWidth: true
//                    }
                    LabelTitle {
                        text: currentLocale.monthName(monthGrid.month) + " " + monthGrid.year
                        elide: Text.ElideRight
                        color: textOnPrimary
                        horizontalAlignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                    }
//                }
                ButtonFlat {
                    leftPadding: 12
                    rightPadding: 12
                    text: ">"
                    font.pointSize: fontSizeTitle
                    textColor: textOnPrimary
                    onClicked: {
                        if (datePickerRoot.displayMonth < 11) {
                            datePickerRoot.displayMonth++
                        } else {
                            datePickerRoot.displayMonth = 0
                            datePickerRoot.displayYear++
                        }
                    }
                }
                Item {
                    Layout.rightMargin: 10
                }
            }
        }

        DayOfWeekRow {
            id: dayOfWeekRow
            leftPadding: 24
            rightPadding: 24
            Layout.fillWidth: true
            font.bold: false
            locale: currentLocale
            delegate: LabelBodySecondary {
                text: model.shortName
                font: dayOfWeekRow.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        MonthGrid {
            id: monthGrid

            Layout.fillWidth: true
            rightPadding: 24
            leftPadding: 24

            month: datePickerRoot.displayMonth
            year: datePickerRoot.displayYear

            onClicked: {
                // Important: check the month to avoid clicking on days outside where opacity 0
                if (date.getMonth() === datePickerRoot.displayMonth) {
                    datePickerRoot.selectedDate = date
                    console.log("tapped on a date ")
                } else {
                    console.log("outside valid month " + date.getMonth())
                }
            }
            locale: currentLocale

            delegate: Label {
                id: dayLabel
                readonly property bool selected: model.day === datePickerRoot.selectedDate.getDate()
                                                 && model.month === datePickerRoot.selectedDate.getMonth()
                                                 && model.year === datePickerRoot.selectedDate.getFullYear()
                text: model.day
                font.bold: model.today ? true : false
                font.pixelSize: fontSizeTitle
                opacity: model.month === monthGrid.month ? 1 : 0.3
                color: selected ? textOnPrimary : model.today ? accentColor : Material.foreground
                minimumPointSize: 8
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                background: Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 2
                    height: parent.height + 2
                    radius: width / 2
//                    border.width: 1
//                    border.color: "darkgray"
                    color: parent.selected ? primaryColor : "transparent"
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            ButtonFlat {
                text: qsTr("Clear")
                textColor: accentColor
                onClicked: {
                    datePickerRoot.selectedDate = new Date()
                    datePickerRoot.displayMonth = datePickerRoot.selectedDate.getMonth()
                    datePickerRoot.displayYear = datePickerRoot.selectedDate.getFullYear()
                    datePickerRoot.clear = true
                    datePickerRoot.close()
                }
                Layout.minimumWidth: 80
            }
            ButtonFlat {
                text: qsTr("Cancel")
                textColor: primaryColor
                onClicked: {
                    datePickerRoot.close()
                }
                Layout.minimumWidth: 80
            }
            ButtonFlat {
                text: qsTr("OK")
                textColor: primaryColor
                onClicked: {
                    datePickerRoot.isOK = true
                    datePickerRoot.close()
                }
                Layout.minimumWidth: 80
            }
        }
    }
    onOpened: {
        datePickerRoot.isOK = false
        datePickerRoot.clear = false
    }
}
