import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtQml 2.12
import "../ekke/common"
import "../ekke/popups"
import "../common"
import "../popups"

AppStackPage {
    property var task

    title: qsTr("Task Details")
    padding: 6

    rightButtons: [
        Action {
            icon.source: "image://icon/mic"
            onTriggered: appData.startSpeechRecognizer();
        }
    ]

    Connections {
        target: appData
        onSpeechRecognized: nameField.text = result.replace(/^./, str => str.toUpperCase())
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
                        placeholderText: qsTr("Tap here to insert name")
                        selectByMouse: true
                        text: task.name
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

                LabelTitle {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Due date")
                }

                LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Date:")
                }
                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true
                    Button {
                        id: dateField
                        property string date: dateString(task.dueDate)
                        leftPadding: 10
                        rightPadding: 10
                        text: date.length ? date : qsTr("Enter date")
                        onClicked: {
                            datePicker.open()
                        }
                    }
                }

                LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Time:")
                }
                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true
                    Button {
                        id: timeField
                        enabled: dateString(task.dueDate).length > 0
                        property string time: timeString(task.dueTime)
                        leftPadding: 10
                        rightPadding: 10
                        text: time.length ? time : qsTr("Enter time")
                        onClicked: timePicker.open()
                    }
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

                HorizontalDivider { }

                ButtonRaised {
                    text: qsTr("Modify")
                    onClicked: {
                        if (nameField.text.length > 0) {
                            if (appData.currentList.modifyTask(task, nameField.text)) {
                                showToast(qsTr("%1 modified").arg(task.name))
                                pop()
                                console.log("modified: " + task.name)
                            } else {
                                showError(qsTr("Task %1 exists").arg(nameField.text))
                            }
                        } else {
                            showError(qsTr("The name field is empty"))
                        }
                    }
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
    DatePicker {
        id: datePicker
        onClosed: {
            if (isOK) {
                task.dueDate = datePicker.selectedDate
            } else if (clear) {
                task.dueDate = ""
                task.dueTime = ""
            }
        }
    }
    TimePicker {
        id: timePicker
        onClosed: {
            if (isOK) {
                var date = new Date(task.dueDate.toString())
                date.setHours(timePicker.hrsDisplay)
                date.setMinutes(timePicker.minutesDisplay)
                task.dueTime = date
                appData.setAlarm(task.id, date.getTime(), task.name)
            } else if (clear) {
                task.dueTime = ""
                appData.cancelAlarm(task.id)
            }
        }
    }
}
