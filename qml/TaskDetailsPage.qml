import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import BaseUI as UI

import TaskList

UI.AppStackPage {
    id: root

    required property Task task

    property string selectedDueDate: ""
    property bool selectedAllDay: false
    property int selectedReminder: Task.Reminder.Off

    property bool modified: {
        return root.task.name !== nameField.text
            || root.task.notes !== notesField.text
            || root.task.dueDateTime !== root.selectedDueDate
            || root.task.allDay !== root.selectedAllDay
            || root.task.reminder !== root.selectedReminder
    }

    function back() {
        _unfocusFields()
        if (modified)
            popupConfirmDiscardModifications.open()
        else
            pop()
    }

    function formatDate(d) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleDateString(Qt.locale(GlobalSettings.country))
    }

    function formatDateTime(d) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleString(Qt.locale(GlobalSettings.country))
    }

    function _unfocusFields() {
        nameField.focus = false
        notesField.focus = false
    }

    title: qsTr("Task Details")
    padding: 6

    leftButton: Action {
        icon.source: UI.Icons.arrow_back
        onTriggered: root.back()
    }

    rightButtons: [
        Action {
            id: saveAction
            enabled: root.modified
            icon.source: root.modified ? UI.Icons.save : ""
            onTriggered: {
                _unfocusFields()
                if (root.modified) {
                    if (root.task.name !== nameField.text
                        && !AppData.currentList.renameTask(task, nameField.text)) {
                        snackbar.showError(qsTr("Name %1 already exists").arg(nameField.text))
                        return
                    }
                    root.task.notes = notesField.text
                    // XXX:
                    if (!(root.selectedReminder === Task.Reminder.Off
                          && root.task.reminder === Task.Reminder.Off)) {
                        if (root.selectedReminder === Task.Reminder.Off) {
                            System.cancelAlarm(root.task.id)
                            snackbar.showMessage(qsTr("Reminder canceled"))
                        } else if (root.selectedDueDate !== root.task.dueDateTime) {
                            System.setAlarm(root.task.id,
                                            root.task.dateToMillisec(root.selectedDueDate),
                                            root.task.name)
                            snackbar.showMessage(qsTr("Notification set to %1")
                                .arg(formatDateTime(root.selectedDueDate)))
                        }
                    }
                    root.task.dueDateTime = root.selectedDueDate
                    root.task.allDay = root.selectedAllDay
                    root.task.reminder = root.selectedReminder
                    // root.task.completedDateTime = root.completedDateTime
                }
            }
        }
    ]

    Flickable {
        contentHeight: taskPane.implicitHeight
        anchors.fill: parent

        Pane {
            id: taskPane

            anchors.fill: parent
            focusPolicy: Qt.ClickFocus

            ColumnLayout {
                width: parent.width

                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true

                    TextField {
                        id: nameField

                        leftPadding: 10
                        rightPadding: 10
                        anchors.fill: parent
                        placeholderText: qsTr("Name")
                        selectByMouse: true

                        Material.containerStyle: Material.Filled
                    }
                }

                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true

                    TextArea {
                        id: notesField

                        leftPadding: 10
                        rightPadding: 10
                        textFormat: TextEdit.PlainText
                        wrapMode: TextEdit.WordWrap
                        anchors.fill: parent
                        placeholderText: qsTr("Notes")
                        selectByMouse: false

                        Material.containerStyle: Material.Filled
                    }
                }

                UI.HorizontalDivider { }

                UI.LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Due date")
                }

                ItemDelegate {
                    id: dateSelection

                    icon.source: UI.Icons.access_time
                    text: {
                        if (root.selectedDueDate) {
                            if (root.selectedAllDay)
                                formatDate(root.selectedDueDate)
                            else
                                formatDateTime(root.selectedDueDate)
                        } else {
                            qsTr("Set date")
                        }
                    }
                    onClicked: {
                        if (root.selectedDueDate) {
                            var dateTime = root.selectedDueDate.split('T')
                            dateTimeDialog.dateString = dateTime[0]
                            dateTimeDialog.timeString = dateTime[1]
                            dateTimeDialog.hasDate = true
                            dateTimeDialog.hasTime = !root.selectedAllDay
                        } else {
                            dateTimeDialog.dateString = ""
                            dateTimeDialog.timeString = ""
                            dateTimeDialog.hasDate = false
                            dateTimeDialog.hasTime = false
                        }
                        _unfocusFields()
                        dateTimeDialog.open()
                    }
                    Layout.fillWidth: true
                }

                ItemDelegate {
                    enabled: root.selectedDueDate
                    icon.source: root.selectedReminder === Task.Reminder.Off
                                    ? UI.Icons.notifications_off
                                    : UI.Icons.notifications
                    text: {
                        if (root.selectedReminder === Task.Reminder.Off)
                            qsTr("Set reminder")
                        else if (root.task.reminderType === Task.ReminderType.Notification)
                            qsTr("Notification set")
                        else if (root.task.reminderType === Task.ReminderType.Alarm)
                            qsTr("Alarm set")
                    }
                    onClicked: {
                        if (root.selectedReminder === Task.Reminder.Off)
                            root.selectedReminder = Task.Reminder.WhenDue
                        else
                            root.selectedReminder = Task.Reminder.Off
                    }
                    Layout.fillWidth: true
                }

                UI.HorizontalDivider { }

                UI.LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Completed:")
                }

                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true

                    UI.LabelBody {
                        leftPadding: 10
                        rightPadding: 10
                        anchors.fill: parent
                        text: {
                            if (root.task.completedDateTime)
                                formatDateTime(root.task.completedDateTime)
                            else
                                qsTr("Not completed")
                        }
                    }
                }

                UI.LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Created:")
                }

                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true

                    UI.LabelBody {
                        id: createdDateTimeLabel

                        leftPadding: 10
                        rightPadding: 10
                        anchors.fill: parent
                    }
                }
            }
        }
    }

    PopupConfirm {
        id: popupConfirmDiscardModifications
        text: qsTr("Discard unsaved modifications?")
        onAccepted: root.pop()
    }

    DateTimeDialog {
        id: dateTimeDialog
        onAccepted: {
            if (dateTimeDialog.hasDate) {
                root.selectedDueDate = dateTimeDialog.selectedDate
                root.selectedAllDay = !dateTimeDialog.hasTime
            } else {
                root.selectedDueDate = ""
                root.selectedAllDay = false
                root.selectedReminder = Task.Reminder.Off
            }
        }
    }

    Snackbar {
        id: snackbar
    }

    Component.onCompleted: {
        nameField.text = root.task.name
        notesField.text = root.task.notes
        createdDateTimeLabel.text = formatDateTime(root.task.createdDateTime)
        root.selectedDueDate = root.task.dueDateTime
        root.selectedAllDay = root.task.allDay
        root.selectedReminder = root.task.reminder
    }
}
