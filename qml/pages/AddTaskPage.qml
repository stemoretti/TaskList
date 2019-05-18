import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import "../ekke/common"
import "../common"
import "../popups"

AppStackPage {
    function resetFocus() { nameField.focus = false }

    title: qsTr("Add Task")
    padding: 6

    rightButtons: [
        Action {
            icon.source: "image://icon/mic"
            onTriggered: appData.startSpeechRecognizer();
        },
        Action {
            icon.source: "image://icon/add"
            onTriggered: {
                if (nameField.text.length > 0) {
                    if (appData.currentList.newTask(nameField.text)) {
                        showToast(qsTr("Added %1 to list").arg(nameField.text))
                        nameField.text = ""
                    } else {
                        showError(qsTr("%1 is already in list").arg(nameField.text))
                        resetFocus()
                    }
                } else {
                    showError(qsTr("The name field is empty"))
                    resetFocus()
                }
            }
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
//                        inputMethodHints: Qt.ImhUppercaseOnly
                        selectByMouse: true
                    }
                }

                HorizontalDivider { }
            }
        }
    }
}
