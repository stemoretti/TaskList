import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import Qt.labs.calendar 1.0
import "../common"

Popup {
    id: root

    property date selectedDate: new Date()
    property int displayMonth: selectedDate.getMonth()
    property int displayYear: selectedDate.getFullYear()
    property int hours: selectedDate.getHours()
    property int minutes: selectedDate.getMinutes()

    property int calendarWidth: isLandscape ? appWindow.width * 0.70 : appWindow.width * 0.94
    property int calendarHeight: isLandscape ? appWindow.height * 0.94 : appWindow.height * 0.9

    property bool isOK: false

    function formatText(count, modelData) {
        var data = count === 12 ? modelData + 1 : modelData;
        return data < 10 ? "0" + data : data;
    }

    x: (parent.width - width) / 2
    y: ((parent.height - height) / 2) - 24
    implicitWidth: calendarWidth
    implicitHeight: Math.min(calendarColumn.implicitHeight, calendarHeight)

    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    modal: true
    padding: 0

    onOpened: root.isOK = false

    ColumnLayout {
        id: calendarColumn

        anchors.fill: parent
        spacing: 0

        StackLayout {
            id: view

            currentIndex: pageIndicator.currentIndex

            ColumnLayout {
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: monthRow.implicitHeight
                    color: Material.primary

                    RowLayout {
                        id: monthRow

                        spacing: 6
                        width: parent.width

                        ToolButton {
                            leftPadding: 12
                            rightPadding: 12
                            icon.source: "image://icon/keyboard_arrow_left"
                            icon.color: textOnPrimary
                            onClicked: {
                                if (root.displayMonth > 0) {
                                    root.displayMonth--
                                } else {
                                    root.displayMonth = 11
                                    root.displayYear--
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
                            icon.source: "image://icon/keyboard_arrow_right"
                            icon.color: textOnPrimary
                            onClicked: {
                                if (root.displayMonth < 11) {
                                    root.displayMonth++
                                } else {
                                    root.displayMonth = 0
                                    root.displayYear++
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

                    rightPadding: 24
                    leftPadding: 24
                    Layout.fillWidth: true

                    month: root.displayMonth
                    year: root.displayYear

                    locale: currentLocale

                    onClicked: {
                        // Important: check the month to avoid clicking on days outside where opacity 0
                        if (date.getMonth() === root.displayMonth) {
                            var tmpDate = date
                            tmpDate.setHours(hours)
                            tmpDate.setMinutes(minutes)
                            root.selectedDate = tmpDate
                            console.log("tapped on a date ")
                        } else {
                            console.log("outside valid month " + date.getMonth())
                        }
                    }

                    delegate: Label {
                        id: dayLabel

                        readonly property bool selected: model.day === root.selectedDate.getDate()
                                                         && model.month === root.selectedDate.getMonth()
                                                         && model.year === root.selectedDate.getFullYear()

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
            }

            Component {
                id: delegateComponent

                Label {
                    text: formatText(Tumbler.tumbler.count, modelData)
                    opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 40
                }
            }

            Item {
                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    spacing: 10

                    Tumbler {
                        id: hoursTumbler
                        model: amPm24Tumbler.currentIndex === 0 ? 24 : 12
                        delegate: delegateComponent
                    }

                    Label {
                        text: ":"
                        font.pixelSize: 40
                    }

                    Tumbler {
                        id: minutesTumbler
                        model: 60
                        delegate: delegateComponent
                    }

                    Label {
                        text: "-"
                        font.pixelSize: 40
                    }

                    Tumbler {
                        id: amPm24Tumbler
                        model: ["24", "AM", "PM"]
                        delegate: delegateComponent
                    }
                }
            }
        }

        RowLayout {
            spacing: 10
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            TabBar {
                id: pageIndicator

                background: null
                Layout.fillWidth: true

                TabButton {
                    text: qsTr("DATE")
                    width: implicitWidth
                }

                TabButton {
                    text: qsTr("TIME")
                    width: implicitWidth
                }
            }

            ButtonFlat {
                text: qsTr("Cancel")
                textColor: primaryColor
                Layout.minimumWidth: 80

                onClicked: {
                    root.close()
                }
            }

            ButtonFlat {
                text: qsTr("OK")
                textColor: primaryColor
                Layout.minimumWidth: 80

                onClicked: {
                    var date = new Date(root.selectedDate)
                    if (amPm24Tumbler.currentIndex === 0) {
                        date.setHours(hoursTumbler.currentIndex)
                    } else {
                        if (amPm24Tumbler.currentIndex === 2) {
                            if (hoursTumbler.currentIndex === 11)
                                date.setHours(12)
                            else
                                date.setHours(hoursTumbler.currentIndex + 13)
                        } else {
                            if (hoursTumbler.currentIndex === 11)
                                date.setHours(0)
                            else
                                date.setHours(hoursTumbler.currentIndex + 1)
                        }
                    }
                    date.setMinutes(minutesTumbler.currentIndex)
                    root.selectedDate = date

                    root.isOK = true
                    root.close()
                }
            }
        }
    }
}
