import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtQml 2.12
import Task 1.0
import "../common"
import "../popups"

import AppData 1.0

AppStackPage {
    property var task

    title: qsTr("Task Details")
    padding: 6

    Connections {
        target: AppData
        onSpeechRecognized: nameField.text = result
    }

    Flickable {
        contentHeight: taskPane.implicitHeight
        anchors.fill: parent

        Pane {
            id: taskPane

            anchors.fill: parent

            ColumnLayout {
                width: parent.width

                LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Name:")
                }
                RowLayout {
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
                            placeholderText: qsTr("Modify task name")
                            selectByMouse: true
                            inputMethodHints: Qt.ImhNoPredictiveText
                            text: task.name
                        }
                    }
                    ToolButton {
                        icon.source: nameField.displayText.length > 0
                                     && nameField.displayText !== task.name ?
                                         "image://icon/check" :
                                         "image://icon/mic"
                        icon.color: Material.foreground
                        focusPolicy: Qt.NoFocus
                        onClicked: {
                            nameField.focus = false
                            if (nameField.displayText.length > 0
                                    && nameField.displayText !== task.name) {
                                Qt.inputMethod.commit()
                                var tmp = task.name
                                if (AppData.currentList.modifyTask(task, nameField.text)) {
                                    showToast(qsTr("%1 modified to %2").arg(tmp).arg(task.name))
                                    console.log(tmp + " modified to " + task.name)
                                } else {
                                    showError(qsTr("Task %1 exists").arg(nameField.text))
                                }
                            } else {
                                AppData.startSpeechRecognizer();
                            }
                        }
                    }
                }

                LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Notes:")
                }
                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true
                    TextArea {
                        id: notesField
//                        height: 100
                        leftPadding: 10
                        rightPadding: 10
                        textFormat: TextEdit.PlainText
                        wrapMode: TextEdit.WordWrap
                        anchors.fill: parent
                        selectByMouse: false
                        text: task.notes
                        onEditingFinished: task.notes = text
                    }
                }

                HorizontalDivider { }

                LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Due date")
                }

                RowLayout {
                    Layout.fillWidth: true

                    ItemDelegate {
                        id: dateSelection

                        property string date: dateTimeString(makeDate(task.dueDate, task.dueTime))

                        icon.source: "image://icon/access_time"
                        text: date.length ? date : "Set date"
                        onClicked: {
                            if (date.length)
                                datePicker.selectedDate = makeDate(task.dueDate, task.dueTime)
                            datePicker.open()
                        }
                        Layout.fillWidth: true
                    }

                    Button {
                        icon.source: "image://icon/cancel"
                        background: null
                        visible: dateSelection.date.length > 0
                        onClicked: {
                            task.dueDate = ""
                            task.dueTime = ""
                            if (task.alarm) {
                                task.alarm = Task.NoAlarm
                                AppData.cancelAlarm(task.id)
                            }
                        }
                    }
                }

                ItemDelegate {
                    icon.source: task.alarm === Task.NoAlarm ? "image://icon/notifications_off" : "image://icon/notifications"
                    text: task.alarm ? "Alarm set" : "Set alarm"
                    enabled: task.dueDate.toString() !== "Invalid Date"
                    onClicked: {
                        if (task.alarm) {
                            task.alarm = Task.NoAlarm
                            appWindow.showToast(qsTr("Alarm canceled"))
                            AppData.cancelAlarm(task.id)
                        } else {
                            var datetime = makeDate(task.dueDate, task.dueTime)
                            task.alarm = Task.Notification
                            appWindow.showToast(qsTr("Notification set to %1").arg(dateTimeString(datetime)))
                            AppData.setAlarm(task.id, datetime.getTime(), task.name)
                        }
                    }
                    Layout.fillWidth: true
                }

                HorizontalDivider { }

                LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Completed:")
                }
                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true
                    LabelBody {
                        leftPadding: 10
                        rightPadding: 10
                        anchors.fill: parent
                        text: task.completed.toString() !== "Invalid Date" ?
                                  dateTimeString(task.completed) :
                                  qsTr("Not completed")
                    }
                }

                LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Created:")
                }
                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true
                    LabelBody {
                        leftPadding: 10
                        rightPadding: 10
                        anchors.fill: parent
                        text: dateTimeString(task.created)
                    }
                }
            }
        }
    }

    DatePicker {
        id: datePicker
        onClosed: {
            if (isOK) {
                var datetime = datePicker.selectedDate
                task.dueDate = datetime
                task.dueTime = datetime
                if (task.alarm) {
                    AppData.setAlarm(task.id, datetime.getTime(), task.name)
                }
            }
        }
    }
}
