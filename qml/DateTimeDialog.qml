import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

import TaskList

Popup {
    id: root

    property bool hasDate: false
    property bool hasTime: false
    property string dateString: ""
    property string timeString: ""
    readonly property string selectedDate: dateString + "T" + timeString

    signal accepted()

    parent: Overlay.overlay

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    implicitWidth: parent.width > parent.height ? parent.width * 0.70 : parent.width * 0.94
    implicitHeight: dateTimeColumn.implicitHeight

    padding: 0
    modal: true
    dim: true
    focus: true

    onAboutToShow: {
        if (root.dateString) {
            var dateTime = new Date(root.selectedDate)
            datePicker.selectedDate = dateTime
            if (root.hasTime)
                timePicker.item.setTime(dateTime.getHours(), dateTime.getMinutes())
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: dateTimePane.implicitHeight
        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.DragOverBounds

        Pane {
            id: dateTimePane

            anchors.fill: parent
            padding: 0

            ColumnLayout {
                id: dateTimeColumn

                width: parent.width
                spacing: 0

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.rightMargin: 30

                        UI.ButtonFlat {
                            text: root.hasTime && root.timeString ? root.timeString : qsTr("No time")
                            onClicked: timePicker.item.open()
                        }

                        UI.ButtonFlat {
                            enabled: root.hasTime && root.timeString
                            text: qsTr("Cancel time")
                            onClicked: root.hasTime = false
                        }
                    }

                    ColumnLayout {
                        Layout.leftMargin: 30

                        UI.ButtonFlat {
                            text: root.hasDate && root.dateString ? root.dateString : qsTr("No date")
                        }

                        UI.ButtonFlat {
                            enabled: root.hasDate && root.dateString
                            text: qsTr("Cancel date")
                            onClicked: root.hasTime = root.hasDate = false
                        }
                    }
                }

                UI.DatePicker {
                    id: datePicker
                    locale: Settings.country
                    onDateStringChanged: {
                        root.hasDate = true
                        root.dateString = datePicker.dateString
                    }
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 10

                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.alignment: Qt.AlignRight

                    UI.ButtonFlat {
                        text: qsTr("Cancel")
                        textColor: UI.Style.primaryColor
                        Layout.minimumWidth: 80
                        onClicked: root.close()
                    }

                    UI.ButtonContained {
                        text: qsTr("OK")
                        Layout.minimumWidth: 80

                        onClicked: {
                            root.dateString = datePicker.dateString
                            root.timeString = timePicker.item.timeString
                            root.close()
                            root.accepted()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: timePickerCircular
        UI.TimePickerCircular {
            time24h: !Settings.timeAMPM
            onAccepted: {
                root.dateString = datePicker.dateString
                root.timeString = timeString
                root.hasDate = true
                root.hasTime = true
            }
        }
    }

    Component {
        id: timePickerTumbler
        UI.TimePickerTumbler {
            timeAMPM: Settings.timeAMPM
            onAccepted: {
                root.dateString = datePicker.dateString
                root.timeString = timeString
                root.hasDate = true
                root.hasTime = true
            }
        }
    }

    Loader {
        id: timePicker
        sourceComponent: Settings.timeTumbler ? timePickerTumbler : timePickerCircular
    }
}
