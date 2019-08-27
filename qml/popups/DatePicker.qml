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

    property string hrsDisplay: selectedDate.getHours()
    property string minutesDisplay: selectedDate.getMinutes()

    x: (parent.width - width) / 2
    y: ((parent.height - height) / 2) - 24
    implicitWidth: calendarWidth
    implicitHeight: Math.min(calendarColumn.implicitHeight, calendarHeight)

    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    modal: true
    padding: 0

    ColumnLayout {
        id: calendarColumn

        anchors.fill: parent
        spacing: 0

        Rectangle {
            height: 90
            Layout.fillWidth: true
//            Layout.fillHeight: true
            color: primaryColor
            TextInput {
                text: (hrsDisplay < 10 ? "0" : "") + hrsDisplay + ":" +
                      (minutesDisplay < 10 ? "0" : "") + minutesDisplay
                font.pointSize: 50
                color: textOnPrimaryDark
                anchors.centerIn: parent
                validator: RegExpValidator { regExp: /^([01]?\d|2[0-3]):([0-5]?\d)$/ }
                inputMask: "00:00"
                inputMethodHints: Qt.ImhTime | Qt.ImhDigitsOnly
                onFocusChanged: {
                    if (focus) {
                        text = "00:00"
                        cursorPosition = 0
                    }
                }
                onTextChanged: {
                    if (acceptableInput) {
                        var date = new Date(datePickerRoot.selectedDate)
                        date.setHours(text.substr(0, 2))
                        date.setMinutes(text.substr(3, 2))
                        datePickerRoot.selectedDate = date
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: monthRow.implicitHeight
            color: primaryDarkColor

            RowLayout {
                id: monthRow
                spacing: 6
                width: parent.width
                ToolButton {
                    leftPadding: 12
                    rightPadding: 12
                    icon.source: "image://icon/arrow_back"
                    icon.color: textOnPrimary
                    onClicked: {
                        if (datePickerRoot.displayMonth > 0) {
                            datePickerRoot.displayMonth--
                        } else {
                            datePickerRoot.displayMonth = 11
                            datePickerRoot.displayYear--
                        }
                    }
                }
                LabelTitle {
                    text: currentLocale.monthName(monthGrid.month) + " " + monthGrid.year
                    elide: Text.ElideRight
                    color: textOnPrimary
                    horizontalAlignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                }
                ToolButton {
                    leftPadding: 12
                    rightPadding: 12
                    icon.source: "image://icon/arrow_forward"
                    icon.color: textOnPrimary
                    onClicked: {
                        if (datePickerRoot.displayMonth < 11) {
                            datePickerRoot.displayMonth++
                        } else {
                            datePickerRoot.displayMonth = 0
                            datePickerRoot.displayYear++
                        }
                    }
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
                    var tmpDate = date
                    tmpDate.setHours(hrsDisplay)
                    tmpDate.setMinutes(minutesDisplay)
                    datePickerRoot.selectedDate = tmpDate
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
                    width: Math.min(parent.height + 2, parent.width + 2)
                    height: Math.min(parent.height + 2, parent.width + 2)
                    radius: width / 2
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
                    datePickerRoot.hrsDisplay = datePickerRoot.selectedDate.getHours()
                    datePickerRoot.minutesDisplay = datePickerRoot.selectedDate.getMinutes()
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
