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

    function formattedDate() {
        var f = Date.fromLocaleString(Qt.locale(), root.dateString, "yyyy-MM-dd")
        return f.toLocaleDateString(Qt.locale(GlobalSettings.country), Locale.ShortFormat)
    }

    function formattedTime() {
        var f = Date.fromLocaleString(Qt.locale(), root.timeString, "HH:mm:ss")
        return f.toLocaleTimeString(Qt.locale(GlobalSettings.country), Locale.ShortFormat)
    }

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

                GridLayout {
                    columns: 2

                    Layout.alignment: Qt.AlignHCenter

                    ToolButton {
                        icon.source: UI.Icons.date_range
                        text: root.hasDate && root.dateString ? formattedDate() : qsTr("No date")
                    }

                    ToolButton {
                        icon.source: UI.Icons.access_time
                        text: root.hasTime && root.timeString ? formattedTime() : qsTr("Select time")
                        onClicked: timePicker.item.open()
                    }

                    ToolButton {
                        enabled: root.hasDate && root.dateString
                        icon.source: UI.Icons.not_interested
                        text: qsTr("Cancel date")
                        onClicked: root.hasTime = root.hasDate = false
                    }

                    ToolButton {
                        enabled: root.hasTime && root.timeString
                        icon.source: UI.Icons.not_interested
                        text: qsTr("Cancel time")
                        onClicked: root.hasTime = false
                    }
                }

                UI.DatePicker {
                    id: datePicker
                    locale: GlobalSettings.country
                    selected: root.hasDate
                    onTappedOnADate: {
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
            time24h: !GlobalSettings.timeAMPM
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
            timeAMPM: GlobalSettings.timeAMPM
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
        sourceComponent: GlobalSettings.timeTumbler ? timePickerTumbler : timePickerCircular
    }
}
